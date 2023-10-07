import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to sign up a user with email, password, and username.
  Future<User?> signUpWithEmailAndPassword(String email, String password, String username) async {
    try {
      // Create a user with email and password using FirebaseAuth.
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // If the user was created successfully, store additional user data in Firestore.
      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'username': username,
          'email': email,
        });
      }

      // Return the user who signed up.
      return credential.user;
    } catch (e) {
      print(e); // Print any error that occurs during the sign-up process.
    }
    return null; // Return null if the sign-up fails.
  }

  // Function to sign in a user with email and password.
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Sign in the user using FirebaseAuth.
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Return the signed-in user.
      return credential.user;
    } catch (e) {
      print(e); // Print any error that occurs during the sign-in process.
    }
    return null; // Return null if the sign-in fails.
  }
}
