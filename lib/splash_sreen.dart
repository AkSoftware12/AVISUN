import 'dart:async';
import 'package:avi/NewUserBottombarPage/new_user_bottombar_page.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'UI/Auth/login_screen.dart';
import 'UI/Auth/login_screen_demo.dart';
import 'UI/bottom_navigation.dart';



class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    postRequestWithToken();
    _checkConnectivity();
  }

  Future<void> postRequestWithToken() async {
    try {


      // Make the POST request
      final response = await http.get(
        Uri.parse(ApiRoutes.clear),
      );

      // Check the status code and handle the response
      if (response.statusCode == 200) {
        setState(() {

          print('Api Hit ');

        });
        // Handle success response
      } else {

        // Handle error response
        print('Failed: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // Handle any exceptions
      print('Error: $e');
    }
  }


  // Check internet connectivity
  Future<void> _checkConnectivity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? newUsertoken = prefs.getString('newusertoken');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _isConnected = false;
      });
      // Show the dialog if there is no internet
      _showNoInternetDialog();
    } else {
      setState(() {
        _isConnected = true;
      });
      // Save the token in shared preferences
      // await _setTokenInSharedPreferences();
      // Navigate to BottomNavBarScreen after 5 seconds if connected
      if (token != null && token.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavBarScreen(initialIndex: 0,)),
        );
      } else  if (newUsertoken != null && newUsertoken.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NewUserBottombarPage()),
        );
      }

      else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    }
  }

  // Save token in shared preferences
  Future<void> _setTokenInSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    // const token = "JXEvEcAgC3MUbjndPGXMlyZQt2lshInfD7s3vI1htvmjMcLAxyP9GEl45Z3z";
    // await prefs.setString('token', token);
  }

  // Show Cupertino dialog when there's no internet
  void _showNoInternetDialog() {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('No Internet Connection'),
        content: const Text('Please check your internet connection and try again.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Reload'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _checkConnectivity(); // Retry connectivity check
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
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background, // Moved color inside decoration
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.all(10), // Optional: Add some padding inside the container
          child: _isConnected
              ? Image.asset(
            AppAssets.cjmlogo,
            width: MediaQuery.of(context).size.width * 0.5, // Responsive width
            height: MediaQuery.of(context).size.height * 0.25, // Responsive height
            fit: BoxFit.contain,
          )
              : const CircularProgressIndicator(), // Show loading spinner if not connected
        ),
      ),
    );
  }
}
