
import 'dart:io';
import 'dart:convert';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:upgrader/upgrader.dart';

import 'DarkMode/dark_mode.dart';
import 'HomeBottom/home_bootom_teacher.dart';
import 'LoginPage/login_page.dart';



class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

// const kWebRecaptchaSiteKey = '6Lemcn0dAAAAABLkf6aiiHvpGD6x-zF3nOSDU2M8';

Future main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await Upgrader.clearSavedSettings();

  Platform.isAndroid ? await Firebase.initializeApp(
    options: kIsWeb || Platform.isAndroid
        ? const FirebaseOptions(
      apiKey: 'AIzaSyAzLFIe_FoYRjCA8-R6e32SuoSm1gE70tQ',
      appId: '1:750843560873:android:36c773f54896a646617ab8',
      messagingSenderId: '750843560873',
      projectId: 'ks-add',
      storageBucket: "ks-add.appspot.com",
    )
        : null,
  ) : await Firebase.initializeApp();

  // Lock orientation to portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await FirebaseAppCheck.instance.activate();

  // await FirebaseAppCheck.instance
  // // Your personal reCaptcha public key goes here:
  //     .activate(
  //   androidProvider: AndroidProvider.debug,
  //   appleProvider: AppleProvider.debug,
  //   // webProvider: ReCaptchaV3Provider(kWebRecaptchaSiteKey),
  // );

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child:  MyApp(),
    ),
  );

  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  final RouteObserver<PageRoute> _routeObserver = RouteObserver();

  MyApp({super.key,});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(
    //   SystemUiOverlayStyle(
    //     statusBarColor: primaryColor, // Set the color you want
    //     systemNavigationBarColor: Colors.blue, // Navigation bar color
    //     systemStatusBarContrastEnforced: false, // For contrast
    //   ),
    // );
    return   Portal(
      child: Provider.value(
        value: _routeObserver,
        child:ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          // Use builder only if you need to use library outside ScreenUtilInit context
          builder: (_ , child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home:  child,
            );
          },
          child:  AuthenticationWrapper(),
        ),

      ),
    );

  }
}






class AuthenticationWrapper extends StatefulWidget {


  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Check if user credentials exist
    bool loggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (loggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeBottom(),
        ),
      );
    }
    else {
      // If user is not logged in, navigate to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Center(
        child: Text('Current Version: \nPlay Store Version: '),
      ),
    );
  }

}







