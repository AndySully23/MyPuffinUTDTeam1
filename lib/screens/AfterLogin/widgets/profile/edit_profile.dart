import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  final Map<String, dynamic> profileData;
  final Map<String, dynamic> healthData;
  EditProfile({Key? key, required this.profileData, required this.healthData})
      : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.profileData['firstname'];
    _lastNameController.text = widget.profileData['lastname'];
    _ageController.text = widget.profileData['age'];
    _heightController.text = widget.healthData['height'];
    _weightController.text = widget.healthData['weight'];
    _selectedDate =
        DateTime.fromMillisecondsSinceEpoch(widget.profileData['birthdate']);
    _profileImageUrl = widget.profileData['profileImage'];
  }

  final ScrollController scroll_controller = ScrollController();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  DateTime? _selectedDate;
  File? _selectedImage;
  String? _profileImageUrl;
  final ImagePicker _imagePicker = ImagePicker();


  // function to select image from the device
  Future<void> _pickImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

//function for uploading profile picture and updating it in firebase storage
  Future<bool> updateProfileImage(File newImage) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(widget.profileData['user'] + '.jpg');

      await ref.putFile(newImage);

      return true;
    } catch (error) {
      print("Error updating image: $error");
      return false;
    }
  }

//function that updates user data on firestore database when save button is pressed, returns a bool value depending whether or not saving was successful
  void updateProfile() async {
    try {
      if (!mounted) return;
      if (_selectedImage != null) {
        bool success = await updateProfileImage(_selectedImage!);
        if (!success) {
          print('Failed to update profile image');
          return;
        }
      }

      try {

        FirebaseFirestore _auth = FirebaseFirestore.instance;

        CollectionReference profiles = _auth.collection('profiles');
        Query query = profiles.where('user', isEqualTo: widget.profileData['user']);
        QuerySnapshot querySnapshot = await query.get();

        CollectionReference health = _auth.collection('health');
        Query healthquery = health.where('user', isEqualTo: widget.profileData['user']);
        QuerySnapshot healthSnapshot = await healthquery.get();

        if (querySnapshot.docs.isNotEmpty && healthSnapshot.docs.isNotEmpty) {

          DocumentReference docRef = querySnapshot.docs.first.reference;
          DocumentReference HealthdocRef = healthSnapshot.docs.first.reference;
          int? birthdateMillis = _selectedDate?.millisecondsSinceEpoch;

          await docRef.update({
            'firstname': _firstNameController.text,
            'lastname': _lastNameController.text,
            'age': _ageController.text,
            'birthdate': birthdateMillis
          });
          await HealthdocRef.update({
            'height': _heightController.text,
            'weight': _weightController.text,
          });
          Navigator.pop(context);
        } else {
          print("No matching documents found");
        }
      } catch (e) {
        print('An error occurred: in try');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    scroll_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: const Padding(
          padding: EdgeInsets.fromLTRB(15, 10, 10, 10),
          child: Row(
            children: [
              Text(
                'Edit Profile',
                style: TextStyle(
                    color: Color.fromARGB(255, 13, 177, 173),
                    fontSize: 28,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Back',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Scrollbar(
            controller: scroll_controller,
            child: SingleChildScrollView(
              controller: scroll_controller,
              child: Column(
                children: [
                  Stack(
                    children: [
                      // Profile Image
                      _selectedImage != null
                          ? CircleAvatar(
                              radius: 60,
                              backgroundImage: FileImage(_selectedImage!),
                              backgroundColor:
                                  Color.fromARGB(127, 131, 181, 221),
                            )
                          : CircleAvatar(
                              radius: 60,
                              backgroundImage: NetworkImage(_profileImageUrl!),
                              backgroundColor:
                                  Color.fromARGB(127, 131, 181, 221),
                            ),
                      // Edit Button at the right corner of profile image
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 15, // Set the size for the edit button
                          backgroundColor:
                              Colors.white, // To give contrast against the profile image
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.edit, size: 15, color: Colors.black),
                            onPressed: () {
                              _pickImage();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Firstname',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lastname',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Age',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        controller: _ageController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date of Birth',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton.icon(
                            onPressed: () async {
                              final selectedDateTemp =
                                  await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now()
                                          .subtract(
                                              const Duration(days: 365 * 100)),
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
                                  color: Color.fromARGB(255, 175, 175, 175),
                                  style: BorderStyle.solid),
                            ),
                            icon: const Icon(
                              Icons.calendar_today,
                              color: Colors.black,
                            ),
                            label: Text(
                              _selectedDate == null
                                  ? DateTime.fromMillisecondsSinceEpoch(
                                          widget.profileData['birthdate'])
                                      .toString()
                                      .split(' ')[0]
                                  : _selectedDate.toString().split(' ')[0],
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400),
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Height',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
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
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weight',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
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
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      updateProfile();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor:
                          const Color.fromARGB(255, 13, 177, 173),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            5), // Set the border radius here
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('UPDATE'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
