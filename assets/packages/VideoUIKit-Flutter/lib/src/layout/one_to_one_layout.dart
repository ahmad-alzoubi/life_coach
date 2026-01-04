import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:agora_uikit/src/layout/widgets/disabled_video_widget.dart';
import 'package:flutter/material.dart';

class OneToOneLayout extends StatefulWidget {
  final AgoraClient client;

  /// Widget that will be displayed when the local or remote user has disabled it's video.
  final Widget? disabledVideoWidget;

  /// Display the camera and microphone status of a user. This feature is only available in the [Layout.floating]
  final bool? showAVState;

  /// Display the host controls. This feature is only available in the [Layout.floating]
  final bool? enableHostControl;

  /// Render mode for local and remote video
  final RenderModeType? renderModeType;

  const OneToOneLayout({
    Key? key,
    required this.client,
    this.disabledVideoWidget = const DisabledVideoWidget(),
    this.showAVState,
    this.enableHostControl,
    this.renderModeType = RenderModeType.renderModeHidden,
  }) : super(key: key);

  @override
  State<OneToOneLayout> createState() => _OneToOneLayoutState();
}

class _OneToOneLayoutState extends State<OneToOneLayout> {
  Offset position = Offset(5, 5);
  Offset _position = Offset.zero;
  bool _initialPositionSet = false;

  Widget _getLocalViews() {
    return widget.client.sessionController.value.isScreenShared
        ? AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: widget.client.sessionController.value.engine!,
              canvas: const VideoCanvas(
                uid: 0,
                sourceType: VideoSourceType.videoSourceScreen,
              ),
            ),
          )
        : AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: widget.client.sessionController.value.engine!,
              canvas: VideoCanvas(uid: 0, renderMode: widget.renderModeType),
            ),
          );
  }

  Widget _getRemoteViews(int uid) {
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: widget.client.sessionController.value.engine!,
        canvas: VideoCanvas(uid: uid, renderMode: widget.renderModeType),
        connection: RtcConnection(
          channelId:
              widget.client.sessionController.value.connectionData!.channelName,
        ),
      ),
    );
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(
      child: Container(
        child: view,
      ),
    );
  }

  Widget _oneToOneLayout() {
    return widget.client.users.isNotEmpty
        ? Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    child: widget.client.sessionController.value.users[0]
                            .videoDisabled
                        ? widget.disabledVideoWidget
                        : Stack(
                            children: [
                              Container(
                                color: Colors.black,
                                child: Center(
                                  child: Text(
                                    'المتصل',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Column(
                                  children: [
                                    _videoView(
                                      _getRemoteViews(widget.client.users[0]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.only(top: 8.0, right: 4),
                //   child: Align(
                //     alignment: Alignment.topRight,
                //     child: Container(
                //       height: MediaQuery.of(context).size.height * 0.2,
                //       width: MediaQuery.of(context).size.width / 3,
                //       child: ClipRRect(
                //           borderRadius: BorderRadius.circular(20),
                //           child: _getLocalViews()),
                //     ),
                //   ),
                // ),
                if(!widget.client.sessionController.value.isLocalVideoDisabled)
                Positioned(
                    left: _position.dx,
                    top: _position.dy,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        final screenWidth = MediaQuery.of(context).size.width;
                        final screenHeight = MediaQuery.of(context).size.height;
                        final containerWidth = screenWidth / 3;
                        final containerHeight = screenHeight * 0.2;

                        setState(() {
                          _position += details.delta;
                          _position = Offset(
                            _position.dx.clamp(0.0, screenWidth - containerWidth),
                            _position.dy.clamp(0.0, screenHeight - containerHeight),
                          );
                        });
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.2,
                        width: MediaQuery.of(context).size.width / 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: _getLocalViews(),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          )
        : Expanded(
            child: Container(
              child: widget.client.sessionController.value.isLocalVideoDisabled
                  ? widget.disabledVideoWidget
                  : Stack(
                      children: [
                        Container(
                          color: Colors.black,
                          child: Center(
                            child: Text(
                              'المستخدم الحالي',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            _videoView(_getLocalViews()),
                          ],
                        ),
                      ],
                    ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialPositionSet) {
      final screenWidth = MediaQuery.of(context).size.width;
      final containerWidth = screenWidth / 3;
      _position = Offset(
        screenWidth - containerWidth - 4, // Initial right padding
        8.0, // Initial top padding
      );
      _initialPositionSet = true;
    }

    return ValueListenableBuilder(
        valueListenable: widget.client.sessionController,
        builder: (context, counter, widgetx) {
          return Column(
            children: [
              _oneToOneLayout(),
            ],
          );
        });
  }
}
