import 'package:flutter/material.dart';
import 'package:futurefit/main.dart';
import 'package:futurefit/screens/BeforeLogin/login.dart';

class FlashScreen extends StatefulWidget {
  const FlashScreen({super.key});

  @override
  State<FlashScreen> createState() => _FlashScreenState();
}

class _FlashScreenState extends State<FlashScreen> {

  @override
  void initState() {
    getSavedData();
    super.initState();
  }

  void getSavedData()async{
    await Future.delayed(Duration(seconds: 3), (){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // getSavedData(context);
    return const Scaffold(
      body: Center(
        child: Text(
          'My Puffin™',
          style: TextStyle(
            fontSize: 48,
            color: Color.fromARGB(255, 0, 120, 150),
          ),
        ),
      ),
    );
  }
}