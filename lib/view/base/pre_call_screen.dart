import 'dart:async';

import 'package:camera/camera.dart';
import 'package:coach_life/controller/booking_controller.dart';
import 'package:coach_life/routes/app_routes.dart';
import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PreCallSetupScreen extends StatefulWidget {
  final String connectType; // 'video' أو 'audio'

  const PreCallSetupScreen({super.key, required this.connectType});

  @override
  State<PreCallSetupScreen> createState() => _PreCallSetupScreenState();
}

class _PreCallSetupScreenState extends State<PreCallSetupScreen> {
  final BookingController _bookingCtrl = Get.find<BookingController>();
  bool get _isVideoCall => widget.connectType.toLowerCase() == 'video';

  bool _isCameraOn = true;
  bool _isMicOn = true;
  bool _isJoining = false;
  bool _canJoinNow = false;
  Duration? _timeUntilStart;

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  Timer? _joinUnlockTimer;

  @override
  void initState() {
    super.initState();
    try {
      _isMicOn = !_bookingCtrl.localMuted.value;
    } catch (_) {
      _isMicOn = true;
    }
    if (_isVideoCall) {
      try {
        _isCameraOn = _bookingCtrl.localVideoEnabled.value;
      } catch (_) {
        _isCameraOn = true;
      }
    } else {
      _isCameraOn = false;
      try {
        _bookingCtrl.localVideoEnabled.value = false;
      } catch (_) {}
    }
    _syncJoinAvailability();
    _startJoinWatcherIfNeeded();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _joinUnlockTimer?.cancel();
    super.dispose();
  }

  void _syncJoinAvailability() {
    final canJoin = _bookingCtrl.canStartCallNow(showMessage: false);
    final remaining = _bookingCtrl.timeUntilCallStart();
    setState(() {
      _canJoinNow = canJoin;
      _timeUntilStart = remaining;
    });
  }

