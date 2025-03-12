import 'dart:convert';
import 'package:avi/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../CommonCalling/progressbarWhite.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceTableScreenState createState() => _AttendanceTableScreenState();
}

class _AttendanceTableScreenState extends State<AttendanceScreen> {
  late Future<Map<String, dynamic>> _attendanceFuture;
  List<String> dates = [];
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  DateTime? startDate;
  DateTime? endDate;
  @override
  void initState() {
    super.initState();
    _attendanceFuture = fetchAttendance(selectedMonth.toString(),selectedYear.toString(),"","");
  }

  Future<Map<String, dynamic>> fetchAttendance(String month, String year, String startDate, String endDate) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${ApiRoutes.attendance}?month=$month&year=$year&start_date=$startDate&end_date=$endDate'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);


        // If the response is a List, convert it to a Map
        if (decodedResponse is List) {
          return {
            "data": {
              "attendance": decodedResponse // Convert list to map key
            }
        };

        } else if (decodedResponse is Map<String, dynamic>) {
          print(decodedResponse.toString());

          return decodedResponse;

        } else {
          throw Exception("Unexpected response format");
        }
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
                          startDate=null;
                          endDate=null;
                          selectedMonth = newMonth!;
                          _attendanceFuture = fetchAttendance(selectedMonth.toString(), selectedYear.toString(),'','');
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
                          startDate=null;
                          endDate=null;

