
import 'dart:io';
import 'dart:ui';
import 'package:fancy_bottom_navigation_2/fancy_bottom_navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:secure_content/secure_content.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Utils/string.dart';
import '../../Utils/textSize.dart';
import '../Utils/app_colors.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import '../Utils/image.dart';


class HomeBottom extends StatefulWidget {

  const HomeBottom({super.key,});
  @override
  State<HomeBottom> createState() => _HomeBottomNavigationState();
}

class _HomeBottomNavigationState extends State<HomeBottom> {
  int _selectedIndex = 0;
  String nickname = '';
  String photoUrl = '';
  String userEmail = '';
  String contact = '';
  String address = '';
  String bio = '';
  String cityState = '';
  String pin = '';
  GlobalKey bottomNavigationKey = GlobalKey();
  bool _isLoading = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }







  @override
  Widget build(BuildContext context) {

    return  SecureWidget(
      isSecure: true,
      builder: (context, onInit, onDispose) =>    WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: bgColor,
          drawerEnableOpenDragGesture: false,

          appBar:  AppBar(
            leading: Builder(
              builder: (context) =>


                  Padding(
                    padding:  EdgeInsets.all(5.sp),
                    child: GestureDetector(
                        onTap: (){
                          Scaffold.of(context).openDrawer();
                        },
                        child: SizedBox(
                            height: 15.sp,
                            width: 15.sp,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Image.asset('assets/drawer_icon.png',color: Colors.white,),
                            ))

                    ),
                  ),// Ensure Scaffold is in context

            ),






            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(TextSpan(
                  text: '',
                  style:  TextStyle(
                      color: Colors.white, fontSize: 16.sp),
                  children: <TextSpan>[
                    TextSpan(
                      // text: '${nickname}',
                        text: '${AppConstants.appName}',
                        // text: '${'Ravi'}',
                        style:  TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                          }),
                  ],
                )),

                SizedBox(width: 30.sp,),

                CircleAvatar(
                  radius: 20.0, // Set size of the circle
                  backgroundImage: AssetImage(
                    logo, // Replace with your image URL or use AssetImage for local assets
                  ),
                ),

              ],
            ),


            centerTitle: true,
            backgroundColor: bgColor,
          ),


          body: SafeArea(
            top: false,
            child: Container(
              decoration: BoxDecoration(color: bgColor),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [


                    Expanded(
                      child: _getPage(_selectedIndex),
                    ),
                  ],
                ),
              ),
            ),
          ),

          bottomNavigationBar: ClipRRect(
            borderRadius: BorderRadius.only(
              // topLeft: Radius.circular(20.sp),
              // topRight: Radius.circular(20.sp),
            ),
            child: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),

                // BottomNavigationBarItem(
                //   icon: Icon(Icons.calendar_month),
                //   label: 'Previous Papers',
                // ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.subscriptions),
                  label: 'Subscriptions',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey,
              backgroundColor: bgColor,
              type: BottomNavigationBarType.fixed,  // Ensures all items are shown
              selectedLabelStyle: GoogleFonts.radioCanada(
                textStyle: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
              unselectedLabelStyle: GoogleFonts.radioCanada(
                textStyle: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
              showUnselectedLabels: true,  // Show unselected labels
              onTap: _onItemTapped,
            ),
          ),


          // drawer: Drawer(
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.zero,
          //   ),
          //   width: MediaQuery.sizeOf(context).width* .65,
          //   // backgroundColor: Theme.of(context).colorScheme.background,
          //   backgroundColor:primaryColor,
          //   child: Center(
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.start,
          //       children: <Widget>[
          //         // Container(
          //         //   child: Padding(
          //         //     padding: EdgeInsets.only(top: 40.sp, bottom: 10.sp),
          //         //     child: Container(
          //         //       height: 70.sp,
          //         //       decoration: BoxDecoration(
          //         //         color: Colors.white,
          //         //
          //         //         shape: BoxShape.circle,
          //         //       ),
          //         //       child:Image.network(
          //         //         photoUrl ,
          //         //         fit: BoxFit.cover,
          //         //         errorBuilder: (context, error, stackTrace) {
          //         //           return Image.network('https://via.placeholder.com/150', fit: BoxFit.cover);
          //         //         },
          //         //       )
          //         //     ),
          //         //   ),
          //         // ),
          //
          //         Padding(
          //           padding:  EdgeInsets.only(top: 58.sp,bottom: 10.sp),
          //           child: ClipRRect(
          //             borderRadius: BorderRadius.circular(40.sp),
          //             child: SizedBox(
          //               height: 80.sp,
          //               width: 80.sp,
          //               child: Image.network(
          //                 photoUrl.toString(),
          //                 fit: BoxFit.cover,
          //                 errorBuilder: (context, error, stackTrace) {
          //                   // Return a default image widget here
          //                   return Container(
          //                     color: Colors.grey,
          //                     // Placeholder color
          //                     // You can customize the default image as needed
          //                     child: Icon(
          //                       Icons.image,
          //                       color: Colors.white,
          //                     ),
          //                   );
          //                 },
          //               ),
          //             ),
          //           ),
          //         ),
          //
          //         Center(
          //           child: Container(
          //             child: Padding(
          //               padding: EdgeInsets.only(top: 0.sp, bottom: 20.sp),
          //               child: Container(
          //                 decoration: BoxDecoration(
          //                   shape: BoxShape.circle,
          //                 ),
          //                 child: Text(nickname,
          //                   style: GoogleFonts.radioCanada(
          //                     // Replace with your desired Google Font
          //                     textStyle: TextStyle(
          //                       color:  Colors.white,
          //                       fontSize: TextSizes.textmedium,
          //                       // Adjust font size as needed
          //                       fontWeight: FontWeight
          //                           .bold, // Adjust font weight as needed
          //                       // Adjust font color as needed
          //                     ),
          //                   ),),
          //               ),
          //             ),
          //           ),
          //         ),
          //         Padding(
          //           padding:  EdgeInsets.only(left: 15.sp,right: 15.sp),
          //           child: Divider(
          //             color: Colors.grey.shade300,
          //             // Set the color of the divider
          //             thickness: 2.0,
          //             // Set the thickness of the divider
          //             height: 1, // Set the height of the divider
          //           ),
          //         ),
          //
          //         Expanded(
          //           child: ListView(
          //             padding: EdgeInsets.zero,
          //             children: <Widget>[
          //               Padding(
          //                 padding: EdgeInsets.all(8.sp),
          //                 child: Column(
          //                   crossAxisAlignment: CrossAxisAlignment.start,
          //                   mainAxisAlignment: MainAxisAlignment.center,
          //                   children: [
          //                     ListTile(
          //                       title: Text(
          //                         'Download',
          //                         style: GoogleFonts.cabin(textStyle:
          //                         TextStyle(
          //                             color: Colors.white,
          //                             fontSize: 15.sp,
          //                             fontWeight: FontWeight.normal),
          //                         ),
          //                       ),
          //
          //                       trailing:   Container(
          //                           height: 20.sp,
          //                           width: 20.sp,
          //                           color: primaryColor,
          //                           child: Icon(Icons.download,
          //                             color: Colors.white,)),
          //                       onTap: () {
          //                         Navigator.push(
          //                           context,
          //                           MaterialPageRoute(
          //                             builder: (context) {
          //                               return DownloadPdf();
          //                             },
          //                           ),
          //                         );
          //                       },
          //                     ),
          //                     Padding(
          //                       padding:  EdgeInsets.only(left:8.sp,right: 8.sp),
          //                       child: Divider(
          //                         height: 1.sp,
          //                         color: Colors.grey.shade300,
          //                         thickness: 1.sp,
          //                       ),
          //                     ),
          //
          //                     ListTile(
          //                       title: Text(
          //                         'Doubt Status',
          //                         style: GoogleFonts.cabin(textStyle:
          //                         TextStyle(
          //                             color: Colors.white,
          //                             fontSize: 15.sp,
          //                             fontWeight: FontWeight.normal),
          //                         ),
          //                       ),
          //
          //                       trailing:  Container(
          //                           height: 20.sp,
          //                           width: 20.sp,
          //                           child: Image.asset(
          //                             doubt, color: Colors.white,)),
          //                       onTap: () {
          //                         Navigator.push(
          //                           context,
          //                           MaterialPageRoute(
          //                             builder: (context) {
          //                               return DoubtStatusPage();
          //                             },
          //                           ),
          //                         );
          //                       },
          //                     ),
          //                     Padding(
          //                       padding:  EdgeInsets.only(left:8.sp,right: 8.sp),
          //                       child: Divider(
          //                         height: 1.sp,
          //                         color: Colors.grey.shade300,
          //                         thickness: 1.sp,
          //                       ),
          //                     ),
          //
          //
          //                     ListTile(
          //                       title: Text(
          //                         'Doubt Session',
          //                         style: GoogleFonts.cabin(textStyle:
          //                         TextStyle(
          //                             color: Colors.white,
          //                             fontSize: 15.sp,
          //                             fontWeight: FontWeight.normal),
          //                         ),
          //                       ),
          //
          //                       trailing:  Container(
          //                           height: 20.sp,
          //                           width: 20.sp,
          //                           child: Image.asset(
          //                             doubt, color: Colors.white,)),
          //                       onTap: () {
          //                         Navigator.push(
          //                           context,
          //                           MaterialPageRoute(
          //                             builder: (context) {
          //                               return DoubtSessionTabClass();
          //                             },
          //                           ),
          //                         );
          //                       },
          //                     ),
          //                     Padding(
          //                       padding:  EdgeInsets.only(left:8.sp,right: 8.sp),
          //                       child: Divider(
          //                         height: 1.sp,
          //                         color: Colors.grey.shade300,
          //                         thickness: 1.sp,
          //                       ),
          //                     ),
          //
          //                     ListTile(
          //                       title: Text(
          //                         'Orders',
          //                         style: GoogleFonts.cabin(textStyle:
          //                         TextStyle(
          //                             color: Colors.white,
          //                             fontSize: 15.sp,
          //                             fontWeight: FontWeight.normal),
          //                         ),
          //                       ),
          //
          //                       trailing:  Container(
          //                           height: 20.sp,
          //                           width: 20.sp,
          //                           child: Image.asset(
          //                             checklist, color: Colors.white,)),
          //                       onTap: () {
          //                         Navigator.push(
          //                           context,
          //                           MaterialPageRoute(
          //                             builder: (context) {
          //                               return OrdersPage();
          //                             },
          //                           ),
          //                         );
          //                       },
          //                     ),
          //                     Padding(
          //                       padding:  EdgeInsets.only(left:8.sp,right: 8.sp),
          //                       child: Divider(
          //                         height: 1.sp,
          //                         color: Colors.grey.shade300,
          //                         thickness: 1.sp,
          //                       ),
          //                     ),
          //
          //                     ListTile(
          //                       title: Text(
          //                         'Update Password',
          //                         style: GoogleFonts.cabin(textStyle:
          //                         TextStyle(
          //                             color: Colors.white,
          //                             fontSize: 15.sp,
          //                             fontWeight: FontWeight.normal),
          //                         ),
          //                       ),
          //
          //                       trailing:  Container(
          //                           height: 20.sp,
          //                           width: 20.sp,
          //                           child: Image.asset(
          //                             changePass, color: Colors.white,)),
          //                       onTap: () {
          //                         Navigator.push(
          //                           context,
          //                           MaterialPageRoute(
          //                             builder: (context) {
          //                               return ResetPasswordPage();
          //                             },
          //                           ),
          //                         );
          //                       },
          //                     ),
          //                     Padding(
          //                       padding:  EdgeInsets.only(left:8.sp,right: 8.sp),
          //                       child: Divider(
          //                         height: 1.sp,
          //                         color: Colors.grey.shade300,
          //                         thickness: 1.sp,
          //                       ),
          //                     ),
          //
          //
          //
          //                     ListTile(
          //                       title: Text(
          //                         'Share App',
          //                         style: GoogleFonts.cabin(textStyle:
          //                         TextStyle(
          //                             color: Colors.white,
          //                             fontSize: 15.sp,
          //                             fontWeight: FontWeight.normal),
          //                         ),
          //                       ),
          //
          //                       trailing:  Container(
          //                           height: 20.sp,
          //                           width: 20.sp,
          //                           child: Icon(Icons.share,color: Colors.white,)),
          //                       onTap: () {
          //                         shareContent();
          //
          //                         Navigator.pop(context);
          //                       },
          //                     ),
          //                     Padding(
          //                       padding:  EdgeInsets.only(left:8.sp,right: 8.sp),
          //                       child: Divider(
          //                         height: 1.sp,
          //                         color: Colors.grey.shade300,
          //                         thickness: 1.sp,
          //                       ),
          //                     ),
          //
          //
          //
          //                     ListTile(
          //                       title: Text(
          //                         'Help',
          //                         style: GoogleFonts.cabin(textStyle:
          //                         TextStyle(
          //                             color: Colors.white,
          //                             fontSize: 15.sp,
          //                             fontWeight: FontWeight.normal),
          //                         ),
          //                       ),
          //
          //                       trailing:  Container(
          //                           height: 20.sp,
          //                           width: 20.sp,
          //                           child: Image.asset(
          //                             help, color: Colors.white,)),
          //                       onTap: () {
          //                         Navigator.push(
          //                           context,
          //                           MaterialPageRoute(
          //                             builder: (context) {
          //                               return HelpScreen();
          //                             },
          //                           ),
          //                         );
          //                       },
          //                     ),
          //                     Padding(
          //                       padding:  EdgeInsets.only(left:8.sp,right: 8.sp),
          //                       child: Divider(
          //                         height: 1.sp,
          //                         color: Colors.grey.shade300,
          //                         thickness: 1.sp,
          //                       ),
          //                     ),
          //
          //
          //
          //                     ListTile(
          //                       title: Text(
          //                         'FAQs',
          //                         style: GoogleFonts.cabin(textStyle:
          //                         TextStyle(
          //                             color: Colors.white,
          //                             fontSize: 15.sp,
          //                             fontWeight: FontWeight.normal),
          //                         ),
          //                       ),
          //
          //                       trailing:     Container(
          //                           height: 20.sp,
          //                           width: 20.sp,
          //                           child: Image.asset(faqs)),
          //                       onTap: () {
          //                         Navigator.push(
          //                           context,
          //                           MaterialPageRoute(
          //                             builder: (context) {
          //                               return FaqScreen();
          //                             },
          //                           ),
          //                         );
          //                       },
          //                     ),
          //                     Padding(
          //                       padding:  EdgeInsets.only(left:8.sp,right: 8.sp),
          //                       child: Divider(
          //                         height: 1.sp,
          //                         color: Colors.grey.shade300,
          //                         thickness: 1.sp,
          //                       ),
          //                     ),
          //
          //
          //
          //                     ListTile(
          //                       title: Text(
          //                         'Privacy',
          //                         style: GoogleFonts.cabin(textStyle:
          //                         TextStyle(
          //                             color: Colors.white,
          //                             fontSize: 15.sp,
          //                             fontWeight: FontWeight.normal),
          //                         ),
          //                       ),
          //
          //                       trailing:       Container(
          //                           height: 20.sp,
          //                           width: 20.sp,
          //                           child: Icon(Icons.privacy_tip,
          //                             color: Colors.white,)),
          //                       onTap: () {
          //                         Navigator.push(
          //                           context,
          //                           MaterialPageRoute(
          //                             builder: (context) {
          //                               return WebViewExample(title: 'Privacy',
          //                                 url: 'https://ksadmission.in/privacy-policy',);
          //                             },
          //                           ),
          //                         );
          //                       },
          //                     ),
          //                     Padding(
          //                       padding:  EdgeInsets.only(left:8.sp,right: 8.sp),
          //                       child: Divider(
          //                         height: 1.sp,
          //                         color: Colors.grey.shade300,
          //                         thickness: 1.sp,
          //                       ),
          //                     ),
          //
          //
          //
          //                     ListTile(
          //                       title: Text(
          //                         'Terms & Condition',
          //                         style: GoogleFonts.cabin(textStyle:
          //                         TextStyle(
          //                             color: Colors.white,
          //                             fontSize: 15.sp,
          //                             fontWeight: FontWeight.normal),
          //                         ),
          //                       ),
          //
          //                       trailing: Container(
          //                           height: 20.sp,
          //                           width: 20.sp,
          //                           child: Icon(Icons.event_note_outlined,
          //                             color: Colors.white,)),
          //                       onTap: () {
          //                         Navigator.push(
          //                           context,
          //                           MaterialPageRoute(
          //                             builder: (context) {
          //                               return WebViewExample(
          //                                 title: 'Terms & Condition',
          //                                 url: 'https://ksadmission.in/privacy-policy',);
          //                             },
          //                           ),
          //                         );
          //                       },
          //                     ),
          //                     Padding(
          //                       padding:  EdgeInsets.only(left:8.sp,right: 8.sp),
          //                       child: Divider(
          //                         height: 1.sp,
          //                         color: Colors.grey.shade300,
          //                         thickness: 1.sp,
          //                       ),
          //                     ),
          //
          //
          //
          //                     ListTile(
          //                       title: Text(
          //                         'Join facebook Page',
          //                         style: GoogleFonts.cabin(textStyle:
          //                         TextStyle(
          //                             color: Colors.white,
          //                             fontSize: 15.sp,
          //                             fontWeight: FontWeight.normal),
          //                         ),
          //                       ),
          //
          //                       trailing:   Container(
          //                           height: 20.sp,
          //                           width: 20.sp,
          //                           child:Image.asset('assets/facebook.png')),
          //                       onTap: () async {
          //                         const url = 'https://www.facebook.com/profile.php?id=61560588287955'; // Replace with your Facebook page URL
          //
          //                         if (await canLaunch(url)) {
          //                           await launch(url);
          //                         } else {
          //                           throw 'Could not launch $url';
          //                         }
          //                       },
          //                     ),
          //                     Padding(
          //                       padding:  EdgeInsets.only(left:8.sp,right: 8.sp),
          //                       child: Divider(
          //                         height: 1.sp,
          //                         color: Colors.grey.shade300,
          //                         thickness: 1.sp,
          //                       ),
          //                     ),
          //
          //
          //
          //                     ListTile(
          //                       title: Text(
          //                         'Join Instagram  Page',
          //                         style: GoogleFonts.cabin(textStyle:
          //                         TextStyle(
          //                             color: Colors.white,
          //                             fontSize: 15.sp,
          //                             fontWeight: FontWeight.normal),
          //                         ),
          //                       ),
          //
          //                       trailing:   Container(
          //                           height: 20.sp,
          //                           width: 20.sp,
          //                           child: Image.asset('assets/instagram.png')),
          //                       onTap: () async {
          //                         const url = 'https://www.instagram.com/ks_admission/'; // Replace with your Facebook page URL
          //
          //                         if (await canLaunch(url)) {
          //                           await launch(url);
          //                         } else {
          //                           throw 'Could not launch $url';
          //                         }
          //                       },
          //                     ),
          //                     Padding(
          //                       padding:  EdgeInsets.only(left:8.sp,right: 8.sp),
          //                       child: Divider(
          //                         height: 1.sp,
          //                         color: Colors.grey.shade300,
          //                         thickness: 1.sp,
          //                       ),
          //                     ),
          //
          //
          //                     ListTile(
          //                       title: Text(
          //                         'Join Twitter  Page',
          //                         style: GoogleFonts.cabin(textStyle:
          //                         TextStyle(
          //                             color: Colors.white,
          //                             fontSize: 15.sp,
          //                             fontWeight: FontWeight.normal),
          //                         ),
          //                       ),
          //
          //                       trailing:   Container(
          //                           height: 20.sp,
          //                           width: 20.sp,
          //                           child: Image.asset('assets/twitter.png')),
          //                       onTap: () async {
          //                         const url = 'https://x.com/KS_Admission'; // Replace with your Facebook page URL
          //
          //                         if (await canLaunch(url)) {
          //                           await launch(url);
          //                         } else {
          //                           throw 'Could not launch $url';
          //                         }
          //                       },
          //                     ),
          //                     Padding(
          //                       padding:  EdgeInsets.only(left:8.sp,right: 8.sp),
          //                       child: Divider(
          //                         height: 1.sp,
          //                         color: Colors.grey.shade300,
          //                         thickness: 1.sp,
          //                       ),
          //                     ),
          //
          //
          //                     ListTile(
          //                       title: Text(
          //                         'Youtube Channel',
          //                         style: GoogleFonts.cabin(textStyle:
          //                         TextStyle(
          //                             color: Colors.white,
          //                             fontSize: 15.sp,
          //                             fontWeight: FontWeight.normal),
          //                         ),
          //                       ),
          //
          //                       trailing: Container(
          //                           height: 20.sp,
          //                           width: 20.sp,
          //                           child: Image.asset('assets/youtube.png'))
          //                       ,
          //                       onTap: () async {
          //                         const url = 'https://www.youtube.com/@KSAdmission'; // Replace with your Facebook page URL
          //
          //                         if (await canLaunch(url)) {
          //                           await launch(url);
          //                         } else {
          //                           throw 'Could not launch $url';
          //                         }
          //                       },
          //                     ),
          //                     Padding(
          //                       padding:  EdgeInsets.only(left:8.sp,right: 8.sp),
          //                       child: Divider(
          //                         height: 1.sp,
          //                         color: Colors.grey.shade300,
          //                         thickness: 1.sp,
          //                       ),
          //                     ),
          //
          //
          //                     ListTile(
          //                       title: Text(
          //                         'Official Website',
          //                         style: GoogleFonts.cabin(textStyle:
          //                         TextStyle(
          //                             color: Colors.white,
          //                             fontSize: 15.sp,
          //                             fontWeight: FontWeight.normal),
          //                         ),
          //                       ),
          //
          //                       trailing:Container(
          //                           height: 20.sp,
          //                           width: 20.sp,
          //                           child:Image.asset('assets/site.png'))
          //                       ,
          //                       onTap: () async {
          //                         const url = 'https://ksadmission.in/'; // Replace with your Facebook page URL
          //
          //                         if (await canLaunch(url)) {
          //                           await launch(url);
          //                         } else {
          //                           throw 'Could not launch $url';
          //                         }
          //                       },
          //                     ),
          //                     Padding(
          //                       padding:  EdgeInsets.only(left:8.sp,right: 8.sp),
          //                       child: Divider(
          //                         height: 1.sp,
          //                         color: Colors.grey.shade300,
          //                         thickness: 1.sp,
          //                       ),
          //                     ),
          //
          //
          //
          //                     ListTile(
          //                       title: Text(
          //                         'Logout',
          //                         style: GoogleFonts.cabin(textStyle:
          //                         TextStyle(
          //                             color: Colors.white,
          //                             fontSize: 15.sp,
          //                             fontWeight: FontWeight.normal),
          //                         ),
          //                       ),
          //
          //
          //                       trailing: Container(
          //                           height: 20.sp,
          //                           width: 20.sp,
          //                           child: Icon(
          //                             Icons.logout, color: Colors.white,)),
          //
          //                       onTap: () {
          //                         logoutApi(context);
          //                       },
          //                     ),
          //
          //
          //                   ],
          //                 ),
          //               ),
          //
          //
          //
          //
          //
          //
          //               Padding(
          //                 padding: EdgeInsets.only(bottom: 15.sp),
          //               ),
          //
          //
          //
          //             ],
          //           ),
          //         )
          //
          //         // Add more list items as needed
          //       ],
          //     ),
          //   ),
          // ),



        ),
      ),
    );




  }

  _getPage(int page) {
    switch (page) {
      case 0:
        return Container(
          child: Center(child: Text('Home',style: TextStyle(color: Colors.white,fontSize: 25),)),
        );
    // case 1:
    //   return ProfileScreen();
      case 1:
        return Container(
          child: Center(child: Text('Profile',style: TextStyle(color: Colors.white,fontSize: 25),)),
        );
      case 2:
        return Container(
          child: Center(child: Text('Plan',style: TextStyle(color: Colors.white,fontSize: 25),)),
        );
      default:
        return Container(
          child: Center(child: Text('Home',style: TextStyle(color: Colors.white,fontSize: 25),)),
        );
    }
  }
}

