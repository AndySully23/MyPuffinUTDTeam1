import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:futurefit/db/functions/firebase_authentication/firebase_auth_services.dart';
import 'package:futurefit/screens/AfterLogin/homescreen.dart';
import 'package:futurefit/screens/BeforeLogin/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  final userController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'SignIn',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 13, 177, 173)
                  ),
                ),
                const SizedBox(height: 20,),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder( 
                      borderRadius: BorderRadius.circular(30),
                    ),
                    contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                    hintText: 'email',
                  ),
                ),
                const SizedBox(height: 10,),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                    hintText: 'Password',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Remember me'),
                    Switch.adaptive(
                      value: rememberMe, 
                      activeColor: const Color.fromARGB(255, 13, 177, 173),
                      inactiveTrackColor: const Color.fromARGB(149, 199, 199, 199),
                      activeTrackColor: const Color.fromARGB(103, 0, 163, 163),
                      onChanged: (ctx){
                        setState(() {
                          rememberMe = !rememberMe;
                        });
                      }
                    ),
                    
                  ],
                ),
                const SizedBox(height: 10,),
                ElevatedButton(
                  onPressed: (){
                    _signIn(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: const Color.fromARGB(255, 13, 177, 173),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Set the border radius here
                    ), 
                    minimumSize: const Size(double.infinity, 45)
                  ), 
                  child: const Text('SIGNIN'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'No account yet?',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                    TextButton(
                      onPressed: (){
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (ctx){
                            return SignupScreen();
                          }), 
                          (route) => false);
                      }, 
                      child: const Text(
                        ' Register here.',
                        style: TextStyle(
                          color: Color.fromARGB(117, 0, 94, 94),
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      )
                    ),
                    
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  // function for user login
  void _signIn(ctx) async{
    final signedIn = await SharedPreferences.getInstance();
    String email = emailController.text;
    String password = passwordController.text;

    try{
      User? user = await _auth.signInWithEmailAndPassword(email, password);
        if (user != null){
          if (rememberMe){
            await signedIn.setBool('rememberMe', true);
          } else {
            await signedIn.setBool('rememberMe', false);
          }
          Navigator.of(ctx).pushReplacement(MaterialPageRoute(builder: (ctx){
            return HomeScreen(user:user);
          }));
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(20),
              backgroundColor: Color.fromARGB(199, 255, 17, 0),
              content: Text('There is no account in this email')
            )
          );
          return;
        }
      }catch(e){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(20),
            backgroundColor: Color.fromARGB(199, 255, 17, 0),
            content: Text('There is no account in this email')
          )
        );
        return;
      }
  }
}