import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_clean_calendar/controllers/clean_calendar_controller.dart';
import 'package:scrollable_clean_calendar/scrollable_clean_calendar.dart';
import 'package:scrollable_clean_calendar/utils/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? studentData;
  bool isLoading = true;
  late CleanCalendarController calendarController;

  @override
  void initState() {
    super.initState();
    calendarController = CleanCalendarController(
      minDate: DateTime.now().subtract(const Duration(days: 30)),
      maxDate: DateTime.now().add(const Duration(days: 365)),
    );
    fetchStudentData();
  }

  Future<void> fetchStudentData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("Token: $token");

    if (token == null) {
      _showLoginDialog();
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
      });
    } else {
      _showLoginDialog();
    }
  }

  void _showLoginDialog() {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Session Expired'),
        content: const Text('Please log in again to continue.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pushReplacementNamed(context, '/login'); // Navigate to Login Screen
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
        child: CupertinoActivityIndicator(radius: 20),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            const SizedBox(height: 20),
            SectionCard(
              title: 'Promotions',
              icon: Icons.local_offer,
              content: 'Special promotions and offers for the students.',
              color: AppColors.secondary,
            ),
            SectionCard(
              title: 'Assignments',
              icon: Icons.assignment,
              content: 'Assignments due this week and upcoming tasks.',
              color: AppColors.secondary,
            ),
            SectionCard(
              title: 'Fees',
              icon: Icons.monetization_on,
              content: 'Your upcoming fee payments and history.',
              color: AppColors.secondary,
            ),
            SectionCard(
              title: 'Calendar',
              icon: Icons.calendar_today,
              content: 'View and manage your schedule.',
              isCalendar: true,
              calendarController: calendarController,
              color: AppColors.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: studentData!['photo'] != null
                ? NetworkImage(studentData!['photo'])
                : null,
            child: studentData!['photo'] == null
                ? Image.asset(AppAssets.logo, fit: BoxFit.cover)
                : null,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textwhite,
                ),
              ),
              Text(
                studentData!['student_name'] ?? 'Student',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textwhite,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String content;
  final bool isCalendar;
  final CleanCalendarController? calendarController;
  final color;

  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.content,
    this.isCalendar = false,
    this.calendarController,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: this.color,
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 30, color: Colors.blue),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textwhite),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: const TextStyle(fontSize: 16, color: AppColors.textwhite),
            ),
            if (isCalendar) const SizedBox(height: 16),
            if (isCalendar)
              Container(
                height: 300,
                child: ScrollableCleanCalendar(
                  daySelectedBackgroundColor: AppColors.primary,
                  dayBackgroundColor: AppColors.textwhite,
                  daySelectedBackgroundColorBetween: AppColors.primary,
                  dayDisableBackgroundColor: AppColors.textwhite,
                  dayDisableColor: AppColors.textwhite,
                  calendarController: calendarController!,
                  layout: Layout.DEFAULT,
                  monthTextStyle: const TextStyle(fontSize: 18, color: AppColors.textwhite),
                  weekdayTextStyle: const TextStyle(fontSize: 16, color: AppColors.textwhite),
                  dayTextStyle: const TextStyle(fontSize: 14, color: AppColors.textwhite),
                  padding: const EdgeInsets.all(8.0),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
