import 'package:avi/HexColorCode/HexColor.dart';
import 'package:flutter/material.dart';

class AppColors {
  // static  Color primary = HexColor('#FF2C2C');
  static  Color primary = Colors.red.shade500;
   static  Color secondary =Colors.red.shade500;
  // static  Color secondary41 =HexColor('#FF2C2C');






  static const Color grey = Color(0xFFAAAEB2); // Secondary color (gray)
  static const Color background = Color(0xFFF8F9FA); // Light background color
  static const Color textblack = Color(0xFF212529); // Dark text color
    static const Color textwhite = Color.fromARGB(255, 255, 255, 255); // Dark text color
  static const Color error = Color(0xFFDC3545); // Error color (red)
  static const Color success = Color(0xFF28A745); // Success color (green)
  static const Color yellow = Color(0xFFCCAB21); // Success color (green)
}

class AppAssets {
  static const String logo = 'assets/images/logo.png'; 
  static const String cjm = 'assets/cjm.png';
  static const String cjmlogo = 'assets/playstore.png';
}

class ApiRoutes {


  // Gallery App url


  // Main App Url
  static const String baseUrl = "https://softcjm.cjmambala.co.in/api";
  static const String baseUrlNewUser = "https://cjmambala.co.in/api";



  static const String downloadUrl = "https://softcjm.cjmambala.co.in/student/fee-receipt/";
  static const String newUserdownloadUrl = "https://cjmambala.co.in/api/fees/";

// Local  App Url


  // static const String baseUrlNewUser = "http://192.168.1.5/cjmweb/api";
  // static const String baseUrl = "http://192.168.1.5/cjm_ambala/api";


  // New Admission Api
  static const String loginNewUser = "$baseUrlNewUser/login";
  static const String getProfileNewUser = "$baseUrlNewUser/student-get";
  static const String orderCreateNewUser  = "$baseUrlNewUser/initiatepayment";
  static const String payFeesNewUser  = "$baseUrlNewUser/payfees";
  static const String admissionDownload  = "$baseUrlNewUser/profile/";





// Student Api


  static const String login = "$baseUrl/login";
  static const String loginstudent = "$baseUrl/loginstudent";
  static const String clear = "$baseUrl/clear";
  static const String getProfile = "$baseUrl/student-get";
  static const String getPhotos = "$baseUrlNewUser/getPhotos";
  static const String getVideos = "$baseUrlNewUser/getVideos";
  static const String getDashboard = "$baseUrl/dashboard";
  static const String getFees = "$baseUrl/get-fees";
  static const String getAssignments = "$baseUrl/get-assignments";
  static const String getTimeTable = "$baseUrl/get-class-routine?day=";
  static const String getSubject = "$baseUrl/get-subjects";
  static const String studentDashboard = "$baseUrl/dashboard";
  static const String uploadAssignment = "$baseUrl/submit-assignments";
  static const String attendance = "$baseUrl/get-attendance-monthly";
  static const String events = "$baseUrl/events";
  static const String getlibrary = "$baseUrl/library-get";
  static const String notifications = "$baseUrl/notifications";
  static const String getBookTypes = "$baseUrl/book-types";
  static const String getBookCategories = "$baseUrl/book-categories";
  static const String getBookPublishers = "$baseUrl/book-publishers";
  static const String getBookSupplier= "$baseUrl/book-supplier";
  static const String getAtomSettings= "$baseUrl/atom-settings";
  static const String orderCreate= "$baseUrl/bulkpay";
  static const String atompay= "$baseUrl/atompay";
  static const String passwordChange= "$baseUrl/change-password";
  static const String updateApk= "$baseUrl/update-apk";
  static const String forgotPassword= "$baseUrl/forgot-password";
  static const String verifyOtp= "$baseUrl/verifyOtp";
  static const String applyleave= "$baseUrl/applyleave";

  static const String getAllMessages = "$baseUrl/messages";
  static const String getUserMessagesConversation = "$baseUrl/messages/conversation/";
  static const String sendMessage = "$baseUrl/messages";
}
