import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../CommonCalling/data_not_found.dart';
import '../../../CommonCalling/progressbarWhite.dart';
import '../../../constants.dart';
import 'ImageFull/image_full.dart';

class ImageListScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const ImageListScreen({super.key, required this.data});

  @override
  State<ImageListScreen> createState() => _ImageListScreenState();
}

class _ImageListScreenState extends State<ImageListScreen> {
  bool isLoading = false;

  void _openFullScreenSlider(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageSlider(
          images: widget.data['album_image'],
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.data['album_name'].toString(),
          style: GoogleFonts.montserrat(
            textStyle: Theme.of(context).textTheme.displayLarge,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textwhite,
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
            onTap: () => _openFullScreenSlider(index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: CachedNetworkImage(
                imageUrl: widget.data['album_image'][index]['image_url_full'].toString(),
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

