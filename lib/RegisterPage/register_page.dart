import 'dart:convert';

import 'package:avi/HomeBottom/home_bootom_teacher.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../ContainerShape/container.dart';
import '../HexColorCode/HexColor.dart';
import '../LoginPage/login_page.dart';
import '../Utils/app_colors.dart';
import '../Utils/image.dart';
import '../Utils/string.dart';
import '../Utils/textSize.dart';
import '../baseurl/baseurl.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? nameError;
  String? phoneError;

  String? passwordError;

  String? validationMessage;

  final _focusNode = FocusNode();

  final TextEditingController nameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController schoolController = TextEditingController();
  final TextEditingController marksController = TextEditingController();
  final TextEditingController examNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController highestqualificationController =
      TextEditingController();
  final TextEditingController teachingExperienceController =
      TextEditingController();

  String email = "";
  String password = "";
  String fullName = "";


  Future<void> _registerUser(BuildContext context) async {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    String? deviceToken = await _firebaseMessaging.getToken();
    print('Device id: $deviceToken');

    try {
      if (formKey.currentState!.validate()) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: primaryColor,
                  ),
                  // SizedBox(width: 16.0),
                  // Text("Logging in..."),
                ],
              ),
            );
          },
        );

        setState(() {
          _isLoading = true;
        });

        String apiUrl = register; // Replace with your API endpoint

        Map<String, dynamic> requestBody = {
          'name': nameController.text,
          'email': emailController.text,
          'contact': phoneController.text,
          'password': passwordController.text,
          'standard': selectedValue1,
          'school_name': schoolController.text,
          'past_marks': marksController.text,
          'language': selectedValue3,
          'exam_name': examNameController.text,
          'state': selectedState,
        };



        final response = await http.post(
          Uri.parse(apiUrl),
          body: requestBody,
        );

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 201) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final String token = responseData['token'];
          final String userId = responseData['data']['id'].toString();
          final String user = responseData['data'].toString();

          // Save token using shared_preferences
          await prefs.setString('token', token);
          await prefs.setString('id', userId);
          await prefs.setString('data', user);
          prefs.setBool('isLoggedIn', true);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeBottom(
              ),
            ),
          );

          print('User registered successfully!');
          print(token);
          print(response.body);
        } else {
          Navigator.pop(context);
          print('Registration failed!');
          Fluttertoast.showToast(
            msg: response.body,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black.withOpacity(0.8),
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context); // Close the progress dialog

      // Handle errors appropriately
      print('Error during login: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to log in. Please try again.'),
      ));
    }
  }


  @override
  void initState() {
    super.initState();
  }

  void validateEmail() {
    setState(() {
      String value = emailController.text;

      // Regular expression for validating an email
      String emailPattern =
          r'^[a-zA-Z0-9.a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+';

      RegExp regex = RegExp(emailPattern);

      if (value.isEmpty) {
        validationMessage = 'Please enter your email id';
      }
      // Check if email matches the regex pattern
      else if (!regex.hasMatch(value)) {
        validationMessage = 'Please enter a valid email id';
      } else {
        validationMessage = null;
      }
    });
  }

  void validateName() {
    setState(() {
      String value = nameController.text;
      if (value.isEmpty) {
        nameError = 'Please enter your name';
      } else {
        nameError = null;
      }
    });
  }

  void validatePhone() {
    setState(() {
      String value = phoneController.text;
      if (value.isEmpty) {
        phoneError = 'Please enter your Mobile Number';
      } else {
        phoneError = null;
      }
    });
  }

  void validatePassword() {
    setState(() {
      String value = passwordController.text;

      if (value.isEmpty) {
        passwordError = 'Please enter your password';
      } else if (value.length < 6) {
        passwordError = "Password must be at least 6 characters";
      } else {
        passwordError = null; // Clear error if password is valid
      }
    });
  }



  List<bool> isSelected = [true, false]; // Default: Student selected

  // Function to fetch data from API

  String? selectedValue2;
  String? selectedValue1;
  String? selectedAdditionalValue;

  List<Map<String, String>> dropdownItems1 = [
    {'id': '11th', 'name': '11th Grade'},
    {'id': '12th', 'name': '12th Grade'},
    {'id': 'dropout', 'name': 'Dropout'},
  ];

  List<String> additionalDropdownItems = ['Option 1', 'Option 2'];

  String? selectedValue4;
  String? selectedValue3;

  List<Map<String, String>> dropdownItems2 = [
    {'id': 'Hindi', 'name': 'Hindi'},
    {'id': 'English', 'name': 'English'},
  ];


  final List<String> states = [
    "Andhra Pradesh",
    "Arunachal Pradesh",
    "Assam",
    "Bihar",
    "Chhattisgarh",
    "Goa",
    "Gujarat",
    "Haryana",
    "Himachal Pradesh",
    "Jharkhand",
    "Karnataka",
    "Kerala",
    "Madhya Pradesh",
    "Maharashtra",
    "Manipur",
    "Meghalaya",
    "Mizoram",
    "Nagaland",
    "Odisha",
    "Punjab",
    "Rajasthan",
    "Sikkim",
    "Tamil Nadu",
    "Telangana",
    "Tripura",
    "Uttar Pradesh",
    "Uttarakhand",
    "West Bengal",
    "Andaman and Nicobar Islands",
    "Chandigarh",
    "Dadra and Nagar Haveli and Daman and Diu",
    "Delhi",
    "Jammu and Kashmir",
    "Ladakh",
    "Lakshadweep",
    "Puducherry",
  ];

  String? selectedState; // Holds the currently selected state

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: isSelected[0] ? primaryColor : Colors.blueGrey,
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 230.sp,
                color: isSelected[0] ? primaryColor : Colors.blueGrey,
                child: ClipPath(
                  clipper: WaveClipper(),
                  child: Stack(
                    children: [
                      Container(
                        height: 250.sp, // Adjust height according to your need
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              isSelected[0] ? primaryColor : Colors.blueGrey,
                              isSelected[0] ? Colors.blueGrey : primaryColor,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                              child: SizedBox(
                                  height: 150.sp,
                                  // child: Image.asset('assets/log_in.png')

                                  child: Column(
                                    children: [
                                      SizedBox(
                                          width: 150.sp,
                                          height: 100.sp,
                                          child: Image.asset(logo)),
                                      Text.rich(TextSpan(
                                        text: AppConstants.appLogoName,
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: AppConstants.appLogoName2,
                                            style: GoogleFonts.poppins(
                                              textStyle: TextStyle(
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          )
                                        ],
                                      )),
                                    ],
                                  ))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.sp),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [


                            SizedBox(height: 1.sp),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Full Name",
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ),
                                Text('')
                              ],
                            ),
                            SizedBox(height: 10.sp),
                            Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 50.sp,
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(10.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 7,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 10,
                                        child: Container(
                                          width: double.infinity,
                                          height: 50.sp,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.orange
                                                    .withOpacity(0.5),
                                                spreadRadius: 2,
                                                blurRadius: 7,
                                                offset: Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: 8.0, right: 8.sp),
                                  child: Container(
                                    width: double.infinity,
                                    height: 50.sp,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 7,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: TextFormField(
                                              controller: nameController,
                                              keyboardType: TextInputType.name,
                                              style: GoogleFonts.poppins(
                                                textStyle: TextStyle(
                                                    fontSize: 15.sp,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.black),
                                              ),
                                              decoration: InputDecoration(
                                                hintText: 'Enter your name',
                                                border: InputBorder.none,
                                                prefixIcon: Icon(
                                                    Icons.account_circle,
                                                    color: Colors.black),
                                              ),
                                              onChanged: (val) {
                                                validateName();

                                                // setState(() {
                                                //   fullName = val;
                                                // });
                                              },

                                              // validator: (val) {
                                              //   if (val!.isNotEmpty) {
                                              //     return null;
                                              //   } else {
                                              //     return "Name cannot be empty";
                                              //   }
                                              // },
                                              textInputAction:
                                                  TextInputAction.next,
                                              // This sets the keyboard action to "Next"
                                              onEditingComplete: () =>
                                                  FocusScope.of(context)
                                                      .nextFocus(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (nameError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 0.0),
                                child: Container(
                                  // decoration: BoxDecoration(
                                  //   color: Colors.red[100],
                                  //   borderRadius: BorderRadius.circular(5),
                                  // ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 1, horizontal: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                        size: 16,
                                      ),
                                      SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          nameError!,
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12.sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            SizedBox(height: 10.sp),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Email id",
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ),
                                Text('')
                              ],
                            ),
                            SizedBox(height: 10.sp),
                            Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 50.sp,
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(10.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 7,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 10,
                                        child: Container(
                                          width: double.infinity,
                                          height: 50.sp,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.orange
                                                    .withOpacity(0.5),
                                                spreadRadius: 2,
                                                blurRadius: 7,
                                                offset: Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Container(
                                    width: double.infinity,
                                    height: 50.sp,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 7,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: TextFormField(
                                              controller: emailController,
                                              keyboardType:
                                                  TextInputType.emailAddress,

                                              style: GoogleFonts.poppins(
                                                textStyle: TextStyle(
                                                    fontSize: 15.sp,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.black),
                                              ),
                                              decoration: InputDecoration(
                                                hintText: 'Enter your email',
                                                border: InputBorder.none,
                                                prefixIcon: Icon(Icons.email,
                                                    color: Colors.black),
                                              ),

                                              onChanged: (val) {
                                                validateEmail();

                                                // setState(() {
                                                //   email = val;
                                                // });
                                              },

                                              // check tha validation
                                              // validator: (val) {
                                              //   return RegExp(
                                              //       r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                              //       .hasMatch(val!)
                                              //       ? null
                                              //       : "Please enter a valid email";
                                              // },
                                              textInputAction:
                                                  TextInputAction.next,
                                              // This sets the keyboard action to "Next"
                                              onEditingComplete: () =>
                                                  FocusScope.of(context)
                                                      .nextFocus(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (validationMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 0.0),
                                child: Container(
                                  // decoration: BoxDecoration(
                                  //   color: Colors.red[100],
                                  //   borderRadius: BorderRadius.circular(5),
                                  // ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                        size: 16,
                                      ),
                                      SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          validationMessage!,
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12.sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            SizedBox(height: 10.sp),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Contact Number",
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ),
                                Text('')
                              ],
                            ),
                            SizedBox(height: 10.sp),
                            Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 50.sp,
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(10.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 7,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 10,
                                        child: Container(
                                          width: double.infinity,
                                          height: 50.sp,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.orange
                                                    .withOpacity(0.5),
                                                spreadRadius: 2,
                                                blurRadius: 7,
                                                offset: Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: 8.0, right: 8.sp),
                                  child: Container(
                                    width: double.infinity,
                                    height: 50.sp,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 7,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: TextFormField(
                                              controller: phoneController,
                                              keyboardType: TextInputType.phone,
                                              style: GoogleFonts.poppins(
                                                textStyle: TextStyle(
                                                    fontSize: 15.sp,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.black),
                                              ),
                                              decoration: InputDecoration(
                                                hintText:
                                                    'Enter your mobile number',
                                                border: InputBorder.none,
                                                prefixIcon: Icon(Icons.call,
                                                    color: Colors.black),
                                              ),
                                              onChanged: (val) {
                                                validatePhone();

                                                // setState(() {
                                                //   fullName = val;
                                                // });
                                              },

                                              // validator: (val) {
                                              //   if (val!.isNotEmpty) {
                                              //     return null;
                                              //   } else {
                                              //     return "Name cannot be empty";
                                              //   }
                                              // },
                                              textInputAction:
                                                  TextInputAction.next,
                                              // This sets the keyboard action to "Next"
                                              onEditingComplete: () =>
                                                  FocusScope.of(context)
                                                      .nextFocus(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (phoneError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 0.0),
                                child: Container(
                                  // decoration: BoxDecoration(
                                  //   color: Colors.red[100],
                                  //   borderRadius: BorderRadius.circular(5),
                                  // ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 1, horizontal: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                        size: 16,
                                      ),
                                      SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          phoneError!,
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12.sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            SizedBox(height: 10.sp),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Password",
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ),
                                Text('')
                              ],
                            ),
                            SizedBox(height: 10.sp),
                            // Remove GestureDetector from wrapping Scaffold

                            Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 50.sp,
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(10.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 7,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 10,
                                        child: Container(
                                          width: double.infinity,
                                          height: 50.sp,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.orange
                                                    .withOpacity(0.5),
                                                spreadRadius: 2,
                                                blurRadius: 7,
                                                offset: Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Container(
                                    width: double.infinity,
                                    height: 50.sp,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 7,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: TextFormField(
                                              controller: passwordController,
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              style: GoogleFonts.poppins(
                                                textStyle: TextStyle(
                                                    fontSize: 15.sp,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.black),
                                              ),
                                              decoration: InputDecoration(
                                                hintText: 'Enter your password',
                                                border: InputBorder.none,
                                                prefixIcon: Icon(Icons.lock,
                                                    color: Colors.black),
                                              ),
                                              // validator: (val) {
                                              //   if (val!.length < 6) {
                                              //     return "Password must be at least 6 characters";
                                              //   } else {
                                              //     return null;
                                              //   }
                                              // },
                                              onChanged: (val) {
                                                validatePassword();
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (passwordError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 0.0),
                                child: Container(
                                  // decoration: BoxDecoration(
                                  //   color: Colors.red[100],
                                  //   borderRadius: BorderRadius.circular(5),
                                  // ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                        size: 16,
                                      ),
                                      SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          passwordError!,
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12.sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),




                            SizedBox(
                              height: 20.sp,
                            ),



                            SizedBox(height: 30.sp),
                            Stack(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: 40.sp,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      gradient: LinearGradient(
                                        colors: [
                                          primaryColor2,
                                          primaryColor,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      // borderRadius: BorderRadius.only(
                                      //   bottomLeft: Radius.circular(50.sp),
                                      //   bottomRight: Radius.circular(50.sp),
                                      // ),
                                    ),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        // Make the button background transparent
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                0)), // Remove the shadow (optional)
                                      ),
                                      // style: ElevatedButton.styleFrom(
                                      //     backgroundColor: HexColor('#ffc107'),
                                      //     elevation: 0,
                                      //     shape: RoundedRectangleBorder(
                                      //         borderRadius: BorderRadius.circular(15))),
                                      child: Text(
                                        "Register",
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                              fontSize: 17.sp,
                                              fontWeight: FontWeight.normal,
                                              color: whiteColor),
                                        ),
                                      ),

                                      onPressed: () {
                                        validateEmail();
                                        validateName();
                                        validatePhone();
                                        validatePassword();
                                        if (validationMessage == null &&
                                            nameError == null &&
                                            phoneError == null &&
                                            passwordError == null) {
                                          if (formKey.currentState!
                                              .validate()) {
                                            _registerUser(context);
                                          }
                                        } else {
                                          print(
                                              'Validation failed: $validationMessage');
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 20.sp),
                            Container(
                              height: 25.sp,
                              child: Stack(
                                children: [
                                  Center(
                                    child: Container(
                                      height: 2,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.grey.shade100,
                                            Colors.black54,
                                            Colors.grey.shade100,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Container(
                                      color: Colors.white,
                                      height: 25.sp,
                                      width: 40.sp,
                                      child: Center(
                                        child: Text(
                                          "OR",
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                                fontSize: 17.sp,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.sp),
                            Text.rich(TextSpan(
                              text: "Already have an account ? ",
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: HexColor('#9ba3aa')),
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: "Sign in",
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black),
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => LoginPage()),
                                      );
                                    },
                                ),
                              ],
                            )),
                            SizedBox(height: 20.sp),
                          ],
                        ),
                      ),
                    )

            ],
          ),
        ),
      ),
    );
  }
}
