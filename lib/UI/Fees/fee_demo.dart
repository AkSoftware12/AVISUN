import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../CommonCalling/data_not_found.dart';
import '../../CommonCalling/progressbarWhite.dart';
import '../../PaymentGateway/PayButton/pay_button.dart';
import '../../PaymentGateway/atom_pay_helper.dart';
import '../../PaymentGateway/web_view_container.dart';
import '../../constants.dart';
import '../Auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FeesDemoScreen extends StatefulWidget {
  const FeesDemoScreen({super.key});

  @override
  State<FeesDemoScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesDemoScreen> {
  String createOrderId = ""; //optional
  String productId = ""; //optional

  bool isButtonDisabled = false;
  Timer? _timer;
  int remainingSeconds = 0;

  static const String disableTimeKey = 'pay_button_disabled_time';
  static const int cooldownMinutes = 8;

  // merchant configuration data
  final String login = "317157"; //mandatory
  final String password = 'Test@123'; //mandatory
  final String prodid = 'NSE'; //mandatory
  final String requestHashKey = 'd6ab820f036a9bc6c3'; //mandatory
  final String responseHashKey = 'd0b70f551f424ecc57'; //mandatory
  // final String requestEncryptionKey = 'A4476C2062FFA58980DC8F79EB6A799E'; //mandatory
  // final String responseDecryptionKey = '75AEF0FA1B94B3C10D4F5B268F757F11'; //mandatory
  final String txnid =
      'test240223'; // mandatory // this should be unique each time
  final String clientcode = "NAVIN"; //mandatory
  final String txncurr = "INR"; //mandatory
  final String mccCode = "8220"; //mandatory
  final String merchType = "R"; //mandatory
  // final String amount = "1.00"; //mandatory

  final String mode = "uat"; // change live for production

  // final String custFirstName = 'test'; //optional
  // final String custLastName = 'user'; //optional
  // final String mobile = '8888888888'; //optional
  // final String email = 'test@gmail.com'; //optional
  // final String address = 'mumbai'; //optional
  final String custacc = '639827'; //optional
  final String udf1 = "udf1"; //optional
  final String udf2 = "udf2"; //optional
  final String udf3 = "udf3"; //optional
  final String udf4 = "udf4"; //optional
  final String udf5 = "udf5"; //optional

  final String authApiUrl = "https://caller.atomtech.in/ots/aipay/auth"; // uat

  final String auth_API_url =
      "https://payment1.atomtech.in/ots/aipay/auth"; // prod

  // final String returnUrl =
  //     "https://pgtest.atomtech.in/mobilesdk/param"; //return url uat
  final String returnUrl =
      "https://payment.atomtech.in/mobilesdk/param"; ////return url production

  final String payDetails = '';

  bool isLoading = false;
  List fees = [];
  Map<String, dynamic>? studentData;
  Map<String, dynamic>? atomData;
  Map<String, dynamic>? atomSession;
  Set<int> selectedFees = {}; // Track selected fee IDs
  double totalAmount = 0.0;
  List<String> selectedFees1 = [];

  Timer? _statusCheckTimer; // Timer for checking fee status

  // List<String> months = [
  //   "April",
  //   "April",
  //   "May",
  //   "June",
  //   "July",
  //   "August",
  //   "September",
  //   "October",
  //   "November",
  //   "December",
  //   "January",
  //   "February",
  //   "March",
  // ];

  @override
  void initState() {
    super.initState();
    fetchAtomDataKey();
    fetchFeesData();
    checkCooldownStatus();
  }

  Future<void> fetchAtomDataKey() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("token: $token");

    final response = await http.get(
      Uri.parse(ApiRoutes.getAtomSettings),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        atomData = data['atom_settings'];
        atomSession = data['session'];

        print('Atom data : $atomData');
        print('atomSession : $atomSession');
        isLoading = false;
      });
    } else {
      // _showLoginDialog();
    }
  }

  Future<void> fetchFeesData() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse(ApiRoutes.getFees),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        fees = data['fees'];
        fetchStudentData();
        isLoading = false;

        print('FEE List : $fees');

      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _toggleSelection(int id, double amount) {
    setState(() {
      if (selectedFees1.contains(id.toString())) {
        selectedFees1.remove(id.toString());
        totalAmount -= amount;
      } else {
        selectedFees1.add(id.toString());
        totalAmount += amount;
      }
    });
  }

  Future<void> fetchStudentData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("Token: $token");

    if (token == null) {
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
    } else {}
  }

  Future<void> orderCreate(BuildContext context) async {
    showLoadingDialog(context);


    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("Token: $token");

    final url = Uri.parse(ApiRoutes.orderCreate);

    Map<String, dynamic> body = {
      "fee_ids": selectedFees1 ?? [],
      "student_id": studentData?['student_id'].toString(),
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Adding token here
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print("Success: ${response.body}");
        Map<String, dynamic> data = jsonDecode(response.body);

        setState(() {
          createOrderId = data["order_id"]; // ✅ Correct assignment
          productId = data["product_id"]; // ✅ Correct assignment
          print('OrderId: $createOrderId');
          print('productId: $productId');
        });
        _initNdpsPayment(
            context, responseHashKey, atomData!['decResponseKey'].toString());
        startStatusCheck(); // Start checking status after payment initiation
      } else {
        print("Failed: ${response.statusCode}, Response: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> orderCreateApi(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("Token: $token");

    final url = Uri.parse(ApiRoutes.atompay);

    Map<String, dynamic> body = {
      "fee_ids": selectedFees1 ?? [],
      "order_id": createOrderId,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Adding token here
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print("Success: ${response.body}");

        Map<String, dynamic> data = jsonDecode(response.body);
        _showPaymentSuccessDialog(context);
        fetchFeesData();

        setState(() {
          print('Susses: $data');
        });
      } else {
        print("Failed: ${response.statusCode}, Response: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _refresh() {
    setState(() {
      orderCreateApi(context);
    });
  }

  void _showPaymentSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          content: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 80,
                ),
                const SizedBox(height: 10),
                Text(
                  'Payment Successful',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Your payment has been processed successfully!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void startCooldown() async {
    final prefs = await SharedPreferences.getInstance();
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt(disableTimeKey, currentTime);

    setState(() {
      isButtonDisabled = true;
      remainingSeconds = cooldownMinutes * 60;
    });

    startTimer();
  }

  void startTimer() async {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      setState(() {
        remainingSeconds--;
      });

      if (remainingSeconds <= 0) {
        _timer?.cancel();
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(disableTimeKey);
        setState(() {
          isButtonDisabled = false;
        });
      }
    });
  }

  void checkCooldownStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final disabledAt = prefs.getInt(disableTimeKey);

    if (disabledAt != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final diff = now - disabledAt;
      final elapsedSeconds = diff ~/ 1000;
      final totalCooldown = cooldownMinutes * 60;

      if (elapsedSeconds < totalCooldown) {
        setState(() {
          isButtonDisabled = true;
          remainingSeconds = totalCooldown - elapsedSeconds;
        });
        startTimer();
      } else {
        await prefs.remove(disableTimeKey);
      }
    }
  }

  String formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  // Start the periodic status check when payment is initiated
  void startStatusCheck() {
    _statusCheckTimer?.cancel(); // Cancel any existing timer
    _statusCheckTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      checkFeeStatus();
    });
  }

  // Check the status of selected fees
  Future<void> checkFeeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || selectedFees1.isEmpty) {
      _statusCheckTimer?.cancel(); // Stop timer if no token or no selected fees
      return;
    }

    final response = await http.get(
      Uri.parse(ApiRoutes.getFees), // Assuming this endpoint returns fee data
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List updatedFees = data['fees'];

      // Check if all selected fees are paid
      bool allPaid = selectedFees1.every((feeId) {
        var fee = updatedFees.firstWhere(
          (f) => f['id'].toString() == feeId,
          orElse: () => null,
        );
        return fee != null && fee['pay_status'].toLowerCase() == 'paid';
      });

      if (allPaid) {
        setState(() {
          fees = updatedFees; // Update the fees list
          selectedFees1.clear(); // Clear selected fees
          totalAmount = 0.0; // Reset total amount
        });
        _statusCheckTimer?.cancel(); // Stop the timer
        // _showPaymentSuccessDialog(context); // Show success dialog
      } else {
        setState(() {
          fees = updatedFees; // Update UI with latest fee data
        });
      }
    } else {
      print("Failed to fetch fee status: ${response.statusCode}");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _statusCheckTimer?.cancel(); // Cancel the status check timer
    super.dispose();
  }

  void _showCooldownDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      // Allow dialog to be dismissed by tapping outside
      builder: (BuildContext context) {
        return _CooldownDialog(remainingSeconds: remainingSeconds);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: isLoading
          ? WhiteCircularProgressWidget()
          : fees.isEmpty
              ? Center(child: DataNotFoundWidget(title: 'Fees Not Available.'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: fees.length,
                        itemBuilder: (context, index) {
                          String dueDate = fees[index]['due_date'].toString();

                          // Parse due date and extract month
                          String monthName = "";
                          if (dueDate.isNotEmpty) {
                            DateTime parsedDate = DateTime.parse(dueDate);
                            monthName = DateFormat('MMMM')
                                .format(parsedDate); // Extract month name
                            print("Due Date Month: $monthName"); // Print month
                          }

                          return PaymentCard(
                            amount: fees[index]['to_pay_amount'].toString(),
                            status: fees[index]['pay_status'],
                            dueDate: fees[index]['due_date'].toString(),
                            payDate: fees[index]['pay_date'].toString(),
                            id: fees[index]['id'],
                            isSelected: selectedFees1.contains(fees[index]['installment_id'].toString()),
                            onSelect: (bool selected) {
                              _toggleSelection(
                                  fees[index]['installment_id'],
                                  double.parse(
                                      fees[index]['to_pay_amount'].toString()));
                              print(selectedFees1);
                            },
                            month: monthName,
                          );
                        },
                      ),
                    ),
                    // if (selectedFees1.isNotEmpty && atomSession?['payment'].toString() == '1')
                      SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              if (isButtonDisabled) {
                                // Show dialog when timer is running
                                _showCooldownDialog(context);
                              } else {
                                // Proceed with payment when timer is not running

                                orderCreate(context);
                                startCooldown();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(vertical: 10.sp),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              isButtonDisabled
                                  ? 'Please wait (${formatDuration(remainingSeconds)})'
                                  : 'Pay ₹ ${totalAmount.toString()}',
                              style: GoogleFonts.montserrat(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  void _initNdpsPayment(BuildContext context, String responseHashKey,
      String responseDecryptionKey) {
    // showLoadingDialog(context);
    _getEncryptedPayUrl(context, responseHashKey, responseDecryptionKey);
  }

  _getEncryptedPayUrl(context, responseHashKey, responseDecryptionKey) async {
    String reqJsonData = _getJsonPayloadData();
    debugPrint(reqJsonData);
    print('Json Data : $reqJsonData');
    const platform = MethodChannel('flutter.dev/NDPSAESLibrary');
    try {
      final String result = await platform.invokeMethod('NDPSAESInit', {
        'AES_Method': 'encrypt',
        'text': reqJsonData, // plain text for encryption
        'encKey': atomData!['encRequestKey'].toString() // encryption key
      });
      String authEncryptedString = result.toString();
      // here is result.toString() parameter you will receive encrypted string
      // debugPrint("generated encrypted string: '$authEncryptedString'");

      print('Atom Token : $authEncryptedString');
      _getAtomTokenId(context, authEncryptedString);
    } on PlatformException catch (e) {
      debugPrint("Failed to get encryption string: '${e.message}'.");
    }
  }

  _getAtomTokenId(context, authEncryptedString) async {
    var request = http.Request(
        'POST', Uri.parse("https://payment1.atomtech.in/ots/aipay/auth"));
    request.bodyFields = {
      'encData': authEncryptedString,
      'merchId': atomData!['login'].toString()
    };

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var authApiResponse = await response.stream.bytesToString();
      debugPrint(
          "API Response: $authApiResponse"); // Log the API response for debugging

      final split = authApiResponse.trim().split('&');
      final Map<int, String> values = {
        for (int i = 0; i < split.length; i++) i: split[i]
      };

      final splitTwo = values[1]!.split('=');
      if (splitTwo[0] == 'encData') {
        const platform = MethodChannel('flutter.dev/NDPSAESLibrary');
        try {
          final String result = await platform.invokeMethod('NDPSAESInit', {
            'AES_Method': 'decrypt',
            'text': splitTwo[1].toString(),
            'encKey': atomData!['decResponseKey'].toString()
          });

          debugPrint(
              "Decrypted Response: $result"); // Log the decrypted response for debugging
          var respJsonStr = result.toString();
          Map<String, dynamic> jsonInput = jsonDecode(respJsonStr);

          hideLoadingDialog(context);
          if (jsonInput["responseDetails"]["txnStatusCode"] == 'OTS0000') {
            final atomTokenId = jsonInput["atomTokenId"].toString();
            if (atomTokenId.isEmpty) {
              debugPrint("Error: Atom Token ID is empty.");
              return; // Handle the case where the token is empty
            }
            debugPrint("atomTokenId: $atomTokenId");
            final String payDetails =
                '{"atomTokenId" : "$atomTokenId","merchId": "${atomData!['login'].toString()}","emailId": "${studentData!['email'].toString()}","mobileNumber":"${studentData!['contact_no'].toString()}", "returnUrl":"$returnUrl"}';
            _openNdpsPG(payDetails, context, responseHashKey,
                atomData!['decResponseKey'].toString());
          } else {
            debugPrint(
                "Problem in auth API response, txnStatusCode: ${jsonInput["responseDetails"]["txnStatusCode"]}");
          }
        } on PlatformException catch (e) {
          debugPrint("Failed to decrypt: '${e.message}'.");
        }
      } else {
        debugPrint("Unexpected response format.");
      }
    } else {
      debugPrint(
          "Failed to connect to the API. Status code: ${response.statusCode}");
    }
  }

  _openNdpsPG(payDetails, context, responseHashKey, responseDecryptionKey) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WebViewContainer(
                  mode,
                  payDetails,
                  responseHashKey,
                  responseDecryptionKey,
                  selectedFees1,
                  createOrderId,
                  onReturn: _refresh,
                )));
  }

  _getJsonPayloadData() {
    var payDetails = {};
    payDetails['login'] = atomData!['login'].toString();
    payDetails['userId'] = '686507';
    payDetails['password'] = atomData!['password'].toString();
    payDetails['prodid'] = productId;
    payDetails['custFirstName'] = studentData?['student_name'];
    payDetails['custLastName'] = 'N/A';
    payDetails['amount'] = totalAmount.toString();
    payDetails['mobile'] = studentData!['contact_no'].toString();
    payDetails['address'] = studentData!['address'].toString();
    payDetails['email'] = studentData!['email'].toString();
    payDetails['txnid'] = createOrderId;
    payDetails['custacc'] = custacc;
    payDetails['requestHashKey'] = requestHashKey;
    payDetails['responseHashKey'] = responseHashKey;
    payDetails['requestencryptionKey'] = atomData!['encRequestKey'].toString();
    payDetails['responseencypritonKey'] =
        atomData!['decResponseKey'].toString();
    payDetails['clientcode'] = clientcode;
    payDetails['txncurr'] = txncurr;
    payDetails['mccCode'] = mccCode;
    payDetails['merchType'] = merchType;
    payDetails['returnUrl'] = returnUrl;
    payDetails['mode'] = mode;
    payDetails['udf1'] = '${studentData?['student_id'].toString()}';
    payDetails['udf2'] = createOrderId;
    payDetails['udf3'] = '$selectedFees1';
    payDetails['udf4'] = udf4;
    payDetails['udf5'] = udf5;
    String jsonPayLoadData = getRequestJsonData(payDetails);
    return jsonPayLoadData;
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // User manually dialog close na kar sake
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 15.sp),
              Text("Please wait...")
            ],
          ),
        );
      },
    );
  }

  void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

