import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF007BFF); // Example primary color (blue)
  static const Color secondary = Color(0xFF6C757D); // Secondary color (gray)
  static const Color background = Color(0xFFF8F9FA); // Light background color
  static const Color textblack = Color(0xFF212529); // Dark text color
    static const Color textwhite = Color.fromARGB(255, 255, 255, 255); // Dark text color
  static const Color error = Color(0xFFDC3545); // Error color (red)
  static const Color success = Color(0xFF28A745); // Success color (green)
}

class AppAssets {
  static const String logo = 'assets/images/logo.png'; 
}

class ApiRoutes {
  static const String baseUrl = "http://192.168.1.3/stb/api";
  static const String login = "$baseUrl/login";
  static const String getProfile = "$baseUrl/student-get";
  static const String studentDashboard = "$baseUrl/dashboard";
}
