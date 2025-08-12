import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/UI/bottom_navigation.dart';
import '/constants.dart';
import '../../strings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'login_screen.dart';

class LoginUserLIst extends StatefulWidget {

  const LoginUserLIst({super.key,});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginUserLIst> {

  final Dio _dio = Dio(); // Initialize Dio
  bool _isLoading = false;
  // List<dynamic> studentList = []; // ✅ Dropdown ke liye data list
  List<Map<String, dynamic>> studentList = [];

  // Radio Button List Data
  String? selectedOption;

  @override
  void initState() {
    super.initState();
    _loadLoginHistory();

  }

  Future<void> _login() async {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    String? deviceToken = await _firebaseMessaging.getToken();
    print('Device id: $deviceToken');
    // if (!_formKey.currentState!.validate()) return;

    print('${AppStrings.apiLoginUrl}${ApiRoutes.loginstudent}'); // Debug: Print the API URL
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _dio.post(
        ApiRoutes.loginstudent,
        data: {
          'student_id': selectedOption,
          'fcm': deviceToken,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      print(' Device token : - $deviceToken');

      print('${AppStrings.responseStatusDebug}${response.statusCode}'); // Debug: Print status code
      print('${AppStrings.responseDataDebug}${response.data}'); // Debug: Print the response data

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true) {
          // Save token in SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', responseData['token']);
          print('${AppStrings.tokenSaved}${responseData['token']}'); // Debug: Print the saved token

          // Retrieve the token
          String? token = prefs.getString('token');
          print('${AppStrings.tokenRetrieved}$token'); // Debug: Print retrieved token

          // Navigate to the BottomNavBarScreen with the token
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BottomNavBarScreen(initialIndex: 0,),
            ),
          );
        } else {
          print('${AppStrings.loginFailedDebug}${responseData['message']}'); // Debug: Print failure message
          _showErrorDialog(responseData['message']);
        }
      } else {
        print('${AppStrings.loginFailedMessage} ${response.statusCode}'); // Debug: Unexpected status code
        _showErrorDialog(AppStrings.loginFailedMessage);
      }
    } on DioException catch (e) {
      print('${AppStrings.dioExceptionDebug}${e.message}'); // Debug: Print DioException message

      String errorMessage = AppStrings.unexpectedError;
      if (e.response != null) {
        print('${AppStrings.errorResponseDebug}${e.response?.data}'); // Debug: Print error response data

        if (e.response?.data is Map<String, dynamic>) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
        } else if (e.response?.data is String) {
          errorMessage = e.response?.data;
        }
      } else {
        errorMessage = e.message ?? 'Unable to connect to the server.';
      }

      _showErrorDialog(errorMessage);
    } catch (e) {
      print('${AppStrings.generalErrorDebug}$e'); // Catch any other errors
      _showErrorDialog(AppStrings.unexpectedError);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.loginFailedTitle),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
// Save selected student_id to SharedPreferences
  Future<void> _saveSelectedStudent(String studentId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_student_id', studentId);
  }


  Future<void> _loadLoginHistory() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('loginHistory');
    if (data != null) {
      setState(() {
        studentList = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }
  // Future<void> _loadStudents() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? savedData = prefs.getString('studentList');
  //
  //   if (savedData != null) {
  //     setState(() {
  //       studentList = jsonDecode(savedData);
  //       print('Student List $studentList');
  //
  //       // selectedStudent = studentList.isNotEmpty ? studentList[0]['name'] : null;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: EdgeInsets.all(10.sp),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo Section
                  Container(
                    height: 90.sp,
                    width: 180.sp,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10.sp),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          height: 90.sp,
                          width: 90.sp,
                          child: Image.asset(
                            AppAssets.cjmlogo,
                            fit: BoxFit.contain, // Ensure image fits properly
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error); // Fallback for image loading failure
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Select Student Text
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Select Student",
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                  ),
                   Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '(${studentList.length.toString()})',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                  ),
                  // Constrain ListView height
                  SizedBox(
                    height: 250.sp, // Set a fixed height for the ListView
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true, // Ensure ListView takes only the space it needs
                      physics: const ClampingScrollPhysics(), // Smooth scrolling
                      itemCount: studentList.length,
                      itemBuilder: (context, index) {
                        final student = studentList[index];
                        // Check for null or missing keys
                        if (student == null ||
                            student['name'] == null ||
                            student['student_id'] == null ||
                            student['adm_no'] == null) {
                          return const ListTile(
                            title: Text('Invalid Student Data'),
                          );
                        }
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                            // boxShadow: [
                            //   BoxShadow(
                            //     color: Colors.black,
                            //     blurRadius: 10,
                            //     offset: const Offset(2, 2),
                            //   ),
                            // ],
                          ),
                          child: RadioListTile<String>(
                            contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student['name'].toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  student['student_id'].toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              student['adm_no'].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            value: student['student_id'].toString(),
                            groupValue: selectedOption,
                            onChanged: (value) {
                              setState(() {
                                selectedOption = value;
                              });
                              _saveSelectedStudent(value!);
                            },
                            activeColor: AppColors.secondary,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 50.sp),
                  // Loading Indicator or Button
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Padding(
                    padding: EdgeInsets.only(left: 18.sp, right: 18.sp),
                    child: CustomLoginButton(
                      onPressed: () {
                        if (selectedOption != null) {
                          _login();
                          print("Selected Option: $selectedOption");
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please select a student!"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      title: 'Go',
                    ),
                  ),
                ],
              ),
            ),
            // Footer Text
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Provider by AVI-SUN',
                style: GoogleFonts.montserrat(
                  textStyle: Theme.of(context).textTheme.displayLarge,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.normal,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }}

class CustomLoginButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String title;

  const CustomLoginButton({
    super.key,
    required this.onPressed,
    required this.title,
  });

  @override
  _CustomLoginButtonState createState() => _CustomLoginButtonState();
}

class _CustomLoginButtonState extends State<CustomLoginButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) async {
        setState(() => isPressed = true);

        // Let the ripple animation happen first (optional)
        await Future.delayed(Duration(milliseconds: 100));

        if (mounted) {
          setState(() => isPressed = false);
        }

        // Navigate or perform login after animation is done
        widget.onPressed();
      },


      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: isPressed
                ? [AppColors.secondary, AppColors.primary]
                : [AppColors.secondary, AppColors.primary],
          ),
          boxShadow: isPressed
              ? []
              : [
            BoxShadow(
              color: Colors.blue.withOpacity(0.5),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '${widget.title}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
