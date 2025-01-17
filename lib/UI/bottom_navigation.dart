import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../UI/Dashboard/HomeScreen%20.dart';
import '../constants.dart';
import '../strings.dart';
import 'Attendance/AttendanceScreen.dart';
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

  // List of screens
  final List<Widget> _screens = [
    HomeScreen(),
    AttendanceScreen(),
    LibraryScreen(),
    FeesScreen(),
    ProfileScreen(),
  ];

  // List of titles corresponding to the screens
  final List<String> _titles = [
    AppStrings.homeLabel,
    AppStrings.attendanceLabel,
    AppStrings.libraryLabel,
    AppStrings.feesLabel,
    AppStrings.profileLabel,
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
        title: Text(_titles[_selectedIndex], style: const TextStyle(color: AppColors.textwhite)), // Use the corresponding title
        backgroundColor: AppColors.primary,
      ),
      body: _screens[_selectedIndex], // Display the selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: AppColors.primary,
        selectedItemColor: AppColors.textwhite,
        unselectedItemColor: AppColors.secondary,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: AppStrings.homeLabel,
            backgroundColor: AppColors.primary,
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.clock),
            label: AppStrings.attendanceLabel,
            backgroundColor: AppColors.primary,
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.book_fill),
            label: AppStrings.libraryLabel,
            backgroundColor: AppColors.primary,
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.money_dollar),
            label: AppStrings.feesLabel,
            backgroundColor: AppColors.primary,
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_alt_circle_fill),
            label: AppStrings.profileLabel,
            backgroundColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

