import 'dart:async';
import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final BoxConstraints parentConstraints;

  const VideoPlayerWidget({
    super.key, 
    required this.videoUrl,
    required this.parentConstraints
  });

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  Timer? _hideControlsTimer;
  bool _showControls = true;
  bool _isFullScreen = false;
  double _currentPosition = 0;
  double _totalDuration = 1;
  Orientation? _currentOrientation;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _startHideControlsTimer();
    // _currentOrientation = MediaQuery.of(context).orientation;
  }

    @override
    void didChangeDependencies() {
      super.didChangeDependencies();
      // Get orientation after dependencies change
      _currentOrientation = MediaQuery.of(context).orientation;
    }


  void _initializePlayer() async {
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _totalDuration = _controller.value.duration.inMilliseconds.toDouble();
        });
        _controller.addListener(_updatePosition);
        _controller.play();
      });
  }

  void _updatePosition() {
    setState(() {
      _currentPosition = _controller.value.position.inMilliseconds.toDouble();
      if (!_controller.value.isPlaying && _hideControlsTimer != null) {
        _hideControlsTimer?.cancel();
        _showControls = true;
      }
    });
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      if (_controller.value.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideControlsTimer();
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      if (_isFullScreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      } else {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    });
  }

  void _seekToPosition(double position) {
    _controller.seekTo(Duration(milliseconds: position.toInt()));
  }

  void _forward10Seconds() => _controller.seekTo(
    _controller.value.position + const Duration(seconds: 10)
  );

  void _rewind10Seconds() => _controller.seekTo(
    _controller.value.position - const Duration(seconds: 10)
  );

  String _formatDuration(Duration duration) => 
    "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.dispose();
    _hideControlsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final aspectRatio = _isFullScreen 
        ? screenSize.aspectRatio 
        : _controller.value.aspectRatio;

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: _toggleControls,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isFullScreen ? screenSize.width : constraints.maxWidth,
            height: _isFullScreen ? screenSize.height : constraints.maxHeight,
            color: Colors.black,
            child: Stack(
              children: [
                if (_controller.value.isInitialized)
                  Center(
                    child: AspectRatio(
                      aspectRatio: aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                if (_showControls)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.5),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppBar(
                            backgroundColor: Colors.transparent,
                            leading: IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () {
                                if (_isFullScreen) {
                                  _toggleFullScreen();
                                } else {
                                  Get.back();
                                }
                              },
                            ),
                            actions: [
                              IconButton(
                                icon: Icon(
                                  _isFullScreen 
                                      ? Icons.fullscreen_exit 
                                      : Icons.fullscreen,
                                  color: Colors.white,
                                ),
                                onPressed: _toggleFullScreen,
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                SliderTheme(
                                  data: SliderThemeData(
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 6),
                                    activeTrackColor: AppColors.primaryColor,
                                    inactiveTrackColor: Colors.grey,
                                    thumbColor: AppColors.secondaryColor,
                                    trackHeight: 2,
                                  ),
                                  child: Slider(
                                    value: _currentPosition,
                                    min: 0,
                                    max: _totalDuration,
                                    onChanged: (value) => _seekToPosition(value),
                                    onChangeStart: (_) => _hideControlsTimer?.cancel(),
                                    onChangeEnd: (_) => _startHideControlsTimer(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 16, left: 16, bottom: 50),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDuration(_controller.value.position),
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.forward_10, color: Colors.white),
                                            onPressed: _rewind10Seconds,
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              _controller.value.isPlaying
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                              color: Colors.white,
                                            ),
                                            onPressed: () => setState(() {
                                              _controller.value.isPlaying
                                                  ? _controller.pause()
                                                  : _controller.play();
                                            }),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.replay_10, color: Colors.white),
                                            onPressed: _forward10Seconds,
                                          ),
                                        ],
                                      ),
                                      Text(
                                        _formatDuration(_controller.value.duration),
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (!_controller.value.isInitialized)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        );
      },
    );
  }
}