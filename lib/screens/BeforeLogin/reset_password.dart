import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatelessWidget {
  ResetPasswordScreen({super.key});

  final userController = TextEditingController();
  final passwordController = TextEditingController();

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
                  'Set a new password',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 13, 177, 173)
                  ),
                ),
                const SizedBox(height: 20,),
                const Text(
                  'Must be atleast eight characters',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 20,),
                SizedBox(
                  height: 45,
                  child: TextFormField(
                    controller: userController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 2,
                        )
                      ),
                      hintText: 'New password',
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                SizedBox(
                  height: 45,
                  child: TextFormField(
                    controller: userController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 2,
                        )
                      ),
                      hintText: 'Confirm password',
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                ElevatedButton(
                  onPressed: (){
                    
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: const Color.fromARGB(255, 13, 177, 173),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5), // Set the border radius here
                    ), 
                    minimumSize: const Size(double.infinity, 50)
                  ), 
                  child: const Text('RESET PASSWORD'),
                  
                ),
                const Text(
                  'Back to login',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w400
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Future<void> LoginWithData() async{
    final user = userController.text;
    final password = userController.text;
    if(user == password){

    }
  
  }
}