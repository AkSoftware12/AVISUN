
import 'package:avi/PaymentGateway/home_getway.dart';
import 'package:avi/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../CommonCalling/data_not_found.dart';
import '../../CommonCalling/progressbarWhite.dart';
import '../../PaymentGateway/PayButton/pay_button.dart';
import '../Auth/login_screen.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key,});



  @override
  State<FeesScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<FeesScreen> {
  bool isLoading = false;

  List fess = []; // Declare a list to hold API data
  Map<String, dynamic>? studentData;

  @override
  void initState() {
    super.initState();
    fetchFeesData();
  }

  Future<void> fetchFeesData() async {
    setState(() {
      isLoading = true; // Show progress bar
    });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("Token: $token");

    if (token == null) {
      _showLoginDialog();
      return;
    }

    final response = await http.get(
      Uri.parse(ApiRoutes.getFees),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        fess = data['fees'];
        fetchStudentData();

        isLoading = false;
        print(fess);
      });
    } else {
      _showLoginDialog();
      setState(() {
        isLoading = true; // Show progress bar
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body:  isLoading
          ? WhiteCircularProgressWidget()
          : fess.isEmpty
          ? Center(child: DataNotFoundWidget(title: 'Fees  Not Available.',))
          : ListView.builder(
        itemCount: fess.length,
        itemBuilder: (context, index) {
          return PaymentCard(
            amount: fess[index]['to_pay_amount'].toString(),
            status: fess[index]['pay_status'],
            dueDate: fess[index]['due_date'].toString(),
            onPayNow: () {
              print("Processing payment for ₹${fess[index]['to_pay_amount']}");

              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => HomeGateway()),
              // );
            },
            custFirstName: studentData?['student_name']?? '',
            custLastName: 'N/A',
            mobile: studentData?['contact_no']??'', email:studentData?['contact_mail']??'',
            address: studentData?['address']??'',
            payDate: fess[index]['pay_date'].toString(),
          );
        },
      ),

    );
  }
}

class PaymentCard extends StatelessWidget {
  final String amount;
  final String status;
  final String dueDate;
  final String payDate;
  final VoidCallback onPayNow;
  final String custFirstName; //optional
  final String custLastName; //optional
  final String mobile; //optional
  final String email; //optional
  final String address;

  PaymentCard({
    required this.amount,
    required this.status,
    required this.dueDate,
    required this.onPayNow, required this.custFirstName, required this.custLastName, required this.mobile, required this.email, required this.address, required this.payDate,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_bottom;
        break;
      case 'paid':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'active':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'inactive':
      default:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
    }

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.all(3.sp),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          shrinkWrap: true, // Ensures proper rendering inside ListView.builder
          physics: NeverScrollableScrollPhysics(),
          children: [
            // Pay Amount
            _buildRow("Pay Amount", "${amount}", Icons.currency_rupee, Colors.black),

            SizedBox(height: 12),

            // Payment Status
            _buildRow("Status", status.toUpperCase(), statusIcon, statusColor),

            SizedBox(height: 12),


            if(status=='active')
            // Due Date
            _buildRow("Due Date", dueDate, Icons.calendar_today, Colors.blueGrey),
            if(status=='paid')
              _buildRow("Pay Date", payDate, Icons.calendar_today, Colors.blueGrey),


            SizedBox(height: 20),
            if(status=='active')
            CommonNdpsButton(buttonText: "Pay Now",
              status: status, amount: amount,
              custFirstName: custFirstName,
              custLastName: custLastName,
              mobile: mobile, email: email,
              address: address,
            ),

            if(status=='paid')


            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (){



    },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Download Receipt ",
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Method to Build a Row with Icon
  Widget _buildRow(String title, String value, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: 5),
            Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }



}




