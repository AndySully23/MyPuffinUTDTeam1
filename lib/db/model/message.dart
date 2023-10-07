import 'package:cloud_firestore/cloud_firestore.dart';

// Define a class to represent a message, which includes sender information, receiver, message content, timestamp, and an optional PDF URL.
class Message {
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String message;
  final Timestamp timestamp;
  final String? pdfUrl; // An optional PDF URL.

  // Constructor for the Message class.
  Message({
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.pdfUrl, // PDF URL is optional and can be null.
  });

  // Convert the Message object to a Map for storage in Firestore.
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'pdfUrl': pdfUrl ?? "", // Handling null value, storing an empty string if pdfUrl is null.
    };
  }
}
