import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserPasswordChangeScreen extends StatefulWidget {
  UserPasswordChangeScreen({super.key});

  @override
  _UserPasswordChangeScreenState createState() => _UserPasswordChangeScreenState();
}

class _UserPasswordChangeScreenState extends State<UserPasswordChangeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final _formKeyemail = GlobalKey<FormState>();
  final _formKeypassword = GlobalKey<FormState>();
  String? ValidateEmail(String? email) {
    RegExp emailRegex = RegExp(r'^[\w\.-]+@[\w-]+\.\w{2,3}(\.\w{2,3})?$');
    final isEmailValid = emailRegex.hasMatch(email ?? '');
    if(!isEmailValid){
      return 'Please enter a valid email';
    }
    return null;
  }

   
  // Function to validate password field
  String? ValidatePassword(String? password){
    final warning_text = 'Please enter a valid password which includes: \n1. Eight digits\n2. Uppercase characters\n3. Lowercase characters\n4. Symbols\n5. Numbers';
    if(password!.length < 8){
      return warning_text;
    } 
    if(!password.contains(RegExp(r'[A-Z]'))){
      return warning_text;
    }
    if(!password.contains(RegExp(r'[a-z]'))){
      return warning_text;
    }
    if(!password.contains(RegExp(r'[0-9]'))){
      return warning_text;
    }
    if(!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))){
      return warning_text;
    }
    return null;
  }

  // function to update email of user
  _updateEmail() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reauthentication Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please enter your current password'),
            TextField(
              obscureText: true,
              controller: currentPasswordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                String email = _auth.currentUser!.email!;
                AuthCredential credential = EmailAuthProvider.credential(email: email, password: currentPasswordController.text);
                await _auth.currentUser!.reauthenticateWithCredential(credential);
                await _auth.currentUser!.updateEmail(emailController.text);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Email Updated Successfully'),
                ));
                Navigator.of(context).pop();
              } catch (e) {
                emailController.text = '';
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Wrong password! Try Again.'),
                ));
              }
            },
            child: const Text('Reauthenticate'),
          ),
        ],
      ),
    );
  }

  // function to update user password
  _updatePassword() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reauthentication Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please enter your current password'),
            TextField(
              obscureText: true,
              controller: currentPasswordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                String email = _auth.currentUser!.email!;
                AuthCredential credential = EmailAuthProvider.credential(email: email, password: currentPasswordController.text);
                await _auth.currentUser!.reauthenticateWithCredential(credential);
                await _auth.currentUser!.updatePassword(passwordController.text);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Password Updated Successfully'),
                ));
                Navigator.of(context).pop(); // Close the dialog
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Error: $e'),
                ));
              }
            },
            child: Text('Reauthenticate'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Text(
              'Change Email or Password',
              style: TextStyle(
                color: Color.fromARGB(255, 13, 177, 173),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Back', style: TextStyle(color: Colors.black),),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10,),
                Form(
                  key: _formKeyemail,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Change Email',
                        style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 20,),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30)
                        ),
                        hintText: 'Email',
                        contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                      ),
                        validator: ValidateEmail,
                      ),
                      const SizedBox(height: 20,),
                      ElevatedButton(
                        onPressed: () async{
                          
                          final _validate = _formKeyemail.currentState!.validate();
                          if (!_validate == false){
                            _updateEmail();
                          }
                          
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color.fromARGB(255, 13, 177, 173),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30), // Set the border radius here
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('UPDATE EMAIL'),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30,),
                Form(
                  key: _formKeypassword,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Change Password',
                        style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 20,),
                      TextFormField(
                        obscureText: true,
                        controller: passwordController,
                        decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30)
                        ),
                        hintText: 'New password',
                        contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                      ),
                        validator: ValidatePassword,
                      ),
                      const SizedBox(height: 10,),
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30)
                        ),
                        hintText: 'Confirm password',
                        contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                      ),
                      
                        validator: (cpassword)=>cpassword!=passwordController.text?'Confirm the above password':null,
                      ),
                      const SizedBox(height: 20,),
                      ElevatedButton(
                        onPressed: () async{
                            
                            final _validate = _formKeypassword.currentState!.validate();
                            if (!_validate == false){
                              _updatePassword();
                            }
                            
                          },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color.fromARGB(255, 13, 177, 173),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30), // Set the border radius here
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('UPDATE PASSWORD'),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
