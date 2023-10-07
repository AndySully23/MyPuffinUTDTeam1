import 'package:cloud_firestore/cloud_firestore.dart';

// Create an instance of Firestore for database operations.
final FirebaseFirestore firestore = FirebaseFirestore.instance;

// Class for handling profile-related database operations.
class ProfileDatabaseMethods {
  // Function to add profile details to the Firestore database.
  Future addProfileDetails(Map<String, dynamic> profileInfoMap) async {
    return await firestore.collection("profiles").doc().set(profileInfoMap);
  }

  // Function to get profile data based on a specific key-value pair.
  Future<QuerySnapshot> getProfileByData(String key, String value) async {
    Query query = firestore.collection('profiles').where(key, isEqualTo: value);
    QuerySnapshot querySnapshot = await query.get();
    return querySnapshot;
  }

  // Function to get a stream of profile data based on a specific key-value pair.
  Stream<QuerySnapshot> getProfileStreamByData(String key, String value) {
    Query query = firestore.collection('profiles').where(key, isEqualTo: value);
    return query.snapshots();
  }
}

// Class for handling health-related database operations.
class HealthDatabaseMethods {
  // Function to add health details to the Firestore database.
  Future addHealthDetails(Map<String, dynamic> healthInfoMap) async {
    return await firestore.collection("health").doc().set(healthInfoMap);
  }

  // Function to get health data based on a specific key-value pair.
  Future<QuerySnapshot> getHealthByData(String key, String value) async {
    Query query = firestore.collection('health').where(key, isEqualTo: value);
    QuerySnapshot querySnapshot = await query.get();
    return querySnapshot;
  }

  // Function to get a stream of health data based on a specific key-value pair.
  Stream<QuerySnapshot> getHealthStreamByData(String key, String value) {
    Query query = firestore.collection('health').where(key, isEqualTo: value);
    return query.snapshots();
  }
}
