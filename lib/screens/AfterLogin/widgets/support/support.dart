import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:futurefit/db/services/chat_service.dart';

class Support extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;

  const Support({
    Key? key,
    required this.receiverEmail,
    required this.receiverID,
  }) : super(key: key);

  @override
  State<Support> createState() => _SupportState();
}

class _SupportState extends State<Support> {
  List<String> messages = [];

  // Controller for the message input field
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _scrollController = ScrollController();

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      // Send a message using the chat service
      await _chatService.sendMessage(
          widget.receiverID, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
          widget.receiverID, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Display the list of messages
        return ListView(
          controller: _scrollController,
          reverse: true, // Scroll to the latest message
          children: snapshot.data!.docs
              .map((document) => _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    // Determine the alignment of the message (left for received, right for sent)
    var alignment = data['senderId'] == _firebaseAuth.currentUser!.uid
        ? Alignment.centerRight
        : Alignment.centerLeft;

    bool hasPdf = data['pdfUrl'] != null && data['pdfUrl'].isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 1, 0, 0),
      child: Container(
        alignment: alignment,
        child: Column(
          crossAxisAlignment: data['senderId'] == _firebaseAuth.currentUser!.uid
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              // Display sender's name (or "me" for own messages)
              data['senderEmail'] == _firebaseAuth.currentUser!.email
                  ? 'me'
                  : data['senderEmail'].split('@')[0],
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Container(
              alignment: alignment,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(10),
                    topRight: const Radius.circular(10),
                    bottomLeft: data['senderId'] == _firebaseAuth.currentUser!.uid
                        ? const Radius.circular(10)
                        : const Radius.circular(0),
                    bottomRight:
                        data['senderId'] == _firebaseAuth.currentUser!.uid
                            ? const Radius.circular(0)
                            : const Radius.circular(10),
                  ),
                  color: data['senderId'] == _firebaseAuth.currentUser!.uid
                      ? const Color.fromARGB(255, 13, 177, 173)
                      : Color.fromARGB(255, 133, 133, 133),
                ),
                child: Column(
                  children: [
                    if (hasPdf)
                      InkWell(
                        onTap: () {
                          // Handle PDF tapping, e.g. open PDF
                        },
                        child: Image.asset(
                          'assets/images/pdf.png',
                          height: 50,
                          width: 50,
                        ), // Replace with your actual PDF icon
                      ),
                    Text(
                      data['message'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Enter message',
              ),
            ),
          ),
          IconButton(
            onPressed: sendMessage,
            icon: Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
