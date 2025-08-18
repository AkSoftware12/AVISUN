import 'package:avi/TecaherUi/UI/Gallery/Video/video_player.dart' show VideoPlayer;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../CommonCalling/data_not_found.dart';
import '../../../../CommonCalling/progressbarWhite.dart';
import '../../../../constants.dart';


class VideoListScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const VideoListScreen({super.key, required this.data});

  @override
  State<VideoListScreen> createState() => _ImageListScreenState();
}

class _ImageListScreenState extends State<VideoListScreen> {
  bool isLoading = false;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors2.primary,
      appBar: AppBar(
        backgroundColor: AppColors2.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.data['album_name'].toString(),
          style: GoogleFonts.montserrat(
            textStyle: Theme.of(context).textTheme.displayLarge,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors2.textwhite,
          ),
        ),
      ),
      body: isLoading
          ? const WhiteCircularProgressWidget()
          : widget.data['album_image'].isEmpty
          ? const Center(child: DataNotFoundWidget(title: 'Image Not Available.'))
          : GridView.builder(
        padding: EdgeInsets.all(3.sp),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 5.0,
          mainAxisSpacing: 5.0,
        ),
        itemCount: widget.data['album_image'].length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayer(
                    url: widget.data['album_image'][index]['video_url'], title: '', videoId: null, videoStatus: '',
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: CachedNetworkImage(
                imageUrl: widget.data['cover_image_url'].toString(),
                fit: BoxFit.cover,
                height: 100.sp,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          );
        },
      ),
    );
  }
}