                          selectedYear = newYear!;
                          _attendanceFuture = fetchAttendance(selectedMonth.toString(), selectedYear.toString(),'','');
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

        Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color:Colors.blue.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DateRangeSelector(
              startDate: startDate,
              endDate: endDate,
              onSelectDateRange: _selectDateRange,
            ),

          ],
        ),
      ),
            // Date Selection Row
            // DateRangeSelector(
            //   startDate: startDate,
            //   endDate: endDate,
            //   onSelectDateRange: _selectDateRange,
            // ),
            SizedBox(height: 10,),
            // _buildAppBar('Attendance $selectedYear $selectedMonth'),
            FutureBuilder<Map<String, dynamic>>(
              future: _attendanceFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                      child: Center(child: WhiteCircularProgressWidget()));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!['data'] == null || snapshot.data!['data']['attendance']==null) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/no_attendance.png', filterQuality: FilterQuality.high,height: 150.sp,width: 200.sp,),
                          SizedBox(height: 10),
                          Text(
                            'Attendance Not Available.',
                            style: GoogleFonts.montserrat(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textwhite,
                            ),
                          ),
                        ],
                      ),
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
    List<String> formattedDates;
    if (startDate != null && endDate != null) {
      // Generate dates only within the selected range
      final days = generateDateRange(startDate!, endDate!);
      formattedDates = days.map((date) => DateFormat('yyyy-MM-dd').format(date)).toList();
    } else {
      // Fallback: all dates in the selected month
      int daysInMonth = DateTime(selectedYear, selectedMonth + 1, 0).day;
      formattedDates = List.generate(daysInMonth, (index) {
        DateTime date = DateTime(selectedYear, selectedMonth, index + 1);
        return DateFormat('yyyy-MM-dd').format(date);
      });
    }

    // Filter attendance data for the generated dates
    Map<String, String> dailyAttendanceMap = {};
    attendanceData.forEach((date, entry) {
      if (formattedDates.contains(date)) {
        int status = entry['status'];
        dailyAttendanceMap[date] = getStatusSymbol(status);
      }
    });

    // Optionally sort the dates
    formattedDates.sort();
    dates = formattedDates;

    return [
      {
        'subject': 'Attendance',
        'dailyRecords': dailyAttendanceMap,
      }
    ];
  }

  // List<Map<String, dynamic>> processAttendanceData(Map<String, dynamic> attendanceData) {
  //   int daysInMonth = DateTime(selectedYear, selectedMonth + 1, 0).day; // Get total days in month
  //   Set<String> uniqueDates = Set.from(
  //     List.generate(daysInMonth, (index) {
  //       DateTime date = DateTime(selectedYear, selectedMonth, index + 1);
  //       return DateFormat('yyyy-MM-dd').format(date); // Format as "YYYY-MM-DD"
  //     }),
  //   );
  //
  //   Map<String, String> dailyAttendanceMap = {}; // Store daily attendance
  //
  //   // Extract attendance records correctly
  //   attendanceData.forEach((date, entry) {
  //     if (date.startsWith('$selectedYear-${selectedMonth.toString().padLeft(2, '0')}')) {
  //       int status = entry['status']; // Extract status
  //       dailyAttendanceMap[date] = getStatusSymbol(status); // Convert status to symbol
  //     }
  //   });
  //
  //   dates = uniqueDates.toList()..sort(); // Sort formatted dates
  //
  //   return [
  //     {
  //       'subject': 'Attendance',
  //       'dailyRecords': dailyAttendanceMap,
  //     }
  //   ];
  // }

  List<DateTime> generateDateRange(DateTime start, DateTime end) {
    List<DateTime> range = [];
    for (DateTime date = start;
    date.isBefore(end.add(Duration(days: 1)));
    date = date.add(Duration(days: 1))) {
      range.add(date);
    }
    return range;
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
            _buildSummaryRow("Total Attendance %", "${attendancePercentage.toStringAsFixed(2)}%", Colors.white),
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

  Future<void> _selectDateRange(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Select Date Range",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: SfDateRangePicker(
                  selectionMode: DateRangePickerSelectionMode.range,
                  onSelectionChanged:
                      (DateRangePickerSelectionChangedArgs args) {
                    if (args.value is PickerDateRange) {
                      setState(() {
                        startDate = args.value.startDate;
                        endDate = args.value.endDate;
                        print('Start date :- $startDate' );
                        print('End  date :- $endDate' );
                      });
                    }
                  },
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  if (startDate == null || endDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please select a valid date range")),
                    );
                    return;
                  }
                  // Update the future with the new date range
                  setState(() {
                    _attendanceFuture = fetchAttendance('', '',
                        DateFormat('yyyy-MM-dd').format(startDate!),
                        DateFormat('yyyy-MM-dd').format(endDate!));
                  });
                  Navigator.pop(context);
                },
                icon: Icon(Icons.check),
                label: Text("Apply Date Range"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),

              // ElevatedButton.icon(
              //   onPressed: () {
              //     if (startDate == null || endDate == null) {
              //       ScaffoldMessenger.of(context).showSnackBar(
              //         SnackBar(
              //             content: Text("Please select a valid date range")),
              //       );
              //       return;
              //     }
              //     fetchAttendance('', '',DateFormat('yyyy-MM-dd').format(startDate!).toString(),DateFormat('yyyy-MM-dd').format(endDate!).toString());
              //
              //     Navigator.pop(context);
              //
              //     // _attendanceFuture = fetchAttendance2();
              //
              //   },
              //   icon: Icon(Icons.check),
              //   label: Text("Apply Date Range"),
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.blueAccent,
              //     foregroundColor: Colors.white,
              //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }


}



class DateRangeSelector extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(BuildContext) onSelectDateRange;

  const DateRangeSelector({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.onSelectDateRange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:Colors.blue.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [

              OutlinedButton.icon(
                onPressed: () => onSelectDateRange(context),
                icon: const Icon(Icons.calendar_today, color: Colors.blueAccent),
                label: const Text(
                  "Select Date Range",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  side: const BorderSide(color: Colors.blueAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16), // Spacing between button and container
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateRow("From:", startDate),
                  const Divider(height: 10, color: Colors.blueAccent),
                  _buildDateRow("To:", endDate),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(String label, DateTime? date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        Text(
          date != null ? DateFormat('dd-MM-yyyy').format(date) : "Select Date",
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

}


