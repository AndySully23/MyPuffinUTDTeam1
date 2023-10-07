import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:futurefit/db/functions/firebasedb_methods.dart';
import 'package:futurefit/screens/AfterLogin/widgets/profile/edit_profile.dart';
import 'package:rxdart/rxdart.dart';

class Profile extends StatefulWidget {
  Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    FirebaseAuth _auth = FirebaseAuth.instance;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: const Padding(
          padding: EdgeInsets.fromLTRB(15, 10, 10, 10),
          child: Row(
            children: [
              Text(
                'Profile',
                style: TextStyle(
                  color: Color.fromARGB(255, 13, 177, 173),
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                ),
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
            controller: scrollController,
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(
                decelerationRate: ScrollDecelerationRate.normal,
              ),
              child: StreamBuilder<List<QuerySnapshot>>(
                stream: CombineLatestStream.list<QuerySnapshot>([
                  profileDetails(FirebaseAuth.instance),
                  HealthDetails(FirebaseAuth.instance),
                ]),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  final profileData = snapshot.data![0].docs.first.data()
                      as Map<String, dynamic>;
                  final healthData = snapshot.data![1].docs.first.data()
                      as Map<String, dynamic>;

                  return Column(
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(
                            profileData['profileImage'] ??
                                'https://i.pngimg.me/thumb/f/720/1d714a7743.jpg',
                          ),
                          backgroundColor: Color.fromARGB(127, 131, 181, 221),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Text(
                        "${profileData['firstname']} ${profileData['lastname']}" ??
                            '',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 13, 177, 173),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      // Repeated structure for other profile details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                            child: Text(
                              'Age',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                            child: Text(
                              profileData['age'] ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Color.fromARGB(255, 63, 63, 63),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                            child: Text(
                              'Birth Date',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                            child: Text(
                              DateTime.fromMillisecondsSinceEpoch(
                                          profileData['birthdate'])
                                      .toString()
                                      .split(' ')[0] ??
                                  '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Color.fromARGB(255, 63, 63, 63),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                            child: Text(
                              'Gender',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                            child: Text(
                              profileData['gender'] == 'GenderType.male'
                                  ? 'Male'
                                  : 'Female',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Color.fromARGB(255, 63, 63, 63),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                            child: Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                            child: Text(
                              _auth.currentUser?.email ?? 'No email found',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Color.fromARGB(255, 63, 63, 63),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                            child: Text(
                              'Height',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                            child: Text(
                              healthData['height'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Color.fromARGB(255, 63, 63, 63),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                            child: Text(
                              'Weight',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                            child: Text(
                              healthData['weight'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Color.fromARGB(255, 63, 63, 63),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => EditProfile(
                                profileData: profileData,
                                healthData: healthData,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              const Color.fromARGB(255, 13, 177, 173),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                5), // Set the border radius here
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('EDIT'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
  // stream to get the profile data
  Stream<QuerySnapshot> profileDetails(FirebaseAuth _auth) {
    return ProfileDatabaseMethods()
        .getProfileStreamByData('user', _auth.currentUser!.uid);
  }
  // stream to get the health data
  Stream<QuerySnapshot> HealthDetails(FirebaseAuth _auth) {
    return HealthDatabaseMethods()
        .getHealthStreamByData('user', _auth.currentUser!.uid);
  }
}
