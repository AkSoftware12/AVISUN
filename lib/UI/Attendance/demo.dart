// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../constants.dart';
// import 'package:intl/intl.dart'; // To format the date
//
// // Define your models and fetchAttendance function here
// class AttendanceRecord {
//   final String date;
//   final List<SubjectRecord> records;
//
//   AttendanceRecord({required this.date, required this.records});
//
//   factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
//     var list = json['records'] as List;
//     List<SubjectRecord> recordsList =
//     list.map((i) => SubjectRecord.fromJson(i)).toList();
//
//     return AttendanceRecord(
//       date: json['date'],
//       records: recordsList,
//     );
//   }
// }
//
// class SubjectRecord {
//   final String subject;
//   final int status;
//   final String note;
//
//   SubjectRecord({required this.subject, required this.status, required this.note});
//
//   factory SubjectRecord.fromJson(Map<String, dynamic> json) {
//     return SubjectRecord(
//       subject: json['subject'],
//       status: json['status'],
//       note: json['note'],
//     );
//   }
// }
//
// class AttendanceScreen extends StatefulWidget {
//   const AttendanceScreen({super.key});
//
//   @override
//   State<AttendanceScreen> createState() => _AttendanceScreenState();
// }
//
// class _AttendanceScreenState extends State<AttendanceScreen> {
//   int selectedYear = DateTime.now().year;
//   int selectedMonth = DateTime.now().month; // Default to current month
//
//   @override
//   void initState() {
//     super.initState();
//     fetchAttendanceRecords('01','2025');
//   }
//
//   Future<List<AttendanceRecord>> fetchAttendanceRecords(String month, String year) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('token');
//
//     final response = await http.get(
//       Uri.parse('${ApiRoutes.attendance}?month=$month&year=$year'),
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//     );
//
//
//     if (response.statusCode == 200) {
//       Map<String, dynamic> data = json.decode(response.body);
//       List<dynamic> records = data['data'];
//       return records.map((record) => AttendanceRecord.fromJson(record)).toList();
//
//     } else {
//       throw Exception('Failed to load attendance records');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(0.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildAppBar('Attendance ${selectedYear} ${selectedMonth}'),
//           Container(
//             height: 200,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: 12, // Number of months in a year
//               itemBuilder: (context, monthIndex) {
//                 DateTime firstDayOfMonth = DateTime(DateTime.now().year, monthIndex + 1, 1);
//                 String monthName = DateFormat('MMMM').format(firstDayOfMonth);
//
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                   child: Column(
//                     children: [
//                       Container(
//                         padding: EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: Colors.blue,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Text(
//                           monthName,
//                           style: TextStyle(color: Colors.white, fontSize: 16),
//                         ),
//                       ),
//                       SizedBox(height: 10),
//                       // Container(
//                       //   height: 100,
//                       //   child: ListView.builder(
//                       //     shrinkWrap: true,
//                       //     scrollDirection: Axis.horizontal,
//                       //     itemCount: DateTime(DateTime.now().year, monthIndex + 1 + 1, 0).day, // Get the number of days in the current month
//                       //     itemBuilder: (context, dayIndex) {
//                       //       DateTime currentDate = DateTime(DateTime.now().year, monthIndex + 1, dayIndex + 1);
//                       //       String formattedDate = DateFormat('dd MMM').format(currentDate);
//                       //       bool isToday = currentDate.isAtSameMomentAs(DateTime.now().toLocal());
//                       //
//                       //       return Padding(
//                       //         padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                       //         child: Column(
//                       //           children: [
//                       //             Container(
//                       //               width: 60,
//                       //               height: 60,
//                       //               decoration: BoxDecoration(
//                       //                 color: isToday ? Colors.blue : Colors.grey,
//                       //                 borderRadius: BorderRadius.circular(10),
//                       //               ),
//                       //               child: Center(
//                       //                 child: Text(
//                       //                   formattedDate,
//                       //                   style: TextStyle(color: Colors.white, fontSize: 16),
//                       //                 ),
//                       //               ),
//                       //             ),
//                       //             SizedBox(height: 5),
//                       //             Text(
//                       //               DateFormat('EEEE').format(currentDate), // Day of the week
//                       //               style: TextStyle(fontSize: 12),
//                       //             ),
//                       //           ],
//                       //         ),
//                       //       );
//                       //     },
//                       //   ),
//                       // ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//             FutureBuilder<List<AttendanceRecord>>(
//               future: fetchAttendanceRecords('${selectedYear} ', '${selectedMonth}'),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return Center(child: Text('No attendance records found.'));
//                 } else {
//                   List<AttendanceRecord> records = snapshot.data!;
//                   return ListView.builder(
//                     shrinkWrap: true, // Added to fix unbounded height error
//                     itemCount: records.length,
//                     itemBuilder: (context, index) {
//                       AttendanceRecord record = records[index];
//                       return ExpansionTile(
//                         title: Text(record.date),
//                         children: record.records.map((subjectRecord) {
//                           return ListTile(
//                             title: Text(subjectRecord.subject),
//                             subtitle: Text('Status: ${subjectRecord.status}, Note: ${subjectRecord.note}'),
//                           );
//                         }).toList(),
//                       );
//                     },
//                   );
//                 }
//               },
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAppBar(String title) {
//     return Container(
//       height: 80,
//       width: double.infinity,
//       color: AppColors.secondary,
//       child: Center(
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Align(
//               alignment: Alignment.bottomLeft,
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   title,
//                   style: GoogleFonts.montserrat(
//                     textStyle: Theme.of(context).textTheme.displayLarge,
//                     fontSize: 21,
//                     fontWeight: FontWeight.w800,
//                     fontStyle: FontStyle.normal,
//                     color: AppColors.textwhite,
//                   ),
//                 ),
//               ),
//             ),
//             Align(
//               alignment: Alignment.bottomRight,
//               child: Padding(
//                 padding: const EdgeInsets.all(0.0),
//                 child: Row(
//                   children: [
//                     // Year Dropdown
//                     Container(
//                       height: 30,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         color: Colors.white
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.only(left: 8.0,right: 8),
//                         child: DropdownButton<int>(
//                           value: selectedYear,
//                           onChanged: (int? newYear) {
//                             setState(() {
//                               selectedYear = newYear!;
//                             });
//                           },
//                           items: List.generate(10, (index) {
//                             int year = DateTime.now().year - 5 + index; // Show 10 years range
//                             return DropdownMenuItem<int>(
//                               value: year,
//                               child: Text(year.toString()),
//                             );
//                           }),
//                           underline: SizedBox.shrink(), // Removes the bottom outline
//                         ),
//                       ),
//                     ),
//
//                     SizedBox(width: 10), // To add space between year and month dropdown
//
//                     // Month Dropdown
//                     Container(
//                       height: 30,
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                           color: Colors.white
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.only(left: 8.0,right: 8),
//                         child:   DropdownButton<int>(
//                           value: selectedMonth,
//                           onChanged: (int? newMonth) {
//                             setState(() {
//                               selectedMonth = newMonth!;
//                             });
//                           },
//                           items: List.generate(12, (index) {
//                             int month = index + 1; // Months from 1 to 12
//                             // Abbreviated month names (Jan, Feb, etc.)
//                             List<String> monthNames = [
//                               'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//                               'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
//                             ];
//                             return DropdownMenuItem<int>(
//                               value: month,
//                               child: Text(monthNames[month - 1]), // Display the abbreviated month name
//                             );
//                           }),
//                           underline: SizedBox.shrink(), // Removes the bottom outline
//                         ),
//
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             )
//
//
//           ],
//         ),
//       ),
//     );
//   }
//
// }
//
//
