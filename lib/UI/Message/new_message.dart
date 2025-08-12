import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../CommonCalling/data_not_found.dart';
import '../../CommonCalling/progressbarWhite.dart';
import '../../constants.dart';
import 'chat.dart';

class NewMesssageScreen extends StatefulWidget {
  final int? messageSendPermissionsApp;
  const NewMesssageScreen({super.key, required this.messageSendPermissionsApp});

  @override
  State<NewMesssageScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<NewMesssageScreen> {
  bool isLoading = false;
  List messsage = []; // Declare a list to hold API data

  @override
  void initState() {
    super.initState();
    DateTime.now().subtract(const Duration(days: 30));
    fetchAssignmentsData();
  }

  Future<void> fetchAssignmentsData() async {
    setState(() {
      isLoading = true; // Show progress bar
    });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("Token: $token");

    if (token == null) {
      return;
    }

    final response = await http.get(
      Uri.parse(ApiRoutes.getAllMessages),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      setState(() {
        messsage = jsonResponse['users']; // Update state with fetched data
        isLoading = false; // Stop progress bar
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
          iconTheme: IconThemeData(color: AppColors.textwhite),
          backgroundColor: AppColors.secondary,
          title: Text(
            'New Messages',
            style: GoogleFonts.montserrat(
              textStyle: Theme.of(context).textTheme.displayLarge,
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.normal,
              color: AppColors.textwhite,
            ),
          )),

      body: isLoading
          ? WhiteCircularProgressWidget()
          : messsage.isEmpty
          ? Center(
          child: DataNotFoundWidget(
            title: 'chat  Not Available.',
          ))
          : ListView.builder(
        itemCount: messsage.length,
        itemBuilder: (context, index) {
          final assignment = messsage[index];


          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen(id:  assignment['id'],
                  messageSendPermissionsApp: widget.messageSendPermissionsApp,
                  name: assignment['first_name'], msgSendId: assignment['id'], designation: assignment['designation']['title'].toString(),
                )),
              );
            },
            child: Card(
              margin: EdgeInsets.symmetric(vertical: 3.sp, horizontal: 8.sp),
              elevation: 6,
              color: Colors.white, // Light background
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11.sp),
              ),
              child: Padding(
                padding: EdgeInsets.all(10.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// **Title & Index**
                    Row(
                      children: [
                        Container(
                          height: 35.sp,
                          width: 35.sp,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.chat, // Material chat icon
                              size: 20.sp, // Adjust size as needed
                              color: Colors.white, // Match original text color
                            ),
                          ),
                        ),
                        SizedBox(width: 10.sp),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${assignment['first_name'].toString().toUpperCase()}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 1),
                              Text(
                               '(${assignment['designation']['title'].toString().toUpperCase()})',
                                style: GoogleFonts.montserrat(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 1),


                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

}
