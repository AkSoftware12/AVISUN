import 'package:avi/HexColorCode/HexColor.dart';
import 'package:avi/PaymentGateway/PayButton/pay_button.dart';
import 'package:avi/UI/Attendance/AttendanceScreen.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrollable_clean_calendar/controllers/clean_calendar_controller.dart';
import 'package:scrollable_clean_calendar/scrollable_clean_calendar.dart';
import 'package:scrollable_clean_calendar/utils/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../../constants.dart';
import '../Assignment/assignment.dart';
import '../Auth/login_screen.dart';
import '../Gallery/gallery_tab.dart';
import '../HomeWork/home_work.dart';
import '../Leaves/leaves_tab.dart';
import '../Notice/notice.dart';
import '../Report/report_card.dart';
import '../Subject/subject.dart';
import '../TimeTable/time_table.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../bottom_navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? studentData;
  List assignments = []; // Declare a list to hold API data
  bool isLoading = true;
  late CleanCalendarController calendarController;
  final List<Map<String, String>> items = [
    {
      'name': 'Assignments',
      'image': 'assets/assignments.png',
    },
    {
      'name': 'Time Table',
      'image': 'assets/watch.png',
    },
    {
      'name': 'Messages',
      'image': 'assets/home_work.png',
    },
    {
      'name': 'Attendance',
      'image': 'assets/calendar_attendance.png',
    },
    // {
    //   'name': 'Subject',
    //   'image': 'assets/physics.png',
    // },
    // {
    //   'name': 'Leaves',
    //   'image': 'assets/deadline.png',
    // },
    {
      'name': 'Activity Calendar',
      'image': 'assets/calendar_activity.png',
    },
    {
      'name': 'Gallery',
      'image': 'assets/gallery.png',
    },
    // {
    //   'name': 'Report Card',
    //   'image': 'assets/report.png',
    // },

  ];

  @override
  void initState() {
    super.initState();
    calendarController = CleanCalendarController(
      minDate: DateTime.now().subtract(const Duration(days: 30)),
      maxDate: DateTime.now().add(const Duration(days: 365)),
    );
    fetchStudentData();
    fetchDasboardData();
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
        print(studentData);
      });
    } else {
      // _showLoginDialog();
    }
  }

  Future<void> fetchDasboardData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("Token: $token");

    if (token == null) {
      _showLoginDialog();
      return;
    }

    final response = await http.get(
      Uri.parse(ApiRoutes.getDashboard),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        assignments = data['data']['assignments'];
        isLoading = false;
        print(assignments);
      });
    } else {
      // _showLoginDialog();
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,

      // appBar: AppBar(
      //   backgroundColor: AppColors.secondary,
      //   title: Column(
      //     children: [
      //       _buildAppBar(),
      //     ],
      //   ),
      //   actions: [
      //     Padding(
      //       padding: const EdgeInsets.all(15.0),
      //       child: GestureDetector(
      //           onTap: () {},
      //           child: Icon(
      //             Icons.notification_add,
      //             size: 26,
      //             color: Colors.white,
      //           )),
      //     )
      //
      //     // Container(child: Icon(Icons.ice_skating)),
      //   ],
      // ),
      body: isLoading
          ? const Center(
              child: CupertinoActivityIndicator(radius: 20),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CarouselExample(),
                  SizedBox(height: 10),

                  CarouselFees(
                    status: 'due',
                    dueDate: '',
                    onPayNow: () {
                      // print("Processing payment for ₹${fess[index]['to_pay_amount']}");

                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => HomeGateway()),
                      // );
                    },
                    custFirstName: studentData?['student_name']?? '',
                    custLastName: 'N/A',
                    mobile: studentData?['contact_no']??'',
                    email:studentData?['contact_mail']??'',
                    address: studentData?['address']??'',
                    payDate: '',
                    dueAmount: '0',

                  ),

                  // _buildsellAll('Promotions', 'See All'),

                  // PromotionCard(),
                  // _buildWelcomeHeader(),
                  const SizedBox(height: 20),
                  // _buildsellAll('Promotions', 'See All'),

                  _buildsellAll('Category', ''),

                  _buildGridview(),
                  const SizedBox(height: 10),

                  _buildsellAll('Assignment', ''),
                  _buildListView(),

                  Container(
                    height: 220,
                    width: double.infinity,
                    child: Image.network(
                      'https://cjmambala.in/images/building.png',
                      fit: BoxFit.fill,
                    ),
                  ),

                  Divider(
                    thickness: 1.sp,
                    color: Colors.grey,
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
              Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textwhite,
                ),
              ),
              Text(
                studentData!['student_name'] ?? 'Student',
                style: TextStyle(
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
              studentData?['student_name'] ?? 'Student',
              // Fallback to 'Student' if null
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

  Widget _buildGridview() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: items.length,
        // Kitne bhi items set kar sakte hain
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (items[index]['name'] == 'Assignments') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return AssignmentListScreen();
                    },
                  ),
                );
              } else if (items[index]['name'] == 'Subject') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return SubjectScreen();
                    },
                  ),
                );
              } else if (items[index]['name'] == 'Gallery') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return GalleryVideoTabScreen();
                    },
                  ),
                );
              } else if (items[index]['name'] == 'Leaves') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return LeavesTabScreen();
                    },
                  ),
                );
              } else if (items[index]['name'] == 'Attendance') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return AttendanceCalendarScreen(title: 'Attendance',);
                    },
                  ),
                );
              }



              else if (items[index]['name'] == 'Report Card') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ReportCardScreen();
                    },
                  ),
                );
              } else if (items[index]['name'] == 'Activity Calendar') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return CalendarScreen(title: 'Activity Calendar',);
                    },
                  ),
                );
              } else if (items[index]['name'] == 'Time Table') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return TimeTableScreen();
                    },
                  ),
                );
              } else if (items[index]['name'] == 'Messages') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return HomeWorkScreen(title: 'Messages',);
                    },
                  ),
                );
              }
            },
            child: Card(
              elevation: 5,
              color: AppColors.primary,
              // decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(10)
              // ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      items[index]['image']!,
                      height: 50, // Adjust the size as needed
                      width: 50,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      items[index]['name']!,
                      style: GoogleFonts.montserrat(
                        textStyle: Theme.of(context).textTheme.displayLarge,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        fontStyle: FontStyle.normal,
                        color: AppColors.textwhite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListView() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: assignments.length, // Number of items in the list
        itemBuilder: (context, index) {
          final assignment = assignments[index];

          String description =
              html_parser.parse(assignment['description']).body?.text ?? '';

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return AssignmentListScreen();
                  },
                ),
              );
            },
            child: Card(
              elevation: 5,
              color: AppColors.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: Colors.grey.shade300, // Border color
                  width: 1.5, // Border width
                ), // Rounded corners
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: HexColor('#f2888c'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: Colors.grey.shade300, // Border color
                      width: 1, // Border width
                    ), // Rounded corners
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(8.0),
                    leading: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: AppColors.textwhite,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}', // Displaying the index number
                          style: GoogleFonts.montserrat(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textblack,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      assignments[index]['title'].toString().toUpperCase(),
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textwhite,
                      ),
                    ),
                    subtitle: Text(
                      description,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade300,
                      ),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios,
                        color: Colors.white, size: 25),
                    // Optional arrow icon
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return AssignmentListScreen();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildsellAll(String title, String see) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 15, top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(
              textStyle: Theme.of(context).textTheme.displayLarge,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.normal,
              color: AppColors.textwhite,
            ),
          ),
          Text(
            see,
            style: GoogleFonts.montserrat(
              textStyle: Theme.of(context).textTheme.displayLarge,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.normal,
              color: AppColors.textwhite,
            ),
          ),
        ],
      ),
    );
  }
}


