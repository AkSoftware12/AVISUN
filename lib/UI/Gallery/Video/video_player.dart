import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayer extends StatefulWidget {
  final String url;
  final String title;
  final int? videoId;
  final String videoStatus; // "locked" or "unlocked"

  const VideoPlayer({
    super.key,
    required this.url,
    required this.title,
    required this.videoId,
    required this.videoStatus,
  });

  @override
  State<VideoPlayer> createState() => _VideoPlayerYoutubeState();
}

class _VideoPlayerYoutubeState extends State<VideoPlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.url)!,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text('Video', style: TextStyle(color: Colors.white)),
          ),
          Center(
            child: YoutubePlayerBuilder(
              player: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.red,
              ),
              builder: (context, player) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Centers vertically
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(0.0), // Adds some spacing
                        child: player,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),


        ],
      ),
    );
  }
}
