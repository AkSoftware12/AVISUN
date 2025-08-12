import 'package:avi/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import '../CommonCalling/progressbarWhite.dart';
import 'message_psge.dart';
import 'package:flutter_html/flutter_html.dart';

class MessageMainScreen extends StatefulWidget {
  @override
  State<MessageMainScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageMainScreen> {
  List<dynamic>? messages;
  Map<String, dynamic>? studentData;
  Map<String, dynamic>? instruction;
  bool isLoading = true;
  final staticAnchorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('newusertoken');
    print("token: $token");

    final response = await http.get(
      Uri.parse(ApiRoutes.getProfileNewUser),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        messages = data['messages'];
        studentData = data['student'];
        instruction = data['instruction'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: isLoading
          ? WhiteCircularProgressWidget()
          : messages == null || messages!.isEmpty
          ? _buildEmptyState()
          : CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130.sp,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.secondary,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildProfileHeader(),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildNewMessageCard(),
          ),
          // Add message list here if needed
        ],
      ),
    );
  }



  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary, // Ensure AppColors.secondary is a vibrant color
            AppColors.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft, // Changed for a more dynamic gradient
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Image with Animation
          Hero(
            tag: 'profile_image',
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: 80.h,
              width: 80.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.r), // Slightly larger radius for modern look
                border: Border.all(color: Colors.white, width: 2.sp),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12.r,
                    offset: Offset(0, 6.h),
                  ),
                ],
              ),
              child: ClipRRect( // Changed to ClipRRect for rounded corners
                borderRadius: BorderRadius.circular(15.r),
                child: Image.network(
                  studentData?['picture_data'] ?? '',
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                        color: Colors.white70,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/no_image.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          // User Info with Subtle Animation
          Expanded(
            child: AnimatedOpacity(
              opacity: studentData != null ? 1.0 : 0.0,
              duration: Duration(milliseconds: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome ',
                    style: GoogleFonts.montserrat(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    studentData?['name'] ?? 'N/A',
                    style: GoogleFonts.montserrat(
                      fontSize: 16.sp, // Slightly larger for emphasis
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'P/O ${studentData?['father_name'] ?? ''} (${studentData?['class_name'] ?? ''})',
                    style: GoogleFonts.montserrat(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildNewMessageCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MessageListScreen(),
            ),
          );
        },
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal:10.w, vertical: 40.h),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(35.r),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.secondary.withOpacity(0.1), AppColors.secondary.withOpacity(0.1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(width: 1.sp,color: Colors.pink.shade100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10.r,
                          offset: Offset(0, 5.h),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'New Messages',
                              style: GoogleFonts.montserrat(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            AnimatedContainer(
                              duration: Duration(milliseconds: 500),
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child:Text(
                                '${messages?.length ?? 0} ',
                                style: GoogleFonts.montserrat(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.blueAccent,
                                ),
                              )
                  
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 30.r,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Icon(
                            Icons.message,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Align(
                    alignment: Alignment.topLeft,
                      child: Padding(
                        padding:  EdgeInsets.only(top: 18.sp),
                        child: Text(
                          'Interaction',
                          style: GoogleFonts.montserrat(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                  ),
                  Align(
                    alignment: Alignment.topLeft,
                      child: Padding(
                        padding:  EdgeInsets.only(top: 0.sp),
                        child:Card(
                          child:SingleChildScrollView(
                            child: Html(
                              anchorKey: staticAnchorKey,
                              data: instruction?['description'].toString() ?? '',
                              style: {
                                "table": Style(
                                  backgroundColor: const Color.fromARGB(0x50, 0xee, 0xee, 0xee),
                                ),
                                "th": Style(
                                  padding: HtmlPaddings.all(6),
                                  backgroundColor: Colors.grey,
                                ),
                                "td": Style(
                                  padding: HtmlPaddings.all(6),
                                  border: const Border(bottom: BorderSide(color: Colors.grey)),
                                ),
                                'h5': Style(maxLines: 2, textOverflow: TextOverflow.ellipsis),
                                'flutter': Style(
                                  display: Display.block,
                                  fontSize: FontSize(5, Unit.em),
                                ),
                                ".second-table": Style(
                                  backgroundColor: Colors.transparent,
                                ),
                                ".second-table tr td:first-child": Style(
                                  fontWeight: FontWeight.bold,
                                  textAlign: TextAlign.end,
                                ),
                              },
                              extensions: [
                                TagWrapExtension(
                                    tagsToWrap: {"table"},
                                    builder: (child) {
                                      return SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: child,
                                      );
                                    }),

                                TagExtension.inline(
                                  tagsToExtend: {"bird"},
                                  child: const TextSpan(text: "🐦"),
                                ),
                                TagExtension(
                                  tagsToExtend: {"flutter"},
                                  builder: (context) => CssBoxWidget(
                                    style: context.styledElement!.style,
                                    child: FlutterLogo(
                                      style: context.attributes['horizontal'] != null
                                          ? FlutterLogoStyle.horizontal
                                          : FlutterLogoStyle.markOnly,
                                      textColor: context.styledElement!.style.color!,
                                      size: context.styledElement!.style.fontSize!.value,
                                    ),
                                  ),
                                ),
                                ImageExtension(
                                  handleAssetImages: false,
                                  handleDataImages: false,
                                  networkDomains: {"flutter.dev"},
                                  child: const FlutterLogo(size: 36),
                                ),
                                ImageExtension(
                                  handleAssetImages: false,
                                  handleDataImages: false,
                                  networkDomains: {"mydomain.com"},
                                  networkHeaders: {"Custom-Header": "some-value"},
                                ),

                              ],
                              onLinkTap: (url, _, __) {
                                debugPrint("Opening $url...");
                              },
                              onCssParseError: (css, messages) {
                                debugPrint("css that errored: $css");
                                debugPrint("error messages:");
                                for (var element in messages) {
                                  debugPrint(element.toString());
                                }
                                return '';
                              },
                            ),
                          ),



//                           Html(
//                             data: instruction?['description'].toString() ?? '',
//                             extensions: [
//                               TagExtension(
//                                 tagsToExtend: {"flutter"},
//                                 child: const FlutterLogo(),
//                               ),
//                             ],
//                             style: {
//                               "p.fancy": Style(
//                                 textAlign: TextAlign.center,
//                                 padding: HtmlPaddings.all(16),
//                                 backgroundColor: Colors.grey[200], // Changed from Colors.white to light gray
//                                 color: Colors.black, // Changed from Colors.white to black
//                                 margin: Margins(left: Margin(50, Unit.px), right: Margin.auto()),
//                                 width: Width(300, Unit.px),
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: FontSize(20, Unit.px),
//                                 fontFamily: GoogleFonts.poppins().fontFamily, // Google Font: Roboto
// // Set text size to 15 pixels
//                               ),
//                             },
//                           ),
                        ),



                      ),

                  ),
                ],
              ),
            ),
            Container(
              height: 100.sp, // Sets the height to 50 scaled pixels
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                    70.sp,
                  ), // Rounds the top-left corner
                ),
                border: Border(
                  left: BorderSide(
                    color: Colors.pink.shade100, // Border color for left side
                    width: 1.sp, // Border width for left side
                  ),
                  top: BorderSide(
                    color: Colors.pink.shade100, // Border color for top side
                    width: 1.sp, // Border width for top side
                  ),
                ),
              ),
              // Add other properties like child, width, color, etc., as needed
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: AppColors.secondary,
      highlightColor:AppColors.secondary,
      child: Column(
        children: [
          Container(
            height: 200.h,
            color: AppColors.secondary,
          ),
          SizedBox(height: 20.h),
          Container(
            height: 100.h,
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.message_outlined,
            size: 60.sp,
            color: Colors.white70,
          ),
          SizedBox(height: 16.h),
          Text(
            'No messages found.',
            style: GoogleFonts.montserrat(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start a conversation now!',
            style: GoogleFonts.montserrat(
              fontSize: 14.sp,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}