class CarouselExample extends StatefulWidget {
  @override
  _CarouselExampleState createState() => _CarouselExampleState();
}

class _CarouselExampleState extends State<CarouselExample> {
  final List<String> imgList = [
    'https://cjmambala.in/slider/Slider2025_2.png',
    'https://cjmambala.in/slider/Slider2025_5.png',
    'https://cjmambala.in/slider/Slider2025_7.png',
    'https://cjmambala.in/images/building.png',
  ];

  // final List<String> imgList = [
  //   'https://www.cjmshimla.org/Images/sld1.jpg',
  //   'https://www.cjmshimla.org/Images/sld3.jpg',
  //   'https://www.cjmshimla.org/Images/sld4.jpg',
  //   'https://www.cjmshimla.org/Images/sld5.jpg',
  //
  // ];

  int _currentIndex = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Carousel
        SizedBox(
          width: MediaQuery.of(context).size.width, // Ensure proper width
          child: CarouselSlider(
            controller: _controller,
            options: CarouselOptions(
              height: 170,
              autoPlay: true,
              viewportFraction: 1,
              enableInfiniteScroll: true,
              autoPlayInterval: Duration(seconds: 2),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              scrollDirection: Axis.horizontal,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            items: imgList.map((item) {
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: GestureDetector(
                  onTap: () {
                    print('Image Clicked: $item');
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      item,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                            child:
                                CircularProgressIndicator( color: Colors.white,)); // Show loader while loading
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                            child: Icon(Icons.error,
                                color: Colors
                                    .red)); // Show error icon if image fails
                      },
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Dots Indicator
        SizedBox(height: 1),
        AnimatedSmoothIndicator(
          activeIndex: _currentIndex,
          count: imgList.length,
          effect: ExpandingDotsEffect(
            dotHeight: 8,
            dotWidth: 8,
            activeDotColor: Colors.redAccent,
            dotColor: Colors.grey.shade400,
          ),
          onDotClicked: (index) {
            _controller.animateToPage(index);
          },
        ),
      ],
    );
  }
}

class CarouselFees extends StatelessWidget {
  final String dueAmount;
  final VoidCallback onPayNow;
  final String status;
  final String dueDate;
  final String payDate;
  final String custFirstName; //optional
  final String custLastName; //optional
  final String mobile; //optional
  final String email; //optional
  final String address;

