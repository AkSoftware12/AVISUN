import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../splash_sreen.dart';
import 'UI/Auth/login_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

import 'UI/Notification/notification.dart';

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid ? await Firebase.initializeApp(
    options: kIsWeb || Platform.isAndroid
        ? const FirebaseOptions(
      apiKey: 'AIzaSyBhuh_2exvng2cYi1-WVG8AWFGFgLjRYQM',
      appId: '1:1012918033516:android:0b6718b40f48b55cb84c49',
      messagingSenderId: '1012918033516',
      projectId: 'cjm-ambala',
      storageBucket: "cjm-ambala.firebasestorage.app",
    )
        : null,
  ) : await Firebase.initializeApp();
  NotificationService.initNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      // Use builder only if you need to use library outside ScreenUtilInit context
      builder: (_ , child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home:  SplashScreen(),
        );
      },
    );

  }
}




class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// **🔹 Initialize Notifications**
  static Future<void> initNotifications() async {
    // **Request Permission for Push Notifications**
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("✅ Push Notifications Enabled");

      // **Get FCM Token**
      String? token = await _firebaseMessaging.getToken();
      print("FCM Token: $token"); // Send this to your server

      // **Handle Incoming Notifications**
      FirebaseMessaging.onMessage.listen(_onMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
      FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

      // **Initialize Local Notifications**
      _initLocalNotifications();
    } else {
      print("❌ Push Notifications Denied");
    }
  }

  /// **🔹 Handle Foreground Notifications**
  static void _onMessage(RemoteMessage message) {
    print("📩 Foreground Notification: ${message.notification?.title}");
    _showLocalNotification(message);
  }

  /// **🔹 Handle Notification Click**
  static void _onMessageOpenedApp(RemoteMessage message) {
    print("📩 Notification Clicked: ${message.notification?.title}");

    // **Navigate to a Specific Screen**
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => NotificationScreen()),
    // );
    // Navigate to the relevant screen based on message.data
  }

  /// **🔹 Handle Background Notifications**
  static Future<void> _onBackgroundMessage(RemoteMessage message) async {
    print("📩 Background Notification: ${message.notification?.title}");
  }

  /// **🔹 Initialize Local Notifications**
  static void _initLocalNotifications() {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    _flutterLocalNotificationsPlugin.initialize(settings);
  }

  /// **🔹 Show Local Notification**
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channelId', 'channelName',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails generalNotificationDetails =
    NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      generalNotificationDetails,
    );
  }
}
