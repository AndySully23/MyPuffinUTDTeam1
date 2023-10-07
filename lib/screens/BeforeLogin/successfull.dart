import 'package:flutter/material.dart';

class PasswordChangeSuccess extends StatelessWidget {
  const PasswordChangeSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline_rounded, 
                size: 100, color: Color.fromARGB(255, 13, 177, 173),
                
              ),
              Text(
                'You have successfully changed your password\nPlease use the new password to login', 
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color.fromARGB(255, 125, 125, 125),
                    fontSize: 14,
                    fontWeight: FontWeight.w400
                  ),
              ),
              SizedBox(height: 20,),
              Text(
                  'Back to login',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontSize: 14,
                    fontWeight: FontWeight.w400
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}