  void _startJoinWatcherIfNeeded() {
    _joinUnlockTimer?.cancel();
    if (_bookingCtrl.canStartCallNow(showMessage: false)) {
      setState(() {
        _canJoinNow = true;
        _timeUntilStart = Duration.zero;
      });
      return;
    }
    _joinUnlockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final canJoin = _bookingCtrl.canStartCallNow(showMessage: false);
      final remaining = _bookingCtrl.timeUntilCallStart();
      setState(() {
        _canJoinNow = canJoin;
        _timeUntilStart = remaining;
      });
      if (canJoin) {
        timer.cancel();
      }
    });
  }

  // 🔹 تهيئة الكاميرا الأمامية
  Future<void> _initializeCamera() async {
    if (!_isVideoCall) return; // إذا كانت صوتية لا نهيئ الكاميرا
    try {
      _cameras = await availableCameras();
      final frontCamera = _cameras!.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: true,
      );

      await _cameraController!.initialize();

      if (mounted) {
        if (!_isCameraOn) {
          await _cameraController?.pausePreview();
        }
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      if (kDebugMode) print('Camera initialization error: $e');
    }
  }

  // 🔹 تشغيل/إيقاف الكاميرا
  void _toggleCamera() async {
    if (_cameraController == null) return;
    setState(() {
      _isCameraOn = !_isCameraOn;
    });

    if (_isCameraOn) {
      await _cameraController?.resumePreview();
    } else {
      await _cameraController?.pausePreview();
    }
    try {
      _bookingCtrl.localVideoEnabled.value = _isCameraOn;
    } catch (_) {}
  }

  void _toggleMic() {
    setState(() {
      _isMicOn = !_isMicOn;
    });
    try {
      _bookingCtrl.localMuted.value = !_isMicOn;
    } catch (_) {}
    // ملاحظة: المايك لن يعمل فعلياً هنا إلا داخل مكالمة حقيقية
  }

  void _joinCall() async {
    if (_isJoining) return;

    final appt = _bookingCtrl.selectedBooking.value;
    if (appt == null) {
      Get.snackbar(
        'call_setup_error_title'.tr,
        'call_setup_missing_booking'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!_bookingCtrl.canStartCallNow()) {
      return;
    }

    if (!_bookingCtrl.canStartCallNow(showMessage: true)) {
      setState(() {
        _canJoinNow = false;
      });
      _startJoinWatcherIfNeeded();
      return;
    }

    setState(() => _isJoining = true);

    final connectId = appt.connectId ?? '';
    final connectType = appt.connectType ?? 'video';
    final bookingId = appt.id ?? '';
    final duration = int.tryParse(appt.duration ?? '') ?? 0;

    try {
      await _bookingCtrl.initAgoraCall(
        connectId,
        connectType,
        bookingId,
        duration,
      );
      await _bookingCtrl.applyPreviewAndJoin(
        _isMicOn,
        _isVideoCall ? _isCameraOn : false,
      );

      Get.offNamed(
        AppRoutes.callSreen,
        arguments: {
          'initialMicState': _isMicOn,
          'initialCameraState': _isVideoCall ? _isCameraOn : false,
        },
      );
    } catch (e) {
      setState(() => _isJoining = false);
      Get.snackbar(
        'call_setup_connection_error'.tr,
        'call_setup_retry_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      if (kDebugMode) print('Join call error: $e');
    }
  }

  Widget _getDisabledCameraPlaceholder() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Icon(Icons.videocam_off, color: Colors.white70, size: 80),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = _bookingCtrl.selectedBooking.value;
    final coachName = booking?.coach?.name ?? '---';
    final callTitle = _isVideoCall
        ? 'call_setup_video_with'.trParams({'name': coachName})
        : 'call_setup_audio_with'.trParams({'name': coachName});

    final buttonGradient = LinearGradient(
      colors: [
        AppColors.primaryColor.withOpacity(0.95),
        AppColors.secondaryColor.withOpacity(0.9),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      backgroundColor: AppColors.darkScaffoldColor,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.darkScaffoldColor,
                AppColors.primaryColor.withOpacity(0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'call_setup_title'.tr,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.connectType.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1.4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.32),
                                blurRadius: 18,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (_isVideoCall)
                                  (_isCameraInitialized && _isCameraOn)
                                      ? CameraPreview(_cameraController!)
                                      : _getDisabledCameraPlaceholder()
                                else
                                  _buildAudioPreview(),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.55),
                                        Colors.transparent,
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.center,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 24,
                                  left: 20,
                                  right: 20,
                                  child: Text(
                                    callTitle,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 1.25,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 20,
                                  left: 20,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.55),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      'call_setup_you'.tr,
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 13,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        decoration: BoxDecoration(
                          color: AppColors.lightScaffoldColor.withOpacity(0.94),
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if (_isVideoCall)
                                  _ControlCircleButton(
                                    icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                                    label: _isCameraOn
                                        ? 'call_setup_camera_on'.tr
                                        : 'call_setup_camera_off'.tr,
                                    color: _isCameraOn
                                        ? AppColors.secondaryColor
                                        : AppColors.errorColor,
                                    onPressed: _toggleCamera,
                                  ),
                                _ControlCircleButton(
                                  icon: _isMicOn ? Icons.mic : Icons.mic_off,
                                  label: _isMicOn
                                      ? 'call_setup_mic_on'.tr
                                      : 'call_setup_mic_off'.tr,
                                  color:
                                      _isMicOn ? AppColors.successColor : AppColors.errorColor,
                                  onPressed: _toggleMic,
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            if (!_canJoinNow)
                              Column(
                                children: [
                                  Text(
                                    'call_wait_until_start'.tr,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 14,
                                      color: AppColors.darkGreyColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Builder(
                                    builder: (_) {
                                      final formatted = _formatRemaining(_timeUntilStart);
                                      if (formatted.isEmpty) return const SizedBox.shrink();
                                      return Text(
                                        'call_starts_in'.trParams({'time': formatted}),
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 13,
                                          color: AppColors.grayColor,
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                ],
                              ),
                            SizedBox(
                              width: double.infinity,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: (_canJoinNow && !_isJoining)
                                      ? buttonGradient
                                      : LinearGradient(
                                          colors: [
                                            Colors.grey.shade500,
                                            Colors.grey.shade400,
                                          ],
                                        ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryColor.withOpacity(0.35),
                                      blurRadius: 14,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed:
                                      (!_canJoinNow || _isJoining) ? null : _joinCall,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isJoining
                                      ? Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'call_setup_joining'.tr,
                                              style: const TextStyle(
                                                fontFamily: 'Cairo',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              _isVideoCall ? Icons.videocam : Icons.call,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              'call_setup_join_button'.tr,
                                              style: const TextStyle(
                                                fontFamily: 'Cairo',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioPreview() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withOpacity(0.85),
            AppColors.secondaryColor.withOpacity(0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.headset_mic,
          color: Colors.white,
          size: 80,
        ),
      ),
    );
  }

  String _formatRemaining(Duration? duration) {
    if (duration == null) return '';
    final totalSeconds = duration.inSeconds;
    if (totalSeconds <= 0) return ''; // already started
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '${hours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _ControlCircleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ControlCircleButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
