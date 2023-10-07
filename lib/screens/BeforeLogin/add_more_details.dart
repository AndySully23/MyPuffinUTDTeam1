import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:futurefit/db/functions/firebasedb_methods.dart';
import 'package:futurefit/screens/AfterLogin/homescreen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

enum GenderType{
  male,
  female,
  other,
}

class AddDetailsScreen extends StatefulWidget {
  final User user;

  AddDetailsScreen({Key? key, required this.user}) : super(key: key);

  @override
  _AddDetailsScreenState createState() => _AddDetailsScreenState();
}


class _AddDetailsScreenState extends State<AddDetailsScreen>
    with SingleTickerProviderStateMixin {

  final dataList = [];
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  DateTime? _selectedDate;
  GenderType? _selectedGenderType;
  String? _GenderID;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  late Future<Map<String, dynamic>> userDetails;
  
  // Function to pick image from the device
  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery); // For camera, use ImageSource.camera

    setState(() {
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }
  // Function to upload image to firebase storage
  Future<String?> uploadImageToFirebase(File image) async {
    try {
      // Upload the image to Firebase Storage
      final ref = FirebaseStorage.instance.ref().child('profile_images').child(widget.user.uid + '.jpg');
      await ref.putFile(image);

      // Once the upload is complete, get the download URL
      final imageUrl = await ref.getDownloadURL();

      return imageUrl; // This is the download URL we'll save in Firestore
    } catch (error) {
      print("Error uploading image: $error");
      return null;
    }
  }
  // function to upload user profile data
  uploadData() async{
    String? imageUrl;

    if (_selectedImage != null) {
      imageUrl = await uploadImageToFirebase(_selectedImage!);
    }

    Map<String, dynamic> uploadprofile={
      'user': widget.user.uid,
      'firstname': _firstNameController.text,
      'lastname': _lastNameController.text,
      'age': _ageController.text,
      'gender': _selectedGenderType.toString(),
      'birthdate': _selectedDate?.millisecondsSinceEpoch,
      if (imageUrl != null) 'profileImage': imageUrl,
    };

    Map<String, dynamic> uploadhealth={
      'user': widget.user.uid,
      'height': _heightController.text,
      'weight': _weightController.text,
    };
    
    final profiledata = await ProfileDatabaseMethods().getProfileByData('user', widget.user.uid);
    if(profiledata.docs.isEmpty){
      await ProfileDatabaseMethods().addProfileDetails(uploadprofile);
      await HealthDatabaseMethods().addHealthDetails(uploadhealth);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx){
        return HomeScreen(user:widget.user);
      }));
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.transparent, // or any color you prefer
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!) as ImageProvider
                      : AssetImage('assets/images/personaldata.jpg'),
                ),
                const Text(
                  "Personal Details",
                  style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 0, 0, 0)),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text("Pick Profile Image"),
                ),
                // Image picker integration ends here
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    hintText: 'Firstname',
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    hintText: 'lastname',
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _ageController,
                  // inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    hintText: 'Age',
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                      onPressed: () async {
                        final selectedDateTemp = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 365 * 100)),
                            lastDate: DateTime.now());
                        if (selectedDateTemp == null) {
                          return;
                        } else {
                          setState(() {
                            _selectedDate = selectedDateTemp;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: Colors.white,
                        side: const BorderSide(
                            width: 1,
                            color: Color.fromARGB(255, 88, 88, 88),
                            style: BorderStyle.solid),
                      ),
                      icon: const Icon(
                        Icons.calendar_today,
                        color: Colors.black,
                      ),
                      label: Text(
                        _selectedDate == null
                            ? 'Date of Birth'
                            : _selectedDate.toString().split(' ')[0],
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w400),
                      )),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Radio(
                          value: GenderType.female,
                          groupValue: _selectedGenderType,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedGenderType = GenderType.female;
                              _GenderID = null;
                            });
                          },
                        ),
                        const Text('Female'),
                      ],
                    ),
                    Row(
                      children: [
                        Radio(
                          value: GenderType.male,
                          groupValue: _selectedGenderType,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedGenderType = GenderType.male;
                              _GenderID = null;
                            });
                          },
                        ),
                        const Text('Male'),
                      ],
                    ),
                    Row(
                      children: [
                        Radio(
                          value: GenderType.other,
                          groupValue: _selectedGenderType,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedGenderType = GenderType.other;
                              _GenderID = null;
                            });
                          },
                        ),
                        const Text('Other'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _heightController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    hintText: 'Height',
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _weightController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    hintText: 'Weight',
                  ),
                ),
                const SizedBox(height: 30,),
                ElevatedButton(
                      onPressed: (){
                        // addAllData(context);
                        uploadData();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: const Color.fromARGB(255, 13, 177, 173),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // Set the border radius here
                        ), 
                        minimumSize: const Size(double.infinity, 55)
                      ), 
                      child: const Text('FINISH'),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}