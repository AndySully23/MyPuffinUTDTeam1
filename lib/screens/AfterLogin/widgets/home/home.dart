import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:futurefit/db/functions/sensordata.dart';
import 'package:futurefit/screens/AfterLogin/widgets/home/vitals.dart';
import 'package:futurefit/screens/AfterLogin/widgets/home/widgets/all_data.dart';

class Home extends StatefulWidget {
  // Constructor for the Home widget
  const Home({Key? key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;

    // Extract the username from the user's email
    final username = user!.email.toString().split('@')[0];

    late Stream<List<QuerySnapshot>> combinedStream;

    combinedStream = combinedStreamBasedOnSensor(); // Assuming you have defined this method

    return StreamBuilder<List<QuerySnapshot<Object?>>>(
      stream: combinedStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError)
          return const Center(child: Text('Something went wrong'));
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: Text("Waiting for data..."));
        final allDocs = <QueryDocumentSnapshot>[]; // Store all documents here

        // Iterate through the list of QuerySnapshots
        for (var docs in snapshot.data!) {
          // Iterate through the documents in each QuerySnapshot
          for (var doc in docs.docs) {
            allDocs.add(doc); // Add each document to the list
          }
        }

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 30, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hi,',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                          ),
                        ),
                        // Display the user's username or 'Guest' if not available
                        Text(
                          username[0].toUpperCase() + username.substring(1) ??
                              'Guest',
                          style: const TextStyle(
                            color: Color.fromARGB(255, 13, 177, 173),
                            fontSize: 40,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        border: Border.all(
                          color: const Color.fromARGB(255, 129, 129, 129), //
                          width: 2, // Border width
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: Color.fromARGB(100, 255, 17, 0),
                            radius: 12,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          CircleAvatar(
                            backgroundColor: Color.fromARGB(100, 255, 153, 0),
                            radius: 12,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          CircleAvatar(
                            backgroundColor: Color.fromARGB(255, 0, 255, 8),
                            radius: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Color.fromARGB(195, 0, 0, 0),
                      ),
                    ),
                    // Add an IconButton to navigate to the DataDisplayScreen
                    IconButton(
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (ctx) {
                          return DataDisplayScreen();
                        }));
                      },
                      icon: const Icon(Icons.storage),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              // vitals display
              const HomeExtended(),
            ],
          ),
        );
      },
    );
  }
}
