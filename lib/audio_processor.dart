import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';

class WaveformWidget extends StatefulWidget {

  const WaveformWidget({Key? key}) : super(key: key);

  @override
  _WaveformWidgetState createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<WaveformWidget> {
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
  late String waveformImagePath;
  bool isProcessing = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _downloadAndGenerateWaveform();
  }


  Future<void> _downloadAndGenerateWaveform() async {
    try {
    
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('sensor')
          .where('name', isEqualTo: 'Chest Wearable')
          .where('user', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      final List<DocumentSnapshot> documents = querySnapshot.docs;

      final QuerySnapshot readingDoc = await FirebaseFirestore.instance
          .collection('stethescope_reading')
          .where('sensor', isEqualTo: documents[0].id)
          .orderBy('time', descending: true)
          .get();
      final DocumentSnapshot readingdocuments = readingDoc.docs.first;




      final audioFileUrl = readingdocuments['audio_data'] as String?;
      if (audioFileUrl == null) throw Exception('Audio data is missing');

      final Directory tempDir = await getTemporaryDirectory();
      final File tempAudioFile = File('${tempDir.path}/audio.mp3');

      final ref = FirebaseStorage.instance.refFromURL(audioFileUrl);
      await ref.writeToFile(tempAudioFile);

      final double frequencyOfWave = 1; // Hz
      final double durationOfSingleWave = 1 / frequencyOfWave; // seconds
      final int pixelsPerSecond = 640; // Pixels
      final int waveformWidth = (durationOfSingleWave * pixelsPerSecond).toInt();

      waveformImagePath = '${tempDir.path}/${Timestamp.now().microsecondsSinceEpoch}.png';
      final command = '-i ${tempAudioFile.path} -t $durationOfSingleWave -lavfi showwavespic=s=${waveformWidth}x120 -frames:v 1 $waveformImagePath';
      final int rc = await _flutterFFmpeg.execute(command);

      if (rc != 0) throw Exception('FFmpeg process exited with rc $rc');

    } catch (e) {
      error = 'Error generating waveform: $e';
    } finally {
      setState(() => isProcessing = false);
    }
  }




  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double containerHeight = 100; // Replace with your desired container height
    
    if (isProcessing) return CircularProgressIndicator();
    if (error != null) return Text(error!);
    
    return Container(
      width: deviceWidth, // Container width is equal to device width
      height: containerHeight, // Specific height for the container
      color: Colors.white,
      child: Image.file(
        File(waveformImagePath),
        width: deviceWidth,
        fit: BoxFit.fitWidth, // Image will maintain its ratio and fit within the container
      ),
    );
}
}
