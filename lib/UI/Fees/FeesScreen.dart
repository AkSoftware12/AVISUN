
import 'package:avi/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../Auth/login_screen.dart';

class FeesScreen extends StatefulWidget {


  @override
  State<FeesScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<FeesScreen> {
  final List<Map<String, dynamic>> paymentDetails=[
    {"amount": 2500.75, "status": "Pending", "dueDate": "28-02-2025"},
    {"amount": 1800.00, "status": "Active", "dueDate": "15-03-2025"},
    {"amount": 3200.50, "status": "Inactive", "dueDate": "10-01-2025"},
    {"amount": 3200.50, "status": "Inactive", "dueDate": "10-01-2025"},
  ];
  List fess = []; // Declare a list to hold API data
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFeesData();
  }

  Future<void> fetchFeesData() async {
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
        isLoading = false;
        print(fess);
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
      backgroundColor: AppColors.primary,
      // appBar: AppBar(
      //   title: Text("Payment Details", style: GoogleFonts.montserrat()),
      //   backgroundColor: Colors.blueAccent,
      //   centerTitle: true,
      // ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: ListView.builder(
          itemCount: fess.length,
          itemBuilder: (context, index) {
            return PaymentCard(
              amount: fess[index]['to_pay_amount'].toString(),
              status: fess[index]['pay_status'],
              dueDate: fess[index]['pay_date'].toString(),
              onPayNow: () {
                print("Processing payment for ₹${fess[index]['to_pay_amount']}");

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AtomPaymentScreen()),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class PaymentCard extends StatelessWidget {
  final String amount;
  final String status;
  final String dueDate;
  final VoidCallback onPayNow;

  PaymentCard({
    required this.amount,
    required this.status,
    required this.dueDate,
    required this.onPayNow,
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
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.only(bottom: 16),
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

            // Due Date
            _buildRow("Due Date", dueDate, Icons.calendar_today, Colors.blueGrey),

            SizedBox(height: 20),

            // Pay Now Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: status.toLowerCase() == 'active' || status.toLowerCase() == 'inactive'||status.toLowerCase() == 'pending' ? onPayNow : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: status.toLowerCase() == 'active' || status.toLowerCase() == 'inactive'||status.toLowerCase() == 'pending'
                      ? statusColor
                      : Colors.grey,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Pay Now",
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





class AtomPaymentScreen extends StatefulWidget {
  @override
  _AtomPaymentScreenState createState() => _AtomPaymentScreenState();
}

class _AtomPaymentScreenState extends State<AtomPaymentScreen> {
  bool _isLoading = false;
  String? _paymentUrl;

  // **🔹 Replace with your Atom credentials**
  final String _merchantId = "YOUR_MERCHANT_ID";
  final String _apiKey = "YOUR_API_KEY";
  final String _amount = "100.00"; // Replace with dynamic amount
  final String _currency = "INR";
  final String _customerEmail = "customer@example.com";
  final String _customerPhone = "9876543210";

  // **🔹 Atom Payment API URL**
  final String _atomUrl = "https://paynetzuat.atomtech.in/paynetz/epi/fts";

  @override
  void initState() {
    super.initState();
    initiatePayment();
  }

  /// **🔹 Initialize Payment**
  Future<void> initiatePayment() async {
    setState(() => _isLoading = true);

    try {
      final Uri apiUrl = Uri.parse(_atomUrl);
      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "login": _merchantId,
          "pass": _apiKey,
          "ttype": "NBFundTransfer",
          "prodid": "ATOM_PAYMENT",
          "amt": _amount,
          "txncurr": _currency,
          "txnscamt": "0",
          "clientcode": base64Encode(utf8.encode(_customerEmail)),
          "custacc": "123456789012",
          "date": DateTime.now().toString(),
          "custname": "Customer Name",
          "custemail": _customerEmail,
          "custphone": _customerPhone,
          "ru": "https://yourwebsite.com/payment_response",
        },
      );

      if (response.statusCode == 200) {
        final paymentData = json.decode(response.body);
        _paymentUrl = paymentData["paymentUrl"];

        if (_paymentUrl != null) {
          _launchPaymentUrl(_paymentUrl!);
        } else {
          throw Exception("⚠️ Payment URL not found in response");
        }
      } else {
        throw Exception("⚠️ Payment Initialization Failed: ${response.body}");
      }
    } catch (e) {
      print("⚠️ Payment Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// **🔹 Open Payment URL in Browser**
  void _launchPaymentUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    } else {
      throw "⚠️ Could not launch $url";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Atom Payment Gateway")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
        child: ElevatedButton(
          onPressed: () => initiatePayment(),
          child: Text("Retry Payment"),
        ),
      ),
    );
  }
}
