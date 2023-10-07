import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Stream<List<QuerySnapshot>> combinedStream;

  // Function to create a combined stream from multiple Firestore collections
  Stream<List<QuerySnapshot>> combinedStreamBasedOnSensor() {
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    final Timestamp oneWeekAgoTimestamp = Timestamp.fromDate(oneWeekAgo);
    final userInfo = FirebaseAuth.instance.currentUser;
    return CombineLatestStream.list([
      FirebaseFirestore.instance
          .collection('heart_rate')
          .where('time', isGreaterThan: oneWeekAgoTimestamp)
          .where('user', isEqualTo: userInfo!.uid)
          .snapshots(),
      FirebaseFirestore.instance
          .collection('oxygen_saturation')
          .where('time', isGreaterThan: oneWeekAgoTimestamp)
          .where('user', isEqualTo: userInfo.uid)
          .snapshots(),
      FirebaseFirestore.instance
          .collection('skin_temperature')
          .where('time', isGreaterThan: oneWeekAgoTimestamp)
          .where('user', isEqualTo: userInfo.uid)
          .snapshots(),
      FirebaseFirestore.instance
          .collection('ambient_temperature')
          .where('time', isGreaterThan: oneWeekAgoTimestamp)
          .where('user', isEqualTo: userInfo.uid)
          .snapshots(),
      FirebaseFirestore.instance
          .collection('humidity')
          .where('time', isGreaterThan: oneWeekAgoTimestamp)
          .where('user', isEqualTo: userInfo.uid)
          .snapshots(),
      FirebaseFirestore.instance
          .collection('air_pressure')
          .where('time', isGreaterThan: oneWeekAgoTimestamp)
          .where('user', isEqualTo: userInfo.uid)
          .snapshots(),
      FirebaseFirestore.instance
          .collection('gas')
          .where('time', isGreaterThan: oneWeekAgoTimestamp)
          .where('user', isEqualTo: userInfo.uid)
          .snapshots(),
    ]);
  }

  @override
  void initState() {
    super.initState();
    combinedStream = combinedStreamBasedOnSensor();
  }

  // Function to check the range and return color and message based on the reading
  Map<String, dynamic> checkRange(String collection, double reading) {
    switch (collection) {
      case 'heart_rate':
        if (reading < 60)
          return {'message': 'low', 'color': const Color.fromARGB(178, 255, 177, 60)};
        if (reading > 100)
          return {'message': 'high', 'color': const Color.fromARGB(178, 255, 96, 84)};
        break;
      case 'oxygen_saturation':
        if (reading < 95)
          return {'message': 'low', 'color': const Color.fromARGB(178, 255, 177, 60)};
        if (reading > 100)
          return {'message': 'high', 'color': const Color.fromARGB(178, 255, 96, 84)};
        break;
      case 'skin_temperature':
        if (reading < 33)
          return {'message': 'low', 'color': const Color.fromARGB(178, 255, 177, 60)};
        if (reading > 37)
          return {'message': 'high', 'color': const Color.fromARGB(178, 255, 96, 84)};
        break;
      case 'ambient_temperature':
        if (reading < 33)
          return {'message': 'low', 'color': const Color.fromARGB(178, 255, 177, 60)};
        if (reading > 37)
          return {'message': 'high', 'color': const Color.fromARGB(178, 255, 96, 84)};
        break;
      case 'humidity':
        if (reading < 30)
          return {'message': 'low', 'color': const Color.fromARGB(178, 255, 177, 60)};
        if (reading > 60)
          return {'message': 'high', 'color': const Color.fromARGB(178, 255, 96, 84)};
        break;
      case 'air_pressure':
        if (reading < 1013)
          return {'message': 'low', 'color': const Color.fromARGB(178, 255, 177, 60)};
        if (reading > 1014)
          return {'message': 'high', 'color': const Color.fromARGB(178, 255, 96, 84)};
        break;
      case 'gas':
        if (reading < 50)
          return {'message': 'low', 'color': const Color.fromARGB(178, 255, 177, 60)};
        if (reading > 80)
          return {'message': 'high', 'color': const Color.fromARGB(178, 255, 96, 84)};
        break;
      default:
        return {};
    }
    return {};
  }

  // Function to format Timestamp to a readable date-time string
  String formatDateTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute}';
  }

  // Function to capitalize the first letter of a string
  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<QuerySnapshot>>(
      stream: combinedStream,
      builder: (BuildContext context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
        if (!snapshot.hasData) return  Center(child: Text('No new alerts'));
        if (snapshot.hasError) return const Center(child: Text('Something went wrong'));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Text("Waiting for data..."));

        final allDocs = <QueryDocumentSnapshot>[]; // Store all documents here

        // Iterate through the list of QuerySnapshots
        for (var docs in snapshot.data!) {
          // Iterate through the documents in each QuerySnapshot
          for (var doc in docs.docs) {
            allDocs.add(doc); // Add each document to the list
          }
        }

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView.builder(
            itemCount: allDocs.length,
            itemBuilder: (ctx, index) {
              final doc = allDocs[index];
              final collectionName = doc.reference.parent!.id; // Get the collection name
              double reading = double.tryParse(doc['reading'].toString()) ?? 0;
              var alertInfo = checkRange(collectionName, reading);
              if (alertInfo.isEmpty) return SizedBox.shrink();

              String formattedTime = formatDateTime(doc['time'] as Timestamp);

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: alertInfo['color'] as Color,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: Icon(Icons.notifications, color: Colors.white),
                      title: Text(
                        '${capitalize(collectionName.replaceAll('_', ' '))} is ${alertInfo['message']}',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                      ),
                      subtitle: Text('Reading: $reading\nTime: $formattedTime', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
