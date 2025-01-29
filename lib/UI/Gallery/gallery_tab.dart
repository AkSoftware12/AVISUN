import 'package:avi/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


class GalleryVideoTabScreen extends StatefulWidget {
  @override
  _GalleryVideoTabScreenState createState() => _GalleryVideoTabScreenState();
}

class _GalleryVideoTabScreenState extends State<GalleryVideoTabScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Gallery & Video Gallery",
          style: GoogleFonts.montserrat(
            textStyle: Theme.of(context).textTheme.displayLarge,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.normal,
            color: AppColors.textwhite,
          ),

        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50), // Adjust the height as needed
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white, // Customize the indicator color
            labelColor: Colors.white, // Customize the selected tab label color
            unselectedLabelColor: Colors.grey.shade800, // Customize the unselected tab label color
            indicatorWeight: 3.0, // Thickness of the indicator
            tabs: const [
              Tab(
                icon: Icon(Icons.image),
                text: "Gallery",
              ),
              Tab(
                icon: Icon(Icons.video_collection),
                text: "Video Gallery",
              ),
            ],
          ),
        ),

      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          GalleryScreen(),
          VideoGalleryScreen(),
        ],
      ),
    );
  }
}

class GalleryScreen extends StatelessWidget {
  final List<String> images = [
    'https://api-ap-south-mum-1.openstack.acecloudhosting.com:8080/franciscan/SchImg/CJMAMB/PhotoAlbum/Thumb/Photo_52109.jpg',
    'https://api-ap-south-mum-1.openstack.acecloudhosting.com:8080/franciscan/SchImg/CJMAMB/PhotoAlbum/Thumb/Photo_51578.jpg',
    'https://api-ap-south-mum-1.openstack.acecloudhosting.com:8080/franciscan/SchImg/CJMAMB/PhotoAlbum/Thumb/Photo_455763.jpg',
    'https://api-ap-south-mum-1.openstack.acecloudhosting.com:8080/franciscan/SchImg/CJMAMB/PhotoAlbum/Thumb/Photo_452294.jpg',
    'https://api-ap-south-mum-1.openstack.acecloudhosting.com:8080/franciscan/SchImg/CJMAMB/PhotoAlbum/Thumb/Photo_44857.jpg',
    'https://api-ap-south-mum-1.openstack.acecloudhosting.com:8080/franciscan/SchImg/CJMAMB/PhotoAlbum/Thumb/Photo_450137.jpg',
    'https://api-ap-south-mum-1.openstack.acecloudhosting.com:8080/franciscan/SchImg/CJMAMB/PhotoAlbum/Thumb/Photo_57611.jpg',
    'https://api-ap-south-mum-1.openstack.acecloudhosting.com:8080/franciscan/SchImg/CJMAMB/PhotoAlbum/Thumb/Photo_56392.jpg',
    'https://api-ap-south-mum-1.openstack.acecloudhosting.com:8080/franciscan/SchImg/CJMAMB/PhotoAlbum/Thumb/Photo_524101.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Image.network(
          images[index],
          fit: BoxFit.cover,
        );
      },
    );
  }
}



class VideoGalleryScreen extends StatelessWidget {
  final List<String> videos = [
    'https://youtu.be/2gkPUtNVZuw', // YouTube link
    'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4', // MP4 link
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        return Card(
          child: Column(
            children: [
              Text(
                "Video ${index + 1}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: videos[index].contains('youtu')
                    ? YouTubeVideoPlayer(videoUrl: videos[index]) // YouTube
                    : MP4VideoPlayer(videoUrl: videos[index]), // MP4
              ),
            ],
          ),
        );
      },
    );
  }
}

class YouTubeVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const YouTubeVideoPlayer({required this.videoUrl});

  @override
  _YouTubeVideoPlayerState createState() => _YouTubeVideoPlayerState();
}

class _YouTubeVideoPlayerState extends State<YouTubeVideoPlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    _controller = YoutubePlayerController(
      initialVideoId: videoId!,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.red,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class MP4VideoPlayer extends StatefulWidget {
  final String videoUrl;

  const MP4VideoPlayer({required this.videoUrl});

  @override
  _MP4VideoPlayerState createState() => _MP4VideoPlayerState();
}

class _MP4VideoPlayerState extends State<MP4VideoPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {}); // Refresh when video is ready.
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? GestureDetector(
      onTap: () {
        _controller.value.isPlaying
            ? _controller.pause()
            : _controller.play();
      },
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      ),
    )
        : Center(child: CircularProgressIndicator());
  }
}

