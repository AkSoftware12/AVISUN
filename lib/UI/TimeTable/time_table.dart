import 'dart:convert';

import 'package:avi/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Auth/login_screen.dart';

class TimeTableScreen extends StatefulWidget {
  const TimeTableScreen({super.key});

  @override
  State<TimeTableScreen> createState() => _TimeTableScreenState();
}

class _TimeTableScreenState extends State<TimeTableScreen> {

  bool isLoading = true;
  List timeTable = []; // Declare a list to hold API data


  @override
  void initState() {
    super.initState();

    DateTime.now().subtract(const Duration(days: 30));

    fetchAssignmentsData();
  }


  Future<void> fetchAssignmentsData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("Token: $token");

    if (token == null) {
      _showLoginDialog();
      return;
    }

    final response = await http.get(
      Uri.parse(ApiRoutes.getTimeTable),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      setState(() {
        timeTable = jsonResponse['data']; // Update state with fetched data
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
  // Sample timetable data
  // final List<Map<String, dynamic>> timeTable = [
  //   {"day": "Monday", "subject": "Mathematics", "time": "9:00 AM - 10:00 AM"},
  //   {"day": "Monday", "subject": "Science", "time": "10:15 AM - 11:15 AM"},
  //   {"day": "Monday", "subject": "English", "time": "11:30 AM - 12:30 PM"},
  //   {"day": "Tuesday", "subject": "History", "time": "9:00 AM - 10:00 AM"},
  //   {"day": "Tuesday", "subject": "Geography", "time": "10:15 AM - 11:15 AM"},
  //   {"day": "Tuesday", "subject": "Physics", "time": "11:30 AM - 12:30 PM"},
  //   {"day": "Wednesday", "subject": "Chemistry", "time": "9:00 AM - 10:00 AM"},
  //   {"day": "Wednesday", "subject": "Biology", "time": "10:15 AM - 11:15 AM"},
  //   {"day": "Wednesday", "subject": "Physical Education", "time": "11:30 AM - 12:30 PM"},
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: Text(
          'Time Table',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
      ),
      body:timeTable.isNotEmpty?

      Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: timeTable.length,
          itemBuilder: (context, index) {
            final schedule = timeTable[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(
                  schedule['subject_name'],
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.watch_later_outlined,size: 18,color: Colors.grey.shade800,),
                        Text(
                          " ${schedule['start_time']} - ${schedule['end_time']}",
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3,),

                    Row(
                      children: [

                        SizedBox(
                            height: 18,
                            width: 18,
                            child: Image.asset('assets/teacher.png',color: Colors.black,)),
                        Text(
                          " ${schedule['teacher_name']}",
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade800,
                          ),
                        ),



                        Text(
                          "   Room No . ${schedule['room_name']}   ",
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade800,
                          ),
                        ),

                      ],
                    ),
                  ],
                ),
                leading: Icon(
                  Icons.book,size:40,
                  color: Colors.blueAccent,
                ),
              ),
            );
          },
        ),
      ):
      Container(
          height: MediaQuery.of(context).size.height * 0.7, // 90% of screen height

          child: Center(
              child:
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Image.asset('assets/no_attendance.png',filterQuality: FilterQuality.high,),
                  Text('Time Table  Not Available.',
                    style: GoogleFonts.montserrat(
                      textStyle: Theme.of(context).textTheme.displayLarge,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.normal,
                      color: AppColors.textwhite,
                    ),

                  )
                ],
              )
          )
      ),
    );
  }
}

