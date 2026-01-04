import 'package:coach_life/view/widgets/video_player_widget.dart';
import 'package:flutter/material.dart';

class VideoPlayerScreen extends StatelessWidget {
  final String videoUrl;
  const VideoPlayerScreen({Key? key, required this.videoUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: VideoPlayerWidget(
          videoUrl: videoUrl,
          parentConstraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
            maxWidth: MediaQuery.of(context).size.width
          ),
        )
      ),
    );
  }
}