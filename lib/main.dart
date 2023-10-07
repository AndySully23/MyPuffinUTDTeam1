// Import necessary packages and modules
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:futurefit/firebase_cloud_messaging/cloud_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:futurefit/screens/AfterLogin/homescreen.dart';
import 'package:futurefit/screens/BeforeLogin/futureflash.dart';

// Main function that initializes Firebase, sets up notifications, and runs the app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with the provided options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase Cloud Messaging for notifications
  FirebaseApi().initNotifications();

  // Check if the user has chosen to remember their login state
  await isRemembered();

  // Run the app
  runApp(
    MyApp(),
  );
}

// Define the main application widget
class MyApp extends StatelessWidget {
  MyApp({super.key});
  
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Define the theme for the entire app
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 13, 177, 173),
      ),
      home: StreamBuilder(
        // Listen to changes in the authentication state
        stream: _auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;
            if (user == null) {
              // If user is not authenticated, show the FlashScreen
              return FlashScreen();
            } else {
              // If user is authenticated, show the HomeScreen
              return HomeScreen(key: homeScreenKey, user: user);
            }
          } else {
            // Show FlashScreen while the connection state is not active
            return const FlashScreen();
          }
        },
      ),
    );
  }
}

// Function to check if the user has chosen to remember their login state
Future<void> isRemembered() async {
  final signedIn = await SharedPreferences.getInstance();
  final remember = signedIn.getBool('rememberMe');
  if (remember == false) {
    // If rememberMe is false, sign the user out
    await FirebaseAuth.instance.signOut();
  }
}
