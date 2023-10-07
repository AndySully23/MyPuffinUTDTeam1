import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:futurefit/db/model/message.dart';

class ChatService extends ChangeNotifier {
  // get instance of both firebase auth and firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _store = FirebaseFirestore.instance;

  //Send Message
  Future<void> sendMessage(String receiverId, String message) async {
    //get the user info
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();
    //create a new message
    Message newMessage = Message(
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        receiverId: receiverId,
        message: message,
        timestamp: timestamp);
    //construct chat room id for current user id and receiver id
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    //add new message to database
    await _store
        .collection('chat_room')
        .doc(chatRoomId)
        .collection('message')
        .add(newMessage.toMap());
  }

  //get messages
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return _store
        .collection('chat_room')
        .doc(chatRoomId)
        .collection('message')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> sendPdfMessage(String receiverId, String pdfUrl) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    // construct your chatRoomId as you did before
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    Message newMessage = Message(
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        receiverId: receiverId,
        message: "Health summary",
        timestamp: timestamp,
        pdfUrl: pdfUrl, // This would be a new field in your Message model
    );

    await _store
        .collection('chat_room')
        .doc(chatRoomId)
        .collection('message')
        .add(newMessage.toMap());
  }
}
