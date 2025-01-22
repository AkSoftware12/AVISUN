import 'dart:convert';
import 'package:avi/HexColorCode/HexColor.dart';
import 'package:avi/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceTableScreenState createState() => _AttendanceTableScreenState();
}

class _AttendanceTableScreenState extends State<AttendanceScreen> {
  late Future<Map<String, dynamic>> _attendanceFuture;
  List<String> dates = [];
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    _attendanceFuture = fetchAttendance(selectedMonth, selectedYear);
  }

  Future<Map<String, dynamic>> fetchAttendance(int month, int year) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${ApiRoutes.attendance}?month=$month&year=$year'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching attendance: $e');
      throw Exception('Error fetching attendance');
    }
  }

  Widget _buildAppBar(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: GoogleFonts.montserrat(
                textStyle: Theme.of(context).textTheme.displayLarge,
                fontSize: 21,
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.normal,
                color: AppColors.textwhite,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Year Dropdown

                // Month Dropdown
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: DropdownButton<int>(
                      value: selectedMonth,
                      onChanged: (int? newMonth) {
                        setState(() {
                          selectedMonth = newMonth!;
                          _attendanceFuture = fetchAttendance(selectedMonth, selectedYear);
                        });
                      },
                      items: List.generate(12, (index) {
                        int month = index + 1; // Months from 1 to 12
                        // Abbreviated month names (Jan, Feb, etc.)
                        List<String> monthNames = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                          'Aug',
                          'Sep',
                          'Oct',
                          'Nov',
                          'Dec'
                        ];
                        return DropdownMenuItem<int>(
                          value: month,
                          child: Text(monthNames[month -
                              1]), // Display the abbreviated month name
                        );
                      }),
                      underline:
                      SizedBox.shrink(), // Removes the bottom outline
                    ),
                  ),
                ),
                SizedBox(width: 10),
                // To add space between year and month dropdown

                Container(
                  height: 30,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: DropdownButton<int>(
                      value: selectedYear,
                      onChanged: (int? newYear) {
                        setState(() {
                          selectedYear = newYear!;
                          _attendanceFuture = fetchAttendance(selectedMonth, selectedYear);
                        });
                      },
                      items: List.generate(10, (index) {
                        int year = DateTime.now().year -
                            5 +
                            index; // Show 10 years range
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }),
                      underline:
                      SizedBox.shrink(), // Removes the bottom outline
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title:  _buildAppBar('Attendance'),

      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // _buildAppBar('Attendance $selectedYear $selectedMonth'),
            FutureBuilder<Map<String, dynamic>>(
              future: _attendanceFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data!['data']['attendance'].isEmpty) {
                  // If attendance data is empty
                  return Container(
                      height: MediaQuery.of(context).size.height * 0.7, // 90% of screen height

                      child: Center(
                          child:
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                                  Image.asset('assets/no_attendance.png',filterQuality: FilterQuality.high,),
                              Text('Attendance  Not Available.',
                                style: GoogleFonts.montserrat(
                                  textStyle: Theme.of(context).textTheme.displayLarge,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  fontStyle: FontStyle.normal,
                                  color: AppColors.textblack,
                                ),

                              )
                            ],
                          )
                      )
                  );
                } else {
                  final data = snapshot.data!;
                  final processedData =
                  processAttendanceData(data['data']['attendance']);
                  return _buildDataTable(processedData);
                }
              },
            ),

          ],
        ),
      ),
    );
  }


  List<Map<String, dynamic>> processAttendanceData(List<dynamic> data) {
    int daysInMonth = DateTime(selectedYear, selectedMonth + 1, 0).day; // Get the number of days in the selected month
    Set<String> uniqueDates = Set.from(
        List.generate(daysInMonth, (index) => (index + 1).toString().padLeft(2, '0'))
    );
    Map<String, Map<String, String>> subjectAttendanceMap = {};

    for (var entry in data) {
      String date = entry['date'].split('-').last;
      uniqueDates.add(date);

      for (var record in entry['records']) {
        String subject = record['subject'];
        if (!subjectAttendanceMap.containsKey(subject)) {
          subjectAttendanceMap[subject] = {};
        }
        subjectAttendanceMap[subject]![date] = getStatusSymbol(record['status']);
      }
    }

    dates = uniqueDates.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    return subjectAttendanceMap.entries
        .map((entry) => {'subject': entry.key, 'dailyRecords': entry.value})
        .toList();
  }

  String getStatusSymbol(int status) {
    switch (status) {
      case 1:
        return 'P';
      case 2:
        return 'A';
      case 3:
        return 'L';
      case 4:
        return 'H';
      default:
        return '';
    }
  }

  Widget _buildDataTable(List<Map<String, dynamic>> attendanceData) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: DataTable(
        columnSpacing: 0,
        horizontalMargin: 0,
        dataRowHeight: 25,
        headingRowHeight: 30,
        border: TableBorder.all(width: 0.5),
        columns: [
          DataColumn(
            label: Container(
              color: Colors.cyan,
              width: 80,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 5.0,right: 5),
                  child: Text(
                    "Date/Subject",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
          ),
          ...attendanceData.map((subjectData) => DataColumn(
            label: Container(
              color: Colors.cyan,

              child:Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      subjectData['subject'],
                      maxLines: 2,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
        rows: [
          ...dates.map((date) {
            return DataRow(
              cells: [
                DataCell(
                  Container(
                    color: Colors.cyan,
                    child: Center(
                      child: Text(
                        date,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ),
                ...attendanceData.map((subjectData) {
                  String status = subjectData['dailyRecords'][date] ?? '';
                  Color statusColor;

                  switch (status) {
                    case 'A':
                      statusColor = Colors.red;
                      break;
                    case 'P':
                      statusColor = Colors.green;
                      break;
                    case 'L':
                      statusColor = Colors.blue;
                      break;
                    case 'H':
                      statusColor = Colors.orange;
                      break;
                    default:
                      statusColor = Colors.black;
                  }

                  return DataCell(
                    Center(
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          }).toList(),
          // Add summary rows here

          DataRow(cells: [
            DataCell(
                Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 5.0,right: 5),
                child: Container(
                  width: 70,
                  child: Text(
                    "Total Present",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 12),
                  ),
                ),
              ),
            )),
            ...attendanceData.map((subjectData) {
              int presentCount = subjectData['dailyRecords']
                  .values
                  .where((s) => s == 'P')
                  .length;
              return DataCell(Center(
                child: Text(
                  presentCount.toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 12),
                ),
              ));
            }),
          ]),
          DataRow(cells: [
            DataCell(Center(
              child: Container(
                width: 70,
                child: Text(
                  "Total Absent",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                      fontSize: 12),
                ),
              ),
            )),
            ...attendanceData.map((subjectData) {
              int absentCount = subjectData['dailyRecords']
                  .values
                  .where((s) => s == 'A')
                  .length;
              return DataCell(Center(
                child: Text(
                  absentCount.toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                      fontSize: 12),
                ),
              ));
            }),
          ]),
          DataRow(cells: [
            DataCell(Center(
              child: Container(
                width: 70,
                child: Text(
                  "Total Leave",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 12),
                ),
              ),
            )),
            ...attendanceData.map((subjectData) {
              int leaveCount = subjectData['dailyRecords']
                  .values
                  .where((s) => s == 'L')
                  .length;
              return DataCell(Center(
                child: Text(
                  leaveCount.toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 12),
                ),
              ));
            }),
          ]),
          DataRow(cells: [
            DataCell(Center(
              child: Container(
                width: 70,
                child: Text(
                  "Total Holiday",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontSize: 12),
                ),
              ),
            )),
            ...attendanceData.map((subjectData) {
              int holidayCount = subjectData['dailyRecords']
                  .values
                  .where((s) => s == 'H')
                  .length;
              return DataCell(Center(
                child: Text(
                  holidayCount.toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontSize: 12),
                ),
              ));
            }),
          ]),
          DataRow(cells: [
            DataCell(Center(
              child: Container(
                width: 70,
                child: Text(" Percentage",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12,color: AppColors.primary)),
              ),
            )),
            ...attendanceData.map((subjectData) {
              int presentCount = subjectData['dailyRecords']
                  .values
                  .where((s) => s == 'P')
                  .length;
              int totalDays = subjectData['dailyRecords']
                  .values
                  .where((s) => s != 'H')
                  .length;
              double percentage =
              totalDays == 0 ? 0 : (presentCount / totalDays) * 100;
              return DataCell(Center(
                child: Text("${percentage.toStringAsFixed(0)}%",
                    style: TextStyle(fontSize: 12,color: AppColors.primary)),
              ));
            }),
          ]),
        ],
      ),
    );
  }
}
