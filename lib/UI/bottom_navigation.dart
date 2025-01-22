import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../UI/Dashboard/HomeScreen%20.dart';
import '../constants.dart';
import '../strings.dart';
import 'Attendance/AttendanceScreen.dart';
import 'Attendance/demo.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Auth/login_screen.dart';
import 'Fees/FeesScreen.dart';
import 'Library/LibraryScreen.dart';
import 'Profile/ProfileScreen.dart';

class BottomNavBarScreen extends StatefulWidget {
  // final String token;

  const BottomNavBarScreen({super.key});
  @override
  _BottomNavBarScreenState createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<BottomNavBarScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic>? studentData;
  bool isLoading = true;

  // List of screens
  final List<Widget> _screens = [
    HomeScreen(),
    AttendanceScreen(),
    // AttendanceCalendar(),
    LibraryScreen(),
    FeesScreen(),
    ProfileScreen(),
  ];

  // List of titles corresponding to the screens
  final List<String> _titles = [
    AppStrings.homeLabel,
    AppStrings.attendanceLabel,
    AppStrings.libraryLabel,
    AppStrings.feesLabel,
    AppStrings.profileLabel,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  void initState() {
    super.initState();

    fetchStudentData();
  }
  Future<void> fetchStudentData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("Token: $token");

    if (token == null) {
      _showLoginDialog();
      return;
    }

    final response = await http.get(
      Uri.parse(ApiRoutes.getProfile),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        studentData = data['student'];
        isLoading = false;
        print(studentData);

      });
    } else {
      _showLoginDialog();
    }
  }

  void _showLoginDialog() {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Session Expired'),
        content: const Text('Please log in again to continue.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
  Widget _buildAppBar() {
    return Row(
      children: [

        Builder(
          builder: (context) => Padding(
            padding: EdgeInsets.all(0),
            child: GestureDetector(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
              child: SizedBox(
                height: 30,
                width: 30,
                child: Image.asset('assets/menu.png'),
              ),
            ),
          ), // Ensure Scaffold is in context
        ),


         SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome !',
              style: GoogleFonts.montserrat(
                textStyle: Theme.of(context).textTheme.displayLarge,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.normal,
                color: AppColors.textwhite,
              ),
            ),
            Text(
              studentData?['student_name'] ?? 'Student', // Fallback to 'Student' if null
              style: GoogleFonts.montserrat(
                textStyle: Theme.of(context).textTheme.displayLarge,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.normal,
                color: AppColors.textwhite,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      drawerEnableOpenDragGesture: false,



      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(
          color: AppColors.textwhite
        ),
        title: Column(
          children: [
            _buildAppBar(),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: GestureDetector(
                onTap: () {},
                child: Icon(
                  Icons.notification_add,
                  size: 26,
                  color: Colors.white,
                )),
          )

          // Container(child: Icon(Icons.ice_skating)),
        ],
      ),
      body: _screens[_selectedIndex], // Display the selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: AppColors.primary,
        selectedItemColor: AppColors.textwhite,
        unselectedItemColor: AppColors.grey,
        items:  <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: AppStrings.homeLabel,
            backgroundColor: AppColors.primary,
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.clock),
            label: AppStrings.attendanceLabel,
            backgroundColor: AppColors.primary,
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.book_fill),
            label: AppStrings.libraryLabel,
            backgroundColor: AppColors.primary,
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.money_dollar),
            label: AppStrings.feesLabel,
            backgroundColor: AppColors.primary,
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_alt_circle_fill),
            label: AppStrings.profileLabel,
            backgroundColor: AppColors.primary,
          ),
        ],
      ),
      drawer: Drawer(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        width: MediaQuery.sizeOf(context).width * .65,
        // backgroundColor: Theme.of(context).colorScheme.background,
        backgroundColor: AppColors.primary,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 70,
              ),

              CircleAvatar(
                radius: 40,
                backgroundImage: studentData != null && studentData?['photo'] != null
                    ? NetworkImage(studentData?['photo'])
                    : null,
                child: studentData == null || studentData?['photo'] == null
                    ? Image.asset(AppAssets.logo, fit: BoxFit.cover)
                    : null,
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  child: Padding(
                    padding: EdgeInsets.only(top: 0, bottom: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        studentData?['student_name'] ?? 'Student', // Fallback to 'Student' if null
                        style: GoogleFonts.montserrat(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.normal,
                          color: AppColors.textwhite,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Divider(
                color: Colors.grey.shade300,
                // Set the color of the divider
                thickness: 2.0,
                // Set the thickness of the divider
                height: 1, // Set the height of the divider
              ),

              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          ListTile(
                            title: Text(
                              'Video Gallery',
                              style: GoogleFonts.cabin(
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                            trailing: Container(
                              height: 20,
                              width: 20,
                              color: AppColors.primary,
                              child:  Image.asset(
                                'assets/gallery_video.png',
                                height: 80, // Adjust the size as needed
                                width: 80,
                              ),

                            ),
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) {
                              //       return DownloadPdf();
                              //     },
                              //   ),
                              // );
                            },
                          ),
                          Padding(
                            padding:
                            EdgeInsets.only(left: 8, right: 8),
                            child: Divider(
                              height: 1,
                              color: Colors.grey.shade300,
                              thickness: 1,
                            ),
                          ),

                          ListTile(
                            title: Text(
                              'Gallery',
                              style: GoogleFonts.cabin(
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                            trailing: Container(
                              height: 20,
                              width: 20,
                              color: AppColors.primary,
                              child:  Image.asset(
                                'assets/gallery.png',
                                height: 80, // Adjust the size as needed
                                width: 80,
                              ),

                            ),
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) {
                              //       return DownloadPdf();
                              //     },
                              //   ),
                              // );
                            },
                          ),
                          Padding(
                            padding:
                            EdgeInsets.only(left: 8, right: 8),
                            child: Divider(
                              height: 1,
                              color: Colors.grey.shade300,
                              thickness: 1,
                            ),
                          ),


                          ListTile(
                            title: Text(
                              'Notices',
                              style: GoogleFonts.cabin(
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                            trailing: Container(
                              height: 20,
                              width: 20,
                              color: AppColors.primary,
                              child:  Image.asset(
                                'assets/document.png',
                                height: 80, // Adjust the size as needed
                                width: 80,
                              ),

                            ),
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) {
                              //       return DownloadPdf();
                              //     },
                              //   ),
                              // );
                            },
                          ),
                          Padding(
                            padding:
                            EdgeInsets.only(left: 8, right: 8),
                            child: Divider(
                              height: 1,
                              color: Colors.grey.shade300,
                              thickness: 1,
                            ),
                          ),


                          ListTile(
                            title: Text(
                              'News & Events',
                              style: GoogleFonts.cabin(
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                            trailing: Container(
                              height: 20,
                              width: 20,
                              color: AppColors.primary,
                              child:  Image.asset(
                                'assets/event_planner.png',
                                height: 80, // Adjust the size as needed
                                width: 80,
                              ),

                            ),
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) {
                              //       return DownloadPdf();
                              //     },
                              //   ),
                              // );
                            },
                          ),
                          Padding(
                            padding:
                            EdgeInsets.only(left: 8, right: 8),
                            child: Divider(
                              height: 1,
                              color: Colors.grey.shade300,
                              thickness: 1,
                            ),
                          ),


                          ListTile(
                            title: Text(
                              'Time Table',
                              style: GoogleFonts.cabin(
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                            trailing: Container(
                              height: 20,
                              width: 20,
                              color: AppColors.primary,
                              child:  Image.asset(
                                'assets/watch.png',
                                height: 80, // Adjust the size as needed
                                width: 80,
                              ),

                            ),
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) {
                              //       return DownloadPdf();
                              //     },
                              //   ),
                              // );
                            },
                          ),
                          Padding(
                            padding:
                            EdgeInsets.only(left: 8, right: 8),
                            child: Divider(
                              height: 1,
                              color: Colors.grey.shade300,
                              thickness: 1,
                            ),
                          ),


                          ListTile(
                            title: Text(
                              'Download',
                              style: GoogleFonts.cabin(
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                            trailing: Container(
                                height: 20,
                                width: 20,
                                color: AppColors.primary,
                                child: Icon(
                                  Icons.download,
                                  color: Colors.white,
                                )),
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) {
                              //       return DownloadPdf();
                              //     },
                              //   ),
                              // );
                            },
                          ),
                          Padding(
                            padding:
                            EdgeInsets.only(left: 8, right: 8),
                            child: Divider(
                              height: 1,
                              color: Colors.grey.shade300,
                              thickness: 1,
                            ),
                          ),


                          ListTile(
                            title: Text(
                              'Assignments',
                              style: GoogleFonts.cabin(
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                            trailing: Container(
                                height: 20,
                                width: 20,
                                color: AppColors.primary,
                                child:  Image.asset(
                                  'assets/assignments.png',
                                  height: 80, // Adjust the size as needed
                                  width: 80,
                                ),

                            ),
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) {
                              //       return DownloadPdf();
                              //     },
                              //   ),
                              // );
                            },
                          ),
                          Padding(
                            padding:
                            EdgeInsets.only(left: 8, right: 8),
                            child: Divider(
                              height: 1,
                              color: Colors.grey.shade300,
                              thickness: 1,
                            ),
                          ),

                          Padding(
                            padding:
                            EdgeInsets.only(left: 8, right: 8),
                            child: Divider(
                              height: 1,
                              color: Colors.grey.shade300,
                              thickness: 1,
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'Share App',
                              style: GoogleFonts.cabin(
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                            trailing: Container(
                                height: 20,
                                width: 20,
                                child: Icon(
                                  Icons.share,
                                  color: Colors.white,
                                )),
                            onTap: () {

                              Navigator.pop(context);
                            },
                          ),
                          Padding(
                            padding:
                            EdgeInsets.only(left: 8, right: 8),
                            child: Divider(
                              height: 1,
                              color: Colors.grey.shade300,
                              thickness: 1,
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'Help',
                              style: GoogleFonts.cabin(
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                            trailing: Container(
                                height: 25,
                                width: 25,
                                child: Image.asset('assets/help.png',
                                  color: Colors.white,
                                )),
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) {
                              //       return HelpScreen(appBar: 'Help',);
                              //     },
                              //   ),
                              // );

                            },
                          ),
                          Padding(
                            padding:
                            EdgeInsets.only(left: 8, right: 8),
                            child: Divider(
                              height: 1,
                              color: Colors.grey.shade300,
                              thickness: 1,
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'FAQs',
                              style: GoogleFonts.cabin(
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                            trailing: Container(
                                height: 20,
                                width: 20,
                                child: Image.asset('assets/faq.png')),
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) {
                              //       return FaqScreen(appBar: 'FAQ',);
                              //     },
                              //   ),
                              // );
                            },
                          ),
                          Padding(
                            padding:
                            EdgeInsets.only(left: 8, right: 8),
                            child: Divider(
                              height: 1,
                              color: Colors.grey.shade300,
                              thickness: 1,
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'Privacy',
                              style: GoogleFonts.cabin(
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                            trailing: Container(
                                height: 20,
                                width: 20,
                                child: Icon(
                                  Icons.privacy_tip,
                                  color: Colors.white,
                                )),
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) {
                              //       return WebViewExample(
                              //         title: 'Privacy',
                              //         url:
                              //         'https://ksadmission.in/privacy-policy',
                              //       );
                              //     },
                              //   ),
                              // );
                            },
                          ),
                          Padding(
                            padding:
                            EdgeInsets.only(left: 8, right: 8),
                            child: Divider(
                              height: 1,
                              color: Colors.grey.shade300,
                              thickness: 1,
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'Terms & Condition',
                              style: GoogleFonts.cabin(
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                            trailing: Container(
                                height: 20,
                                width: 20,
                                child: Icon(
                                  Icons.event_note_outlined,
                                  color: Colors.white,
                                )),
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) {
                              //       return WebViewExample(
                              //         title: 'Terms & Condition',
                              //         url:
                              //         'https://ksadmission.in/privacy-policy',
                              //       );
                              //     },
                              //   ),
                              // );
                            },
                          ),



                          Padding(
                            padding:
                            EdgeInsets.only(left: 8, right: 8),
                            child: Divider(
                              height: 1,
                              color: Colors.grey.shade300,
                              thickness: 1,
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'Logout',
                              style: GoogleFonts.cabin(
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                            trailing: Container(
                                height: 20,
                                width: 20,
                                child: Icon(
                                  Icons.logout,
                                  color: Colors.white,
                                )),
                            onTap: () async {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.clear(); // Clear the stored token
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginPage()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 15),
                    ),
                  ],
                ),
              )

            ],
          ),
        ),
      ),

    );
  }
}

