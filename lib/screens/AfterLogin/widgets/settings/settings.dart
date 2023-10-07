import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:futurefit/screens/AfterLogin/widgets/settings/account_settings/account_settings.dart';
import 'package:futurefit/screens/BeforeLogin/login.dart';

class Settings extends StatelessWidget {
  Settings({Key? key}) : super(key: key);
  
  final setting_List = [
    {
      'set': 'Account settings',
      'ico': Icons.account_box,
      'action': (BuildContext context) {
        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => AccountSettings()));
      },
    },
    {
      'set': 'Notification settings',
      'ico': Icons.notifications,
      'action': (BuildContext context) {
        // Add logic for Notification settings
      },
    },
    {
      'set': 'Subscription settings',
      'ico': Icons.subscriptions,
      'action': (BuildContext context) {
        // Add logic for Subscription settings
      },
    },
    {
      'set': 'Logout',
      'ico': Icons.logout,
      'action': (BuildContext context) async {
        await FirebaseAuth.instance.signOut();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false, // this ensures all previous routes are removed
        );
      },
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (ctx, index) {
        return ListTile(
          leading: Icon(setting_List[index]['ico'] as IconData),
          title: Text(setting_List[index]['set'] as String),
          onTap: () {
            final action = setting_List[index]['action'];
            if (action != null) {
              (action as Function(BuildContext))(context);
            }
          },
        );
      },
      separatorBuilder: (ctx, index) {
        return const Padding(
          padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: Divider(color: Color.fromARGB(61, 158, 158, 158),),
        );
      },
      itemCount: setting_List.length,
    );
  }
}