class PaymentCard extends StatelessWidget {
  final String amount;
  final String status;
  final String dueDate;
  final String payDate;
  final String month;
  final int id;
  final bool isSelected;
  final ValueChanged<bool> onSelect;

  PaymentCard({
    required this.amount,
    required this.status,
    required this.dueDate,
    required this.payDate,
    required this.id,
    required this.isSelected,
    required this.onSelect,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.all(5),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 50.sp,
              width: 50.sp,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${month.substring(0, 3).toUpperCase()}',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.sp), // Optional styling
                    ),
                    Text(
                      status.toLowerCase() == 'paid' ? 'Paid' : 'Due',
                      style: GoogleFonts.montserrat(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w700,
                        color: status.toLowerCase() == 'paid'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "₹$amount",
              style: GoogleFonts.montserrat(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        subtitle: Text(
          status.toLowerCase() == 'paid'
              ? (payDate.length >= 10 ? payDate.substring(0, 10) : payDate)
              : '$dueDate',
          style: GoogleFonts.montserrat(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: status.toLowerCase() == 'paid' ? Colors.green : Colors.red,
          ),
        ),
        trailing: status.toLowerCase() == 'paid'
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  IconButton(
                    icon: Icon(Icons.print),
                    onPressed: () async {
                      final Uri uri = Uri.parse('${ApiRoutes.downloadUrl}$id');
                      try {
                        if (!await launchUrl(uri,
                            mode: LaunchMode.externalApplication)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Could not open URL')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                  ),

                  Checkbox(
                    onChanged: (bool? value) {
                      if (value != null) {}
                    },
                    value: true,
                    activeColor: Colors.green,
                  ),
                ],
              )
            : Checkbox(
                value: isSelected,
                onChanged: (bool? value) {
                  if (value != null) {
                    onSelect(value);
                  }
                },
              ),
      ),
    );
  }
}

class _CooldownDialog extends StatefulWidget {
  final int remainingSeconds;

  const _CooldownDialog({required this.remainingSeconds});

  @override
  _CooldownDialogState createState() => _CooldownDialogState();
}

class _CooldownDialogState extends State<_CooldownDialog> {
  late int _currentSeconds;
  Timer? _dialogTimer;

  @override
  void initState() {
    super.initState();
    _currentSeconds = widget.remainingSeconds;
    _startTimer();
  }

  void _startTimer() {
    _dialogTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_currentSeconds > 0) {
        setState(() {
          _currentSeconds--;
        });
      } else {
        _dialogTimer?.cancel();
        Navigator.pop(
            context); // Automatically close the dialog when time is up
      }
    });
  }

  @override
  void dispose() {
    _dialogTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: Text(
        'Payment on Cooldown',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: Colors.orange,
            size: 50.sp,
          ),
          SizedBox(height: 10.sp),
          Text(
            'Please wait for ${_formatDuration(_currentSeconds)} before you can make another payment.',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog manually
          },
          child: Text(
            'OK',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
        ),
      ],
    );
  }
}
