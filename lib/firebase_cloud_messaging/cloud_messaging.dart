import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

Future<void> handleBackground(RemoteMessage message) async{
  print('\n');
  print('Title : ${message.notification?.title}');
  print('Body : ${message.notification?.body}');
  print('Payload : ${message.data}');
  print('\n');
}

class FirebaseApi{
  
  User? user = _auth.currentUser;

  Future<void> initNotifications() async{
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    await _db.collection('users').doc(user!.uid).set({
          'token': fCMToken,
        }, SetOptions(merge: true));
    FirebaseMessaging.onBackgroundMessage(handleBackground);
  }
}