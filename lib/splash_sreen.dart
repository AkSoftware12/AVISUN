import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';

import 'UI/Auth/login_screen.dart';
import 'constants.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  // Check internet connectivity
  Future<void> _checkConnectivity() async {
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
      // Navigate to LoginPage after 5 seconds if connected
      Timer(Duration(seconds: 5), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      });
    }
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
              _checkConnectivity();  // Retry connectivity check
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
            AppAssets.logo,
            width: MediaQuery.of(context).size.width * 0.5, // Responsive width
            height: MediaQuery.of(context).size.height * 0.3, // Responsive height
            fit: BoxFit.contain,
          )
              : const CircularProgressIndicator(), // Show loading spinner if not connected
        ),
      ),
    );
  }
}