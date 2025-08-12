import 'package:avi/NewUserBottombarPage/new_user_profile_page.dart';
import 'package:avi/NewUserBottombarPage/new_user_payment_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import '../utils/upgrader_config.dart';
import '../UI/Gallery/Album/album.dart';
import '../constants.dart';
import '../strings.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'message_main.dart';
import 'message_psge.dart';



class NewUserBottombarPage extends StatefulWidget {

  const NewUserBottombarPage({super.key,});
  @override
  _BottomNavBarScreenState createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<NewUserBottombarPage> {
  int _selectedIndex = 0;
  Map<String, dynamic>? studentData;
  bool isLoading = true;

  // List of screens
  final List<Widget> _screens = [

    MessageMainScreen(),
    // PayPage(),
    NewUserPaymentScreen(),
    GalleryScreen(type: 'NewUser',),
    NewUserProfileScreen(),
  ];



  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  void initState() {
    super.initState();
    fetchStudentData();

  }



  Future<void> fetchStudentData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("Token: $token");

    if (token == null) {
      return;
    }

    final response = await http.get(
      Uri.parse(ApiRoutes.getProfile),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        studentData = data['student'];
        isLoading = false;
        print(studentData);

      });
    } else {
    }
  }


  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: UpgraderConfig.getUpgrader(),
      showIgnore: true,
      showLater: true,
      showReleaseNotes: false,
      shouldPopScope: () => false,
      cupertinoButtonTextStyle: TextStyle(
          color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13.sp),
      barrierDismissible: true,
      dialogStyle: UpgradeDialogStyle.cupertino,
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(

          backgroundColor: AppColors.secondary,
          drawerEnableOpenDragGesture: false,


          body: _screens[_selectedIndex], // Display the selected screen
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.red.shade900,
            selectedItemColor: Colors.white,
            unselectedItemColor: AppColors.grey,
            showSelectedLabels: true,  // ✅ Ensures selected labels are always visible
            showUnselectedLabels: true, // ✅ Ensures unselected labels are also visible
            type: BottomNavigationBarType.fixed,
            items:  <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.chat_bubble_text),
                label:'Messages',
                backgroundColor: AppColors.primary,
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.currency_rupee),
                label: AppStrings.feesLabel,
                backgroundColor: AppColors.primary,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.photo),
                label: 'Gallery',
                backgroundColor: AppColors.primary,
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.person_alt_circle_fill),
                label: AppStrings.profileLabel,
                backgroundColor: AppColors.primary,
              ),
            ],
          ),

        ),


      ),

    );


  }
}

