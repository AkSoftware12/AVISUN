import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
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
    // fetchStudentData();
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
              Navigator.pushReplacementNamed(
                  context, '/login'); // Navigate to Login Screen
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Column(
          children: [
            _buildAppBar(),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: GestureDetector(
                onTap: () {},
                child: Icon(
                  Icons.notification_add,
                  size: 26,
                  color: Colors.white,
                )),
          )

          // Container(child: Icon(Icons.ice_skating)),
        ],
      ),
      body:
      // isLoading
      //     ? const Center(
      //         child: CupertinoActivityIndicator(radius: 20),
      //       )
      //     :
      SingleChildScrollView(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CarouselExample(),
                  _buildsellAll('Promotions', 'See All'),

                  PromotionCard(),
                  // _buildWelcomeHeader(),
                  const SizedBox(height: 20),

                  Container(
                    height:200, // Give a fixed height to the GridView
                    child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Number of columns
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: 20,
                      itemBuilder: (context, index) {
                        return Container(
                          color: Colors.teal,
                          child: Center(
                            child: Text(
                              'Item $index',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
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

  Widget _buildAppBar() {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          radius: 20,
          backgroundImage: studentData?['photo'] != null
              ? NetworkImage(studentData!['photo'])
              : null,
          child: studentData?['photo'] == null
              ? Image.asset(AppAssets.logo, fit: BoxFit.cover)
              : null,
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome !',
              style: GoogleFonts.montserrat(
                textStyle: Theme.of(context).textTheme.displayLarge,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.normal,
                color: AppColors.textwhite,
              ),
            ),
            Text(
              studentData?['student_name'] ?? 'Student', // Fallback to 'Student' if null
              style: GoogleFonts.montserrat(
                textStyle: Theme.of(context).textTheme.displayLarge,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.normal,
                color: AppColors.textwhite,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildsellAll(String title, String see) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 15, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(
              textStyle: Theme.of(context).textTheme.displayLarge,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.normal,
              color: AppColors.textblack,
            ),
          ),
          Text(
            see,
            style: GoogleFonts.montserrat(
              textStyle: Theme.of(context).textTheme.displayLarge,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.normal,
              color: AppColors.secondary,
            ),
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
        padding: const EdgeInsets.all(10.0),
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
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textwhite),
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
                  monthTextStyle:
                      const TextStyle(fontSize: 18, color: AppColors.textwhite),
                  weekdayTextStyle:
                      const TextStyle(fontSize: 16, color: AppColors.textwhite),
                  dayTextStyle:
                      const TextStyle(fontSize: 14, color: AppColors.textwhite),
                  padding: const EdgeInsets.all(8.0),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CarouselExample extends StatelessWidget {
  final List<String> imgList = [
    'https://img.freepik.com/free-photo/tourist-carrying-luggage_23-2151747482.jpg?t=st=1737117547~exp=1737121147~hmac=30bac46a8ddda5246e6eec8ac2e543f2b1221992e9e5abcf8194c904ca2be631&w=1380',
    'https://img.freepik.com/free-photo/classroom-full-students-with-their-hands-up-air_188544-29240.jpg?t=st=1737117595~exp=1737121195~hmac=dae89739d91d32884066482e2f5da21fce463b94e128a8243fa94220a0117ac1&w=1380',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: CarouselSlider(
          options: CarouselOptions(
            height: 130,
            autoPlay: true,
            initialPage: 10,
            viewportFraction: 1,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlayInterval: Duration(seconds: 3),
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            scrollDirection: Axis.horizontal,
          ),
          items: imgList
              .map((item) => GestureDetector(
                    onTap: () {
                      print('click');
                    },
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(item,
                                fit: BoxFit.cover, width: 1000)),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class PromotionCard extends StatelessWidget {
  const PromotionCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
            color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(AppAssets.logo,color: AppColors.textwhite,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Text(
                  '3D Design \nFundamentals',
                  style: GoogleFonts.montserrat(
                    textStyle: Theme.of(context).textTheme.displayLarge,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                    color: AppColors.textwhite,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),

                Container(
                  width: 100,
                  decoration: BoxDecoration(
                      color: AppColors.yellow,
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child:  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        'Click',
                        style: GoogleFonts.montserrat(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          color: AppColors.textwhite,
                        ),
                      ),
                    ),
                  ),
                )
                
              ],
            ),
            Container()
            
          ],
        ),
      ),
    );
  }
}
