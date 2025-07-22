import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../NewUserBottombarPage/new_user_bottombar_page.dart';
import '/constants.dart';
import '../../strings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import 'login_student.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  List<Map<String, dynamic>> loginStudent = [];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login1() async {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    String? deviceToken = await _firebaseMessaging.getToken();
    print('Device id: $deviceToken');

    if (!_formKey.currentState!.validate()) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final url = Uri.parse(ApiRoutes.loginNewUser);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'email': _emailController.text,
          'password': _passwordController.text,
          'fcm': deviceToken ?? '',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

          String token = jsonData['student']['token'];

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('newusertoken', token);

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const NewUserBottombarPage()),
            );
          }

      } else {
        print('Login1 failed, attempting Login2');
        await _login2();
      }
    } catch (e) {
      _handleError(e, AppStrings.unexpectedError);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _login2() async {
    if (!_formKey.currentState!.validate()) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final response = await _dio.post(
        ApiRoutes.login,
        data: {
          'email': _emailController.text,
          'password': _passwordController.text,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = response.data;

        if (jsonResponse['success'] == true) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            'studentList',
            jsonEncode(jsonResponse['students']),
          );
          if (mounted) {
            setState(() {
              loginStudent = List<Map<String, dynamic>>.from(jsonResponse['students']);
              _isLoading = false;
              print('Login Student: $loginStudent');
            });

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginStudentPage()),
            );
          }
        } else {
          print('${AppStrings.loginFailedDebug}${jsonResponse['message']}');
          _showErrorDialog(jsonResponse['message']);
        }
      } else {
        print('${AppStrings.loginFailedMessage} ${response.statusCode}');
        _showErrorDialog(AppStrings.loginFailedMessage);
      }
    } on DioException catch (e) {
      _handleError(e, AppStrings.unexpectedError);
    } catch (e) {
      _handleError(e, AppStrings.unexpectedError);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleError(dynamic e, String fallbackMessage) {
    print('${AppStrings.generalErrorDebug}$e');
    String errorMessage = fallbackMessage;
    if (e is DioException && e.response != null) {
      if (e.response?.data is Map<String, dynamic>) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      } else if (e.response?.data is String) {
        errorMessage = e.response?.data;
      }
    }
    _showErrorDialog(errorMessage);
  }

  void _showErrorDialog(String message) {
    if (mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 130.sp,
                width: double.infinity,
                child: Image.asset('assets/login_top.png', fit: BoxFit.fill),
              ),
              SizedBox(
                width: double.infinity,
                child: Image.asset('assets/login_bottom.png', fit: BoxFit.fill),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  padding: EdgeInsets.all(12.sp),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              height: 90.sp,
                              width: 90.sp,
                              child: Image.asset(AppAssets.cjmlogo),
                            ),
                            Text(
                              'Convent of Jesus & Mary'.toUpperCase(),
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 50.sp),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              CupertinoIcons.mail_solid,
                              color: Colors.black,
                            ),
                            hintText: 'Enter User Id, or Adm. no', // Clear hint
                            hintStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),

                            // helperText: 'Use your email, phone number, or admission number to log in', // Additional guidance
                            // helperStyle: TextStyle(
                            //   color: Colors.grey.shade700,
                            //   fontSize: 14,
                            // ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.blueAccent,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.blue,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 12,
                            ),
                          ),
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return AppStrings.invalidEmail;
                          //   }
                          //   if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          //     return AppStrings.invalidEmail;
                          //   }
                          //   return null;
                          // },
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              CupertinoIcons.padlock_solid,
                              color: Colors.black,
                            ),
                            hintText: AppStrings.password,
                            hintStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? CupertinoIcons.eye_slash_fill
                                    : CupertinoIcons.eye_solid,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.blueAccent,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.blue,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.passwordRequired;
                            }
                            if (value.length < 4) {
                              return 'Password must be at least 4 characters long';
                            }
                            return null;
                          },
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_isLoading)
                          Center(child: CircularProgressIndicator())
                        else
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18.sp),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login1,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: Colors.white,
                                minimumSize: Size(double.infinity, 45.sp),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        SizedBox(height: 50.sp),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}