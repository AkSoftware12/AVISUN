import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../strings.dart';
import 'Attendance/AttendanceScreen.dart';
import 'Dashboard/HomeScreen .dart';
import 'Fees/FeesScreen.dart';
import 'Library/LibraryScreen.dart';
import 'Profile/ProfileScreen.dart';

class BottomNavBarScreen extends StatefulWidget {
  final String token;

  const BottomNavBarScreen({super.key, required this.token});
  @override
  _BottomNavBarScreenState createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<BottomNavBarScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    AttendanceScreen(),
    LibraryScreen(),
    FeesScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(AppStrings.welcomeTitle),
        backgroundColor: AppColors.background,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: AppStrings.homeLabel,
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.clock),
            label: AppStrings.attendanceLabel,
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.book_fill),
            label: AppStrings.libraryLabel,
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.money_dollar),
            label: AppStrings.feesLabel,
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_alt_circle_fill),
            label: AppStrings.profileLabel,
          ),
        ],
      ),
    );
  }
}
