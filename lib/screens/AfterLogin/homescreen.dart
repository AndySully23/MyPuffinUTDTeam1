// Import necessary packages and modules
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:futurefit/screens/AfterLogin/widgets/home/home.dart';
import 'package:futurefit/screens/AfterLogin/widgets/notifications/notifications.dart';
import 'package:futurefit/screens/AfterLogin/widgets/profile/profile.dart';
import 'package:futurefit/screens/AfterLogin/widgets/settings/settings.dart';
import 'package:futurefit/screens/AfterLogin/widgets/support/support.dart';
import 'package:futurefit/screens/BeforeLogin/login.dart';

// Define a global key for the HomeScreen widget for potential use in other parts of the app
final homeScreenKey = GlobalKey<_HomeScreenState>();

// Define the HomeScreen widget
class HomeScreen extends StatefulWidget {
  final User user;
  HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Define the state for the HomeScreen widget
class _HomeScreenState extends State<HomeScreen> {
  int current_Index = 0;
  bool isExpanded = false; // to toggle AppBar expansion

  // Define the list of screens to be displayed in the bottom navigation
  List<Widget> bottom_screens = [
    const Home(),
    NotificationScreen(),
    const Support(
        receiverEmail: 'consultancy@gmail.com',
        receiverID: 'oc7mZuocEIYogTUDvG6P'),
    Settings()
  ];

  // Define the names of the screens
  List<String> screen_names = ['My Puffin™', 'Alerts', 'Support', 'Settings'];

  // Function to change the current tab index
  void changeTabIndex(int index) {
    setState(() {
      current_Index = index;
      isExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;
    final profileImage =
        'https://firebasestorage.googleapis.com/v0/b/fir-project-28009.appspot.com/o/profile_images%2F${user!.uid}.jpg?alt=media&token=162cbe68-2a07-4ec6-bcc8-03570f311e58&_gl=1*124nrjb*_ga*MTMxODE2NzM0Ny4xNjkxNTk4NTUx*_ga_CW55HF8NVT*MTY5NjIyNDc0NS45NC4xLjE2OTYyMjUwMDcuNTIuMC4w';

    return user == null
        ? LoginScreen()
        : Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(isExpanded ? 200.0 : 60.0),
              child: AppBar(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                title: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
                  child: Row(
                    children: [
                      Text(
                        screen_names[current_Index],
                        style: const TextStyle(
                            color: Color.fromARGB(255, 13, 177, 173),
                            fontSize: 28,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isExpanded = !isExpanded; // toggle AppBar expansion
                        });
                      },
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(profileImage ??
                            'https://i.pngimg.me/thumb/f/720/1d714a7743.jpg'),
                        backgroundColor: Color.fromARGB(127, 131, 181, 221),
                      ),
                    ),
                  ),
                ],
                bottom: isExpanded
                    ? PreferredSize(
                        preferredSize: const Size.fromHeight(120.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: Icon(Icons.account_circle),
                              title: Text('Profile'),
                              onTap: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return Profile();
                                }));
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.exit_to_app),
                              title: Text('Logout'),
                              onTap: () async {
                                await FirebaseAuth.instance.signOut();
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()),
                                  (Route<dynamic> route) =>
                                      false, // this ensures all previous routes are removed
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    : null,
              ),
            ),
            body: bottom_screens[current_Index],
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: current_Index,
              onTap: (int index) {
                setState(() {
                  current_Index = index;
                  isExpanded = false;
                });
              },
              selectedItemColor: const Color.fromARGB(199, 13, 177, 174),
              unselectedItemColor: const Color.fromARGB(199, 158, 158, 158),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home,
                    size: 35,
                  ),
                  activeIcon: Icon(
                    Icons.home_outlined,
                    size: 35,
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.notifications,
                      size: 35,
                    ),
                    activeIcon: Icon(
                      Icons.notifications_outlined,
                      size: 35,
                    ),
                    label: 'Alerts'),
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.support_agent,
                      size: 35,
                    ),
                    activeIcon: Icon(
                      Icons.support_agent,
                      size: 35,
                    ),
                    label: 'Support'),
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.settings,
                      size: 35,
                    ),
                    activeIcon: Icon(
                      Icons.settings_outlined,
                      size: 35,
                    ),
                    label: 'Settings')
              ],
            ),
          );
  }

  @override
  void dispose() {
    isExpanded = false;
    super.dispose();
  }
}
