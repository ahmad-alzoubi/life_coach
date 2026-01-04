// record_message.dart
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:coach_life/controller/audio_player_manager.dart';
import 'package:coach_life/enums/audio_status.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecordMessage extends StatefulWidget {
  final String url;
  final bool isSentByMe;
  final double width;

  const RecordMessage({
    super.key,
    required this.url,
    required this.isSentByMe,
    this.width = 0.7,
  });

  @override
  State<RecordMessage> createState() => _RecordMessageState();
}

class _RecordMessageState extends State<RecordMessage> {
  late final AudioPlayerManager _manager;

  @override
  void initState() {
    super.initState();
    _manager = Get.find<AudioPlayerManager>();
    _manager.initController(widget.url);
  }

  @override
  void dispose() {
    _manager.releaseController(widget.url);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = _manager.getStatus(widget.url);
      final duration = _manager.getDuration(widget.url);
      final position = _manager.getPosition(widget.url);
      final downloadProgress = _manager.downloadProgress[widget.url]?.value;

      return Container(
        constraints: BoxConstraints(maxWidth: Get.width * widget.width),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PlayButton(
              status: status,
              isSentByMe: widget.isSentByMe,
              onPressed: () => _manager.togglePlayback(widget.url),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Waveform(
                manager: _manager,
                url: widget.url,
                isSentByMe: widget.isSentByMe,
                duration: duration,
                position: position,
              ),
            ),
            const SizedBox(width: 8),
            if (downloadProgress != null)
              Text(
                '${(downloadProgress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: widget.isSentByMe ? Colors.white : Colors.black,
                  fontSize: 12,
                ),
              )
            else
              _DurationText(
                duration: duration,
                position: position,
                isSentByMe: widget.isSentByMe,
                isPlaying: status == AudioStatus.playing,
              ),
          ],
        ),
      );
    });
  }
}

class _PlayButton extends StatelessWidget {
  final AudioStatus status;
  final bool isSentByMe;
  final VoidCallback onPressed;

  const _PlayButton({
    required this.status,
    required this.isSentByMe,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: status == AudioStatus.loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              status == AudioStatus.playing ? Icons.pause : Icons.play_arrow,
              color: isSentByMe ? Colors.white : Colors.black,
            ),
      onPressed: onPressed,
    );
  }
}

class _Waveform extends StatelessWidget {
  final AudioPlayerManager manager;
  final String url;
  final bool isSentByMe;
  final int duration;
  final int position;

  const _Waveform({
    required this.manager,
    required this.url,
    required this.isSentByMe,
    required this.duration,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return AudioFileWaveforms(
      key: ValueKey(url),  // Unique key for each audio
      size: Size(Get.width * 0.7, 50),
      playerController: manager.getController(url),
      waveformType: WaveformType.fitWidth,
      enableSeekGesture: true,
      playerWaveStyle: manager.playerWaveStyle,
      padding: const EdgeInsets.symmetric(vertical: 8),
      onDragStart: (details) => _handleSeekStart(details, context),
      onDragEnd: (details) => _handleSeekEnd(details, context),
      dragUpdateDetails: (details) => _handleSeekUpdate(details, context),
    );
  }

  void _handleSeekStart(DragStartDetails details, BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final localPosition = details.localPosition.dx;
    _seekToPosition(localPosition, box.size.width);
  }

  void _handleSeekUpdate(DragUpdateDetails details, BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final localPosition = details.localPosition.dx;
    _seekToPosition(localPosition, box.size.width);
  }

  void _handleSeekEnd(DragEndDetails details, BuildContext context) {
    manager.saveSeekPosition(url);
  }

  void _seekToPosition(double localX, double totalWidth) {
    final percentage = localX.clamp(0, totalWidth) / totalWidth;
    final positionMs = (percentage * duration).round();
    manager.seek(url, positionMs);
  }
}

class _DurationText extends StatelessWidget {
  final int duration;
  final int position;
  final bool isSentByMe;
  final bool isPlaying;

  const _DurationText({
    required this.duration,
    required this.position,
    required this.isSentByMe,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    final total = isPlaying ? duration - position : duration;
    return Text(
      _formatDuration(Duration(milliseconds: total)),
      style: TextStyle(
        color: isSentByMe ? Colors.white : Colors.black,
        fontSize: 12,
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}