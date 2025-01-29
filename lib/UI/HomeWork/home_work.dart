import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../HexColorCode/HexColor.dart';
import '../../constants.dart';
import '../Auth/login_screen.dart';
import 'package:html/parser.dart' as html_parser;

class HomeWorkScreen extends StatefulWidget {
  @override
  State<HomeWorkScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<HomeWorkScreen> {
  bool isLoading = true;
  List assignments = []; // Declare a list to hold API data

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
      Uri.parse(ApiRoutes.getAssignments),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      setState(() {
        assignments = jsonResponse['data']; // Update state with fetched data
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
          iconTheme: IconThemeData(color: AppColors.textwhite),
          backgroundColor: AppColors.secondary,
          title: Text(
            'Home Work',
            style: GoogleFonts.montserrat(
              textStyle: Theme.of(context).textTheme.displayLarge,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.normal,
              color: AppColors.textwhite,
            ),
          )),
      body: assignments.isNotEmpty
          ? ListView.builder(
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                final assignment = assignments[index];
                String description =
                    html_parser.parse(assignment['description']).body?.text ??
                        '';
                String startDate = DateFormat('dd-MM-yyyy')
                    .format(DateTime.parse(assignment['start_date']));
                String endDate = DateFormat('dd-MM-yyyy')
                    .format(DateTime.parse(assignment['due_date']));

                return Card(
                  margin: EdgeInsets.all(5),
                  elevation: 4,
                  color: AppColors.secondary,
                  shadowColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: Colors.grey, // Border color
                      width: 1, // Border width
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      color: AppColors.textwhite,
                                      borderRadius: BorderRadius.circular(25)),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: GoogleFonts.montserrat(
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .displayLarge,
                                        fontSize: 25,
                                        fontWeight: FontWeight.w700,
                                        fontStyle: FontStyle.normal,
                                        color: AppColors.textblack,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      assignment['title']
                                          .toString()
                                          .toUpperCase(),
                                      style: GoogleFonts.montserrat(
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .displayLarge,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FontStyle.normal,
                                        color: AppColors.textwhite,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      child: Text(
                                        '${description}'.toUpperCase(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        // Add ellipsis for overflow
                                        style: GoogleFonts.montserrat(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .displayLarge,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FontStyle.normal,
                                          color: AppColors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Start : ${startDate}',
                                  style: GoogleFonts.montserrat(
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .displayLarge,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.normal,
                                    color: AppColors.textwhite,
                                  ),
                                ),
                                Text(
                                  'Due : ${endDate}',
                                  style: GoogleFonts.montserrat(
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .displayLarge,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.normal,
                                    color: AppColors.textwhite,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                                onTap: () async {
                                  if (await canLaunchUrl(Uri.parse(
                                      assignment['attach'].toString()))) {
                                    await launchUrl(Uri.parse(
                                        assignment['attach'].toString()));
                                  } else {
                                    throw 'Could not launch ${assignment['attach']}';
                                  }
                                },
                                child: Container(
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.white,
                                      // You can change the color as needed
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        'Assignment'.toUpperCase(),
                                        style: GoogleFonts.montserrat(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .displayLarge,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FontStyle.normal,
                                          color: AppColors.textwhite,
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                            GestureDetector(
                                onTap: () {},
                                child: Container(
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.white,
                                      // You can change the color as needed
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        'UPLOAD',
                                        style: GoogleFonts.montserrat(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .displayLarge,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FontStyle.normal,
                                          color: AppColors.textwhite,
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                            Center(
                                child: Container(
                              width: 100,
                              decoration: BoxDecoration(
                                color: assignment['attendance_status'] ==
                                        'submitted'
                                    ? Colors.green
                                    : HexColor('#780606'),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.textwhite,
                                  // You can change the color as needed
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    assignment['attendance_status']
                                        .toString()
                                        .toUpperCase(),
                                    style: GoogleFonts.montserrat(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displayLarge,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.normal,
                                      color: AppColors.textwhite,
                                    ),
                                  ),
                                ),
                              ),
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : Container(
              height: MediaQuery.of(context).size.height *
                  0.7, // 90% of screen height

              child: Center(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/no_attendance.png',
                    filterQuality: FilterQuality.high,
                  ),
                  Text(
                    'Home Work  Not Available.',
                    style: GoogleFonts.montserrat(
                      textStyle: Theme.of(context).textTheme.displayLarge,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.normal,
                      color: AppColors.textwhite,
                    ),
                  )
                ],
              ))),
    );
  }
}
