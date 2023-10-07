import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:futurefit/db/services/chat_service.dart';
import 'package:futurefit/screens/AfterLogin/homescreen.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';

class DataDisplayScreen extends StatefulWidget {
  @override
  _DataDisplayScreenState createState() => _DataDisplayScreenState();
}

class _DataDisplayScreenState extends State<DataDisplayScreen> {
  // Get the current user using FirebaseAuth
  final User? user = FirebaseAuth.instance.currentUser;

  // Map to hold measures and their corresponding units
  Map<String, String> measures = {
    'heart_rate': 'bpm',
    'skin_temperature': '°C',
    'ambient_temperature': '°C',
    'humidity': '%',
    'air_pressure': 'hPa',
    'gas': 'R',
    'photoplethysmography': 'ppg',
    'oxygen_saturation': 'SpO2 (%)'
  };

  // Helper function to capitalize text
  String capitalize(String text) {
    text = text.replaceAll('_', ' ');
    return text
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  // Function to generate a PDF document with health data
  Future<File> generatePdf(Map<String, dynamic> data) async {
    final pdf = pw.Document();
    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);
    final titleStyle =
        pw.TextStyle(font: ttf, fontSize: 24, color: PdfColors.blue);
    final headerStyle = pw.TextStyle(
        font: ttf,
        fontSize: 18,
        color: PdfColors.blue,
        fontWeight: pw.FontWeight.bold);
    final contentStyle =
        pw.TextStyle(font: ttf, fontSize: 18, color: PdfColors.black);
    final itemStyle = contentStyle.copyWith(fontSize: 16);

    // Fetch user profile data from Firestore
    final profileData = await FirebaseFirestore.instance
        .collection('profiles')
        .where('user', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    final profile = profileData.docs.first.data();

    // Fetch health data from Firestore
    final healthData = await FirebaseFirestore.instance
        .collection('health')
        .where('user', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    final health = healthData.docs.first.data();

    // Build the PDF document
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(child: pw.Text('Health Data Summary', style: titleStyle)),
            pw.SizedBox(height: 50),
            pw.Text('Name: ${profile['firstname']} ${profile['lastname']}',
                style: contentStyle),
            pw.SizedBox(height: 5),
            pw.Text('Age: ${profile['age']}', style: contentStyle),
            pw.SizedBox(height: 5),
            pw.Text(
                'Birthdate: ${DateTime.fromMillisecondsSinceEpoch(profile['birthdate']).toString().split(' ')[0]}',
                style: contentStyle),
            pw.SizedBox(height: 5),
            pw.Text('Height: ${health['height']}', style: contentStyle),
            pw.SizedBox(height: 5),
            pw.Text('Weight: ${health['weight']}', style: contentStyle),
            pw.SizedBox(height: 20),
            pw.Divider(color: PdfColors.grey400),
            pw.Expanded(
              child: pw.ListView.builder(
                itemCount: data.keys.length,
                itemBuilder: (context, index) {
                  String key = data.keys.elementAt(index);
                  var value = data[key];
                  return pw.Container(
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        bottom:
                            pw.BorderSide(color: PdfColors.grey, width: 0.5),
                      ),
                    ),
                    padding: const pw.EdgeInsets.symmetric(vertical: 5),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('${capitalize(key)}:', style: contentStyle),
                        pw.Text('${value['reading']} ${measures[key] ?? ""}',
                            style: itemStyle),
                      ],
                    ),
                  );
                },
              ),
            ),
            pw.Divider(color: PdfColors.grey400),
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('My Puffin™', style: headerStyle),
            ),
          ],
        ),
      ),
    );

    // Get the application directory to save the PDF file
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/summary.pdf');

    // Write the PDF content to the file
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  // Function to upload a PDF to Firebase Storage
  Future<String> uploadPdfToFirebaseStorage(File pdfFile) async {
    try {
      // Create a unique file name for the upload
      String fileName = 'pdfs/${DateTime.now().millisecondsSinceEpoch}.pdf';

      // Get a reference to the location where the file will be saved
      Reference ref = FirebaseStorage.instance.ref(fileName);

      // Upload the file
      await ref.putFile(pdfFile);

      // Once uploaded, retrieve and return the download URL
      String downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Failed to upload PDF: $e');
      throw e;
    }
  }

  // Function to handle generating and sharing the PDF
  void onGeneratePdfButtonPressed() async {
    final data = await fetchData();
    final pdfFile = await generatePdf(data);
    final xFile = XFile(pdfFile.path);

    Share.shareXFiles([xFile]);
  }

  // Function to handle generating and sending the PDF
  void onSendPdfButtonPressed() async {
    final data = await fetchData();
    final pdfFile = await generatePdf(data);

    // Upload the PDF to Firebase Storage here and get the download URL
    String pdfUrl = await uploadPdfToFirebaseStorage(pdfFile);

    // Now, send this pdf as a message using the ChatService
    ChatService().sendPdfMessage('oc7mZuocEIYogTUDvG6P', pdfUrl);

    // Navigate back to the home screen and change the tab index
    Navigator.popUntil(
        context, ModalRoute.withName(Navigator.defaultRouteName));

    homeScreenKey.currentState?.changeTabIndex(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Floating action button to send the PDF
      floatingActionButton: FloatingActionButton(
        onPressed: onSendPdfButtonPressed,
        child: Icon(Icons.send),
        backgroundColor: const Color.fromARGB(255, 13, 177, 173),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Health Summary',
          style: TextStyle(
              color: Color.fromARGB(255, 13, 177, 173),
              fontSize: 28,
              fontWeight: FontWeight.w600),
        ),
        actions: [
          // IconButton to generate and share the PDF
          IconButton(
              onPressed: onGeneratePdfButtonPressed,
              icon: const Icon(
                Icons.share,
                color: Colors.black,
              ))
        ],
        backgroundColor: Colors.white,
      ),
      body: user == null
          ? Center(child: Text('No user found'))
          : FutureBuilder(
              future: fetchData(),
              builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());
                if (snapshot.hasError)
                  return Center(child: Text('Something went wrong'));
                if (!snapshot.hasData || snapshot.data!.isEmpty)
                  return Center(child: Text('No data found'));

                Map<String, dynamic> data = snapshot.data!;

                return ListView.builder(
                  itemCount: data.keys.length,
                  itemBuilder: (context, index) {
                    String key = data.keys.elementAt(index);
                    var value = data[key];
                    return ListTile(
                      title: Text(
                        capitalize(key),
                        style: const TextStyle(
                          color: Color.fromARGB(255, 13, 177, 173),
                          fontSize: 20
                        ),
                      ),
                      subtitle:
                          Text(
                            '${value['reading']} ${measures[key] ?? ""}',
                            style: const TextStyle(
                              fontSize: 18
                            ),
                          ),
                    );
                  },
                );
              },
            ),
    );
  }

  // Function to fetch health data from Firestore
  Future<Map<String, dynamic>> fetchData() async {
    Map<String, dynamic> allData = {};

    // Query sensors data from Firestore
    final sensorsSnapshot = await FirebaseFirestore.instance
        .collection('sensor')
        .where('user', isEqualTo: user!.uid)
        .get();

    for (var sensorDoc in sensorsSnapshot.docs) {
      String sensorId = sensorDoc.id;
      String sensorName = sensorDoc['name'];

      List<String> collectionsToQuery;
      if (sensorName == 'Chest Wearable') {
        collectionsToQuery = [
          'humidity',
          'air_pressure',
          'gas',
          'ambient_temperature',
          'stethescope_audio'
        ];
      } else if (sensorName == 'Wrist Wearable') {
        collectionsToQuery = [
          'photoplethysmography',
          'skin_temperature',
          'heart_rate',
          'oxygen_saturation'
        ];
      } else {
        continue;
      }

      for (var collectionName in collectionsToQuery) {
        final collectionSnapshot = await FirebaseFirestore.instance
            .collection(collectionName)
            .where('sensor', isEqualTo: sensorId)
            .orderBy('time', descending: true)
            .limit(1)
            .get();

        if (collectionSnapshot.docs.isNotEmpty) {
          allData['$collectionName'] = collectionSnapshot.docs.first.data();
        }
      }
    }

    return allData;
  }
}
