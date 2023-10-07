import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:futurefit/screens/AfterLogin/widgets/settings/account_settings/username_password_change.dart';
import 'package:futurefit/screens/BeforeLogin/login.dart';

class AccountSettings extends StatelessWidget {
  AccountSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //    List of settings 
    final setting_List = [
      {
        'set': 'Username/Password change',
        'ico': Icons.account_box,
        'dest': UserPasswordChangeScreen(),
      },
      {
        'set': 'Delete account',
        'ico': Icons.notifications,
        'action': () => _showDeleteAccountDialog(context),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Text(
              'Account Settings',
              style: TextStyle(
                color: Color.fromARGB(255, 13, 177, 173),
                fontSize: 28,
                fontWeight: FontWeight.w600
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Back', style: TextStyle(color: Colors.black),),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.separated(
          itemBuilder: (ctx, index) {
            return ListTile(
              leading: Icon(setting_List[index]['ico'] as IconData),
              title: Text(setting_List[index]['set'] as String),
              onTap: () {
                if (setting_List[index]['dest'] != null) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => setting_List[index]['dest'] as Widget,
                  ));
                } else if (setting_List[index]['action'] != null) {
                  (setting_List[index]['action'] as Function)();
                }
              },
            );
          },
          separatorBuilder: (ctx, index) {
            return Padding(
              padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Divider(
                color: Color.fromARGB(61, 158, 158, 158),
              ),
            );
          },
          itemCount: setting_List.length,
        ),
      ),
    );
  }

  // Function to re authenticate user
  Future<void> _reauthenticateUser(BuildContext context, String password) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      try {
        await user.reauthenticateWithCredential(credential);
        await _deleteAccount(context);
      } catch (e) {
        print("Error during re-authentication: $e");
        // Provide feedback to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Re-authentication failed. Please try again.'))
        );
      }
    }
  }
  // function to delete account
  Future<void> _deleteAccount(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await user.delete();
        print("User account deleted");
        Navigator.pop(context); // Close the dialog
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
      } catch (e) {
        if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
          print("The user must re-authenticate before this operation can be executed.");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Re-authentication required. Please try again.'))
          );
        } else {
          print("An error occurred while deleting the user: $e");
        }
      }
    } else {
      print("No user is currently signed in.");
    }
  }

  // Function to show the delete account dialog box
  void _showDeleteAccountDialog(BuildContext context) {
    final TextEditingController _passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Please enter your password to confirm account deletion.'),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _reauthenticateUser(context, _passwordController.text);
              },
              child: Text('Delete Account'),
            ),
          ],
        );
      },
    );
  }
}
