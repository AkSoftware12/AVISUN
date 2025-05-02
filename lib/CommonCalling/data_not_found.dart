import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DataNotFoundWidget extends StatelessWidget {
  final String title;
  const DataNotFoundWidget({
    super.key, required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 450.sp,
        child: Container(
          child: Center(
              child: ClipRRect(
                  borderRadius:
                  BorderRadius.circular(10.sp),
                  child:
                  Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: Center(child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 150.sp,
                                    child: Image.asset('assets/no_attendance.png')),
                                Center(child: Padding(
                                  padding:  EdgeInsets.only(top: 0.sp),
                                  child: Text( title,
                                    style: GoogleFonts.radioCanada(
                                      textStyle: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ))

                              ],
                            ))
                          ),
                        ],
                      ),

                    ],
                  ))),
        ),
      ),
    );
  }
}