  final List<Map<String, String>> imgList = [
    {
      'image': 'https://cjmambala.in/images/building.png',
      'text': 'Welcome to CJM Ambala'
    },
    {
      'image': 'https://cjmambala.in/images/building.png',
      'text': 'Best School for Excellence'
    },
    {
      'image': 'https://cjmambala.in/images/building.png',
      'text': 'Learn, Grow & Succeed'
    },
    {
      'image': 'https://cjmambala.in/images/building.png',
      'text': 'Join Our Community'
    },
  ];

   CarouselFees({super.key, required this.dueAmount, required this.onPayNow, required this.status, required this.dueDate, required this.payDate, required this.custFirstName, required this.custLastName, required this.mobile, required this.email, required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: CarouselSlider(
          options: CarouselOptions(
            height: 180,
            autoPlay: false,
            viewportFraction: 1,
            enableInfiniteScroll: true,
            autoPlayInterval: Duration(seconds: 1),
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            scrollDirection: Axis.horizontal,
          ),
          items: imgList.map((item) {
            return DueAmountCard(
              dueAmount: dueAmount,
              status: status,
              dueDate: dueDate,
              onPayNow: () {
                // print("Processing payment for ₹${fess[index]['to_pay_amount']}");

                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => HomeGateway()),
                // );
              },
              custFirstName: custLastName,
              custLastName: 'N/A',
              mobile: mobile,
              email:email,
              address: address,
              payDate: payDate,
            );

            //   GestureDetector(
            //   onTap: () {
            //     print('Image Clicked: ${item['text']}');
            //   },
            //   child: Padding(
            //     padding: const EdgeInsets.all(5.0),
            //     child: Container(
            //       width: double.infinity,
            //       padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            //       decoration: BoxDecoration(
            //         color: Colors.black.withOpacity(0.6),
            //         borderRadius: BorderRadius.circular(5),
            //       ),
            //       child: Text(
            //         item['text']!,
            //         textAlign: TextAlign.center,
            //         style: TextStyle(
            //           color: Colors.white,
            //           fontSize: 16,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //     ),
            //   ),
            // );
          }).toList(),
        ),
      ),
    );
  }
}

class DueAmountCard extends StatelessWidget {
  final String dueAmount;
  final VoidCallback onPayNow;
  final String status;
  final String dueDate;
  final String payDate;
  final String custFirstName; //optional
  final String custLastName; //optional
  final String mobile; //optional
  final String email; //optional
  final String address;

  DueAmountCard({required this.dueAmount, required this.onPayNow, required this.status, required this.dueDate, required this.payDate, required this.custFirstName, required this.custLastName, required this.mobile, required this.email, required this.address});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.red, Colors.white, Colors.red], // Gradient Colors
          ),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title
            Text(
              "Due Amount",
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: HexColor('#f62c13'), // Highlight in Yellow
              ),
            ),
            SizedBox(height: 8),

            // Amount
            Text(
              "₹ ${dueAmount}",
              style: GoogleFonts.montserrat(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: HexColor('#f62c13'), // Highlight in Yellow
              ),
            ),
            SizedBox(height: 12),

            // Pay Now Button
            SizedBox(
              width: double.infinity,
              child:CommonNdpsButton(buttonText: "Pay Now",
                status: status,
                amount: '1',
                // amount: dueAmount,
                custFirstName: custFirstName,
                custLastName: custLastName,
                mobile: mobile, email: email,
                address: address,
              ),



              // ElevatedButton(
              //   onPressed: onPayNow,
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.white, // White button for contrast
              //     padding: EdgeInsets.symmetric(vertical: 12),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //   ),
              //   child: Text(
              //     "Pay Now",
              //     style: GoogleFonts.montserrat(
              //       fontSize: 16,
              //       fontWeight: FontWeight.w600,
              //       color: Colors.redAccent, // Matching gradient color
              //     ),
              //   ),
              // ),
            ),
          ],
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
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.textwhite, // You can change the color as needed
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Image.asset(
                AppAssets.logo,
                color: AppColors.textwhite,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 18.0),
              child: Column(
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
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: HexColor('#e16a54'),
                        // You can change the color as needed
                        width: 1,
                      ),
                    ),
                    child: Padding(
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
            ),
          ],
        ),
      ),
    );
  }
}
