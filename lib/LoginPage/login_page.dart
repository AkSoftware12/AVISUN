
import 'package:avi/HomeBottom/home_bootom_teacher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../ContainerShape/container.dart';

import '../ForgotPassword/forgot_password.dart';
import '../HexColorCode/HexColor.dart';

import '../RegisterPage/register_page.dart';
import '../RegisterPage/widgets/widgets.dart';
import '../Utils/app_colors.dart';
import '../Utils/image.dart';
import '../Utils/string.dart';
import 'dart:async';
import 'dart:developer' as developer;


class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isloading = false;

  @override
  void initState() {
    super.initState();
  }



  bool _isLoading = false;
  String? validationMessage;
  String? passwordError ;






  void validateEmail() {
    setState(() {
      String value = emailController.text;

      // Regular expression for validating an email
      String emailPattern = r'^[a-zA-Z0-9.a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+';

      RegExp regex = RegExp(emailPattern);

      if (value.isEmpty) {
        validationMessage = 'Please enter your email id';
      }
      // Check if email matches the regex pattern
      else if (!regex.hasMatch(value)) {
        validationMessage = 'Please enter a valid email id';
      }
      else {
        validationMessage = null;
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
        passwordError = null;  // Clear error if password is valid
      }
    });
  }


  List<bool> isSelected = [true, false]; // Default: Student selected


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 320.sp,
                color: bgColor,
                child: ClipPath(
                  clipper: WaveClipper(),
                  child: Stack(
                    children: [
                      Container(
                        height: 320.sp, // Adjust height according to your need
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blueGrey,
                              bgColor,

                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Center(
                              child: SizedBox(
                                width: 170.sp,
                                  height: 120.sp,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.sp),
                                    child: Image.asset(
                                      logo, // Replace with your image path
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                              ),

                              ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),



            SingleChildScrollView(
                child:   Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.sp),
                  child: Container(
                    color:bgColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            // decoration: BoxDecoration(
                            //   color: Colors.white,
                            //   borderRadius: BorderRadius.only(
                            //     topLeft: Radius.circular(30.sp),
                            //     topRight: Radius.circular(30.sp),
                            //   ),
                            // ),


                            child:
                            Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.sp),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 1.sp),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Email Id",
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(fontSize: 15.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
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
                                            color: bgColor,
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
                                                    borderRadius: BorderRadius.circular(10.0),
                                                    // boxShadow: [
                                                    //   BoxShadow(
                                                    //     color: Colors.orange.withOpacity(0.5),
                                                    //     spreadRadius: 2,
                                                    //     blurRadius: 7,
                                                    //     offset: Offset(0, 3),
                                                    //   ),
                                                    // ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0,right: 8.0),
                                          child: Container(
                                            width: double.infinity,

                                            height: 50.sp,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10.0),
                                              // boxShadow: [
                                              //   BoxShadow(
                                              //     color: Colors.grey.withOpacity(0.5),
                                              //     spreadRadius: 2,
                                              //     blurRadius: 7,
                                              //     offset: Offset(0, 3),
                                              //   ),
                                              // ],
                                            ),
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                    child: TextFormField(
                                                      controller: emailController,
                                                      keyboardType: TextInputType.emailAddress,


                                                      style: GoogleFonts.poppins(
                                                        textStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.normal, color: Colors.black),
                                                      ),
                                                      decoration: InputDecoration(
                                                        hintText: 'Enter your email',
                                                        border: InputBorder.none,
                                                        prefixIcon: Icon(Icons.email, color: Colors.black),
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
                                                      textInputAction: TextInputAction.next, // This sets the keyboard action to "Next"
                                                      onEditingComplete: () => FocusScope.of(context).nextFocus(),
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



                                    // Password
                                    SizedBox(height: 10.sp),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Password",
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(fontSize: 15.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
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
                                            color: bgColor,
                                            borderRadius: BorderRadius.circular(10.0),
                                            // boxShadow: [
                                            //   BoxShadow(
                                            //     color: Colors.grey.withOpacity(0.5),
                                            //     spreadRadius: 2,
                                            //     blurRadius: 7,
                                            //     offset: Offset(0, 3),
                                            //   ),
                                            // ],
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
                                                    borderRadius: BorderRadius.circular(10.0),
                                                    // boxShadow: [
                                                    //   BoxShadow(
                                                    //     color: Colors.orange.withOpacity(0.5),
                                                    //     spreadRadius: 2,
                                                    //     blurRadius: 7,
                                                    //     offset: Offset(0, 3),
                                                    //   ),
                                                    // ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0,right: 8.0),
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
                                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                    child: TextFormField(
                                                      controller: passwordController,
                                                      keyboardType: TextInputType.emailAddress,
                                                      style: GoogleFonts.poppins(
                                                        textStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.normal, color: Colors.black),
                                                      ),
                                                      obscureText: true,
                                                      decoration: InputDecoration(
                                                        hintText: 'Enter your password',
                                                        border: InputBorder.none,
                                                        prefixIcon: Icon(Icons.lock, color: Colors.black),

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
                                    SizedBox(height: 10.sp),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(
                                                builder: (context) =>
                                                    ForgotPasswordPage()),);
                                          },
                                          child: Text(
                                            "Forgot password?",
                                            style: GoogleFonts.poppins(
                                              textStyle: TextStyle(fontSize: 12.sp,
                                                  fontWeight: FontWeight.normal,
                                                  color: HexColor('#f04949')),
                                            ),
                                          ),
                                        ),
                                      ],
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
                                                  bgColor,


                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.5),
                                                  spreadRadius: 2,
                                                  blurRadius: 7,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],

                                              // borderRadius: BorderRadius.only(
                                              //   bottomLeft: Radius.circular(50.sp),
                                              //   bottomRight: Radius.circular(50.sp),
                                              // ),
                                            ),

                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.transparent, // Make the button background transparent
                                                shadowColor: Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(0)),// Remove the shadow (optional)
                                              ),

                                              child: Text(
                                                "Login",
                                                style: GoogleFonts.poppins(
                                                  textStyle: TextStyle(fontSize: 17.sp,
                                                      fontWeight: FontWeight.normal,
                                                      color: whiteColor),
                                                ),
                                              ),

                                              onPressed: (){
                                                validateEmail();
                                                validatePassword();
                                                if ( validationMessage == null && passwordError == null  ) {
                                                  if (formKey.currentState!.validate()) {
                                                    nextScreen(context,  HomeBottom());

                                                    // loginUser(context);

                                                  }
                                                } else {
                                                  print('Validation failed: $validationMessage');
                                                }

                                              },

                                            ),
                                          ),
                                        ),
                                        isloading
                                            ? SizedBox(
                                            height: 40.sp,
                                            child: Center(
                                                child:
                                                const CircularProgressIndicator(
                                                  color: Colors.white,
                                                )))
                                            : SizedBox()
                                      ],
                                    ),


                                    SizedBox(height: 10.sp),





                                  ],
                                ),
                              ),
                            ),
                          ),

                        ),
                        SizedBox(height: 30.sp,),

                        Text.rich(TextSpan(
                          text: "Don't have an account? ",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          children: <TextSpan>[
                            TextSpan(
                                text: "Register here",
                                style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    nextScreen(context,  RegisterPage());
                                  }),
                          ],
                        )),
                        // Transform.rotate(
                        //   angle: 3.14159, // Rotate by 180 degrees (PI radians)
                        //   child: ClipPath(
                        //     clipper: WaveClipper(),
                        //     child: Container(
                        //       width: double.infinity,
                        //       height: 130.sp,
                        //       decoration: BoxDecoration(
                        //         // borderRadius: BorderRadius.circular(8.0),
                        //         gradient: LinearGradient(
                        //           colors: [
                        //             primaryColor2,
                        //             primaryColor,
                        //
                        //
                        //           ],
                        //           begin: Alignment.topLeft,
                        //           end: Alignment.bottomRight,
                        //         ),
                        //         // borderRadius: BorderRadius.only(
                        //         //   bottomLeft: Radius.circular(50.sp),
                        //         //   bottomRight: Radius.circular(50.sp),
                        //         // ),
                        //       ),
                        //         child: SizedBox(
                        //           height: 130.sp,
                        //           child: Align(
                        //             alignment: Alignment.bottomCenter,
                        //             child: Transform.rotate(
                        //               angle: 3.14159,
                        //               child: Center(
                        //                 child: Padding(
                        //                   padding:  EdgeInsets.only(top: 15.sp),
                        //                   child: Text.rich(TextSpan(
                        //                     text: "Don't have an account? ",
                        //                     style: const TextStyle(
                        //                         color: Colors.white, fontSize: 14),
                        //                     children: <TextSpan>[
                        //                       TextSpan(
                        //                           text: "Register here",
                        //                           style: const TextStyle(
                        //                               fontSize: 20,
                        //                               color: Colors.black,
                        //                               decoration: TextDecoration.underline),
                        //                           recognizer: TapGestureRecognizer()
                        //                             ..onTap = () {
                        //                               nextScreen(context,  RegisterPage());
                        //                             }),
                        //                     ],
                        //                   )),
                        //                 ),
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //
                        //     ),
                        //   ),

                      ],
                    ),
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





