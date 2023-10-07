import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:futurefit/db/functions/firebase_authentication/firebase_auth_services.dart';
import 'package:futurefit/screens/BeforeLogin/add_more_details.dart';
import 'package:futurefit/screens/BeforeLogin/login.dart';


class SignupScreen extends StatefulWidget {
  SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  final FirebaseAuthService _auth = FirebaseAuthService();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final cpasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String? ValidateEmail(String? email) {
    RegExp emailRegex = RegExp(r'^[\w\.-]+@[\w-]+\.\w{2,3}(\.\w{2,3})?$');
    final isEmailValid = emailRegex.hasMatch(email ?? '');
    if(!isEmailValid){
      return 'Please enter a valid email';
    }
    return null;
  }

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


  @override
  void dispose() {
    cpasswordController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'SignUp',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 13, 177, 173)
                      ),
                    ),
                    const SizedBox(height: 10,),
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
                    
                    const SizedBox(height: 10,),
                    TextFormField(
                      obscureText: true,
                      controller: passwordController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30)
                        ),
                        hintText: 'Password',
                        contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                      ),
                      validator: ValidatePassword,
                    ),
                    const SizedBox(height: 10,),
                    TextFormField(
                      obscureText: true,
                      controller: cpasswordController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30)
                        ),
                        hintText: 'Confirm password',
                        contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                      ),
                      validator: (cpassword)=>cpassword!=passwordController.text?'Confirm the above password':null,
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'I agree to terms of use',
                          style: TextStyle(
                            color: Color.fromARGB(255, 139, 139, 139),
                          ),
                        ),
                        Switch(
                          value: true, 
                          activeColor: const Color.fromARGB(255, 13, 177, 173),
                          inactiveTrackColor: const Color.fromARGB(255, 255, 255, 255),
                          activeTrackColor: const Color.fromARGB(149, 196, 195, 195),
                          onChanged: (ctx){
                            
                          }
                        ),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    ElevatedButton(
                      onPressed: () async{
                        
                        final _validate = _formKey.currentState!.validate();
                        if (!_validate == false){
                          // SignUpWithData(context);
                          _signUp(context);
                        }
                        
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: const Color.fromARGB(255, 13, 177, 173),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // Set the border radius here
                        ), 
                        minimumSize: const Size(double.infinity, 45)
                      ), 
                      child: const Text('SIGNUP'),
                    ),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already a member?',
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
                                return LoginScreen();
                              }), 
                              (route) => false);
                          }, 
                          child: const Text(
                            ' SignIn.',
                            style: TextStyle(
                              color: Color.fromARGB(117, 0, 94, 94),
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          )
                        ),
                        
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
      ),
    );
  }
  // function for user signup
  void _signUp(ctx) async{
    String username = emailController.text.split('@')[0];
    String email = emailController.text;
    String password = passwordController.text;
    User? user = await _auth.signUpWithEmailAndPassword(email, password, username);
    if (user != null){
      final sensorCollection = FirebaseFirestore.instance.collection('sensor');
      
      Map<String, dynamic> doc1 = {
        'user': user.uid,
        'battery': 100,
        'connected': true,
        'name': 'Chest Wearable',
      };
      
      Map<String, dynamic> doc2 = {
        'user': user.uid,
        'battery': 100,
        'connected': true,
        'name': 'Wrist Wearable',
      };

      await sensorCollection.add(doc1);
      await sensorCollection.add(doc2);
      
      Navigator.of(ctx).pushReplacement(MaterialPageRoute(builder: (ctx){
        return AddDetailsScreen(user:user);
      }));
    } else {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 10),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(20),
          backgroundColor: Color.fromARGB(199, 255, 17, 0),
          content: Text('The email address is already in use by another account.') 
        )
      );
    }
    return null;
  }
}


        

        


