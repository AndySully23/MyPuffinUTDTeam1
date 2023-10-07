import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

// Define a class to represent health data with various attributes.
class HealthData {
  final int heartRate;
  final int bloodOxygen;
  final int skinTemperature;
  final int humidity;
  final int environmentalData;
  final double airpressure;
  final int gas;

  HealthData({
    required this.heartRate,
    required this.bloodOxygen,
    required this.skinTemperature,
    required this.humidity,
    required this.environmentalData,
    required this.airpressure,
    required this.gas,
  });
}

// Get the currently logged-in user.
final userInfo = FirebaseAuth.instance.currentUser;

// Define streams to get various health data, e.g., heart rate, blood oxygen, etc.
Stream<int> getHeartRateStream() {
  return FirebaseFirestore.instance
      .collection('heart_rate')
      .where('user', isEqualTo: userInfo!.uid)
      .orderBy('time', descending: true)
      .limit(1)
      .snapshots()
      .map((snapshot) {
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first['reading'] ?? 0;
    }
    return 0;
  });
}

Stream<int> getBloodOxygenStream() {
  return FirebaseFirestore.instance
      .collection('oxygen_saturation')
      .where('user', isEqualTo: userInfo!.uid)
      .orderBy('time', descending: true)
      .limit(1)
      .snapshots()
      .map((snapshot) {
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first['reading'] ?? 0;
    }
    return 0;
  });
}

Stream<int> getSkinTemperatureStream() {
  return FirebaseFirestore.instance
      .collection('skin_temperature')
      .where('user', isEqualTo: userInfo!.uid)
      .orderBy('time', descending: true)
      .limit(1)
      .snapshots()
      .map((snapshot) {
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first['reading'] ?? 0;
    }
    return 0;
  });
}

Stream<int> getHumidityStream() {
  return FirebaseFirestore.instance
      .collection('humidity')
      .where('user', isEqualTo: userInfo!.uid)
      .orderBy('time', descending: true)
      .limit(1)
      .snapshots()
      .map((snapshot) {
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first['reading'] ?? 0;
    }
    return 0;
  });
}

Stream<int> getAmbientTemperatureStream() {
  return FirebaseFirestore.instance
      .collection('ambient_temperature')
      .where('user', isEqualTo: userInfo!.uid)
      .orderBy('time', descending: true)
      .limit(1)
      .snapshots()
      .map((snapshot) {
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first['reading'] ?? 0;
    }
    return 0;
  });
}

Stream<double> getAirPressureStream() {
  return FirebaseFirestore.instance
      .collection('air_pressure')
      .where('user', isEqualTo: userInfo!.uid)
      .orderBy('time', descending: true)
      .limit(1)
      .snapshots()
      .map((snapshot) {
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first['reading'] ?? 0.0;
    }
    return 0.0;
  });
}

Stream<int> getGasStream() {
  return FirebaseFirestore.instance
      .collection('gas')
      .where('user', isEqualTo: userInfo!.uid)
      .orderBy('time', descending: true)
      .limit(1)
      .snapshots()
      .map((snapshot) {
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first['reading'] ?? 0;
    }
    return 0;
  });
}

// Define a stream that combines data from multiple health data streams.
Stream<List<QuerySnapshot>> combinedStreamBasedOnSensor() {
  final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
  final Timestamp oneWeekAgoTimestamp = Timestamp.fromDate(oneWeekAgo);

  return CombineLatestStream.list([
    // Combine streams for various health data types.
    FirebaseFirestore.instance
        .collection('heart_rate')
        .where('time', isGreaterThan: oneWeekAgoTimestamp)
        .where('user', isEqualTo: userInfo!.uid)
        .snapshots(),
    FirebaseFirestore.instance
        .collection('oxygen_saturation')
        .where('time', isGreaterThan: oneWeekAgoTimestamp)
        .where('user', isEqualTo: userInfo!.uid)
        .snapshots(),
    FirebaseFirestore.instance
        .collection('skin_temperature')
        .where('time', isGreaterThan: oneWeekAgoTimestamp)
        .where('user', isEqualTo: userInfo!.uid)
        .snapshots(),
    FirebaseFirestore.instance
        .collection('ambient_temperature')
        .where('time', isGreaterThan: oneWeekAgoTimestamp)
        .where('user', isEqualTo: userInfo!.uid)
        .snapshots(),
    FirebaseFirestore.instance
        .collection('humidity')
        .where('time', isGreaterThan: oneWeekAgoTimestamp)
        .where('user', isEqualTo: userInfo!.uid)
        .snapshots(),
    FirebaseFirestore.instance
        .collection('air_pressure')
        .where('time', isGreaterThan: oneWeekAgoTimestamp)
        .where('user', isEqualTo: userInfo!.uid)
        .snapshots(),
    FirebaseFirestore.instance
        .collection('gas')
        .where('time', isGreaterThan: oneWeekAgoTimestamp)
        .where('user', isEqualTo: userInfo!.uid)
        .snapshots(),
  ]);
}
