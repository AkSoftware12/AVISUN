import 'dart:convert';
import 'package:avi/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        automaticallyImplyLeading: false,
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
                } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!['data'] == null || snapshot.data!['data']['attendance'] == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/no_attendance.png', filterQuality: FilterQuality.high),
                        SizedBox(height: 10),
                        Text(
                          'Attendance Not Available.',
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textblack,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  final data = snapshot.data!;
                  final processedData = processAttendanceData(data['data']['attendance']);
                  return _buildDataTable(processedData);
                }
              },
            ),

          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> processAttendanceData(Map<String, dynamic> attendanceData) {
    int daysInMonth = DateTime(selectedYear, selectedMonth + 1, 0).day; // Get total days in month
    Set<String> uniqueDates = Set.from(
      List.generate(daysInMonth, (index) {
        DateTime date = DateTime(selectedYear, selectedMonth, index + 1);
        return DateFormat('yyyy-MM-dd').format(date); // Format as "YYYY-MM-DD"
      }),
    );

    Map<String, String> dailyAttendanceMap = {}; // Store daily attendance

    // Extract attendance records correctly
    attendanceData.forEach((date, entry) {
      if (date.startsWith('$selectedYear-${selectedMonth.toString().padLeft(2, '0')}')) {
        int status = entry['status']; // Extract status
        dailyAttendanceMap[date] = getStatusSymbol(status); // Convert status to symbol
      }
    });

    dates = uniqueDates.toList()..sort(); // Sort formatted dates

    return [
      {
        'subject': 'Attendance',
        'dailyRecords': dailyAttendanceMap,
      }
    ];
  }

  Widget _buildDataTable(List<Map<String, dynamic>> attendanceData) {
    int totalPresent = 0;
    int totalAbsent = 0;
    int totalLeave = 0;
    int totalHoliday = 0;
    int totalDays = 0;

    // **Loop through attendance records and count the totals**
    for (var date in dates) {
      String status = attendanceData[0]['dailyRecords'][date] ?? '-';
      switch (status) {
        case 'P': totalPresent++; break;
        case 'A': totalAbsent++; break;
        case 'L': totalLeave++; break;
        case 'H': totalHoliday++; break;
      }
      if (status != 'H') totalDays++; // Count only working days
    }

    // **Calculate Percentage**
    double attendancePercentage = totalDays == 0 ? 0 : (totalPresent / totalDays) * 100;

    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue.shade100),
          border: TableBorder.all(color: Colors.grey.shade300),
          columns: [
            DataColumn(label: Text("Date", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Attendance", style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: [
            // **Attendance Records**
            ...dates.map((date) {
              String status = attendanceData[0]['dailyRecords'][date] ?? '-';
              return DataRow(
                cells: [
                  DataCell(Text(date, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,color: Colors.white))),
                  DataCell(
                    Center(
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(status),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),

            // **Summary Rows**
            _buildSummaryRow("Total Present", totalPresent.toString(), Colors.green),
            _buildSummaryRow("Total Absent", totalAbsent.toString(), Colors.red),
            _buildSummaryRow("Total Leave", totalLeave.toString(), Colors.blue),
            _buildSummaryRow("Total Holiday", totalHoliday.toString(), Colors.orange),
            _buildSummaryRow("Total Attendance %", "${attendancePercentage.toStringAsFixed(2)}%", Colors.purple),
          ],
        ),
      ),
    );
  }

  /// **Builds the summary row with text and color**
  DataRow _buildSummaryRow(String title, String value, Color color) {
    return DataRow(
      cells: [
        DataCell(Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14,color: Colors.white))),
        DataCell(
          Center(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ),
      ],
    );
  }

  /// **Convert status symbol to color**
  Color _getStatusColor(String status) {
    switch (status) {
      case 'P': return Colors.green;
      case 'A': return Colors.red;
      case 'L': return Colors.blue;
      case 'H': return Colors.orange;
      default: return Colors.black;
    }
  }

  /// **Convert status integer to symbol**
  String getStatusSymbol(int status) {
    switch (status) {
      case 1: return 'P'; // Present
      case 2: return 'A'; // Absent
      case 3: return 'L'; // Leave
      case 4: return 'H'; // Holiday
      default: return '-';
    }
  }



}





