// lib/view/call_screen.dart
import 'dart:async';
import 'dart:io';

import 'package:agora_uikit/agora_uikit.dart';
import 'package:coach_life/controller/booking_controller.dart';
import 'package:coach_life/controller/chat_controller.dart';
import 'package:coach_life/model/connected_user.dart';
import 'package:coach_life/model/conversation.dart';
import 'package:coach_life/routes/app_routes.dart';
import 'package:coach_life/services/socket_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/theme/app_colors.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with WidgetsBindingObserver {
  static const MethodChannel _callServiceChannel = MethodChannel(
    'com.social.coachLife.android/call_service',
  );

  Timer? _pollTimer;

  bool _isCameraOn = true;
  bool _foregroundServiceRunning = false;

  late final BookingController _bookingController;
  late final ChatController _chatController;
  late final SocketService _socketService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bookingController = Get.find<BookingController>();
    _socket_service_init();
    // Ensure ChatController exists / reuse existing
    if (Get.isRegistered<ChatController>()) {
      _chat_controller_find();
    } else {
      _chat_controller_put();
    }

    final args = Get.arguments ?? {};
    if (args.containsKey('initialCameraState')) {
      _isCameraOn = args['initialCameraState'] ?? true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectType =
          _bookingController.selectedBooking.value?.connectType ??
          (args['connectType'] ?? 'video');
      if (connectType != 'video') {
        _isCameraOn = false;
        _applyCameraStateToEngine(_bookingController);
      } else {
        if (!_isCameraOn) _applyCameraStateToEngine(_bookingController);
      }
      _ensureBackgroundAudioMode();
      _startAndroidForegroundService();
      _bookingController.reevaluateWaitTimer();
      try {
        _bookingController.syncConnectedUsersFromSession();
      } catch (_) {}
    });

    _startPollForReady();

    // Watch connectedUsers (RxList) and react to changes
    try {
      ever<List<ConnectedUser>>(_bookingController.connectedUsers, (val) {
        try {
          final users = val ?? <ConnectedUser>[];
          if (users.length >= 2) {
            try {
              _bookingController.isCallLoading.value = false;
            } catch (_) {}
            _stopPollForReady();
            setState(() {});
          }
        } catch (_) {}
      });
    } catch (_) {}
  }

  Future<void> _confirmLeaveCall(BuildContext context) async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            decoration: BoxDecoration(
              color: AppColors.darkGreyColor.withOpacity(0.98),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.45),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.errorColor.withOpacity(0.95),
                        AppColors.errorColor.withOpacity(0.75),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.call_end,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'call_end_confirm_title'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.lightTextColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'call_end_confirm_body'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.lightTextColor.withOpacity(0.78),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.grayColor.withOpacity(0.4),
                          ),
                          foregroundColor: AppColors.lightTextColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: Text('call_end_confirm_no'.tr),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.errorColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: Text('call_end_confirm_yes'.tr),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldLeave == true) {
      _bookingController.setCallStatusLabel('call_status_leaving');
      _bookingController.setIsCallLoading(true);
      await _bookingController.leaveChannel(
        reason: CallTerminationReason.manualHangup,
      );
      if (mounted) setState(() {});
      if (Get.isOverlaysOpen) Get.back();
    }
  }

  void _socket_service_init() {
    _socketService = Get.find<SocketService>();
  }

  void _chat_controller_find() {
    _chatController = Get.find<ChatController>();
  }

  void _chat_controller_put() {
    _chatController = Get.put(ChatController());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_stopAndroidForegroundService());
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _ensureBackgroundAudioMode();
        break;
      case AppLifecycleState.resumed:
        if (_isCameraOn) {
          _applyCameraStateToEngine(_bookingController);
        }
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _ensureBackgroundAudioMode() {
    unawaited(_bookingController.ensureBackgroundAudioMode());
  }

  Future<void> _startAndroidForegroundService() async {
    if (!Platform.isAndroid || _foregroundServiceRunning) return;

    final includeCamera =
        _bookingController.connectType.value == 'video' && _isCameraOn;

    Future<bool> ensurePermission(Permission permission, String name) async {
      final status = await permission.status;
      if (status.isGranted) return true;
      final result = await permission.request();
      if (result.isGranted) return true;
      if (kDebugMode) {
        print('$name permission not granted; skipping foreground service.');
      }
      return false;
    }

    final micGranted = await ensurePermission(
      Permission.microphone,
      'Microphone',
    );
    if (!micGranted) return;

    if (includeCamera) {
      final cameraGranted = await ensurePermission(Permission.camera, 'Camera');
      if (!cameraGranted) return;
    }

    try {
      await _callServiceChannel.invokeMethod('startService', {
        'title': 'Life Coach',
        'content': 'Call in progress',
        'includeCamera': includeCamera,
      });
      _foregroundServiceRunning = true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to start foreground service: $e');
      }
    }
  }

  Future<void> _stopAndroidForegroundService() async {
    if (!Platform.isAndroid || !_foregroundServiceRunning) return;
    try {
      await _callServiceChannel.invokeMethod('stopService');
    } catch (e) {
      if (kDebugMode) {
        print('Failed to stop foreground service: $e');
      }
    } finally {
      _foregroundServiceRunning = false;
    }
  }

  // ---------- poll & waiting ----------
  void _startPollForReady() {
    int attempts = 0;
    _pollTimer = Timer.periodic(const Duration(milliseconds: 500), (t) {
      attempts++;
      bool ready = false;
      try {
        _bookingController.syncConnectedUsersFromSession();
      } catch (_) {}
      try {
        if (_bookingController.client != null) ready = true;
      } catch (_) {}
      try {
        final users = _booking_controller_connectedUsers_safe();
        if (users.length >= 2) ready = true;
      } catch (_) {}

      if (ready) {
        try {
          _bookingController.isCallLoading.value = false;
        } catch (_) {}
        _stopPollForReady();
        setState(() {});
      } else if (attempts >= 20) {
        _stopPollForReady();
      }
    });
  }

  void _stopPollForReady() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  // ---------- helpers for ConnectedUser or Map ----------
  List<dynamic> _normalizeUsers(dynamic users) {
    try {
      if (users == null) return [];
      if (users is List) return users;
      return [users];
    } catch (_) {
      return [];
    }
  }

  List<ConnectedUser> _booking_controller_connectedUsers_safe() {
    try {
      return _bookingController.connectedUsers.toList();
    } catch (_) {
      return <ConnectedUser>[];
    }
  }

  String _getIdFromUser(dynamic u) {
    try {
      if (u == null) return '';
      if (u is ConnectedUser) return u.id.toString();
    } catch (_) {}
    try {
      if (u is Map) {
        final id = u['id'] ?? u['userId'] ?? u['_id'];
        if (id != null) return id.toString();
      }
    } catch (_) {}
    try {
      final candidate = (u?.id ?? u?['id']);
      return candidate?.toString() ?? u.hashCode.toString();
    } catch (_) {
      return u.hashCode.toString();
    }
  }

  String _getTypeFromUser(dynamic u) {
    try {
      if (u == null) return 'user';
      if (u is ConnectedUser) return (u.type ?? 'user').toString();
    } catch (_) {}
    try {
      if (u is Map && u['type'] != null) return u['type'].toString();
    } catch (_) {}
    return 'user';
  }

  String _getNameFromUser(dynamic u) {
    if (u == null) return 'مستخدم';

    String? explicitName;
    if (u is ConnectedUser) {
      try {
        final dyn = u as dynamic;
        explicitName = dyn.name ?? dyn.displayName;
      } catch (_) {}
    } else if (u is Map) {
      try {
        explicitName = u['displayName'] ?? u['name'] ?? u['username'];
      } catch (_) {}
    }

    if (explicitName != null && explicitName.toString().trim().isNotEmpty) {
      return explicitName.toString();
    }

    final role = _getTypeFromUser(u).trim().toLowerCase();
    final id = _getIdFromUser(u);
    final hasId = id.isNotEmpty;

    if (role == 'coach') {
      return hasId ? 'كوتش' : 'الكوتش';
    }
    if (role == 'host' || role == 'admin') {
      return 'المضيف';
    }
    return hasId ? 'مستخدم' : 'المستخدم';
  }

  String _initialChar(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    final iterator = trimmed.runes.iterator;
    if (iterator.moveNext()) {
      return String.fromCharCode(iterator.current);
    }
    return '';
  }

  String _buildInitials(String name) {
    final cleaned = name.trim();
    if (cleaned.isEmpty) return '؟';
    final parts = cleaned.split(RegExp(r'\s+'));
    final first = parts.isNotEmpty ? _initialChar(parts.first) : '';
    final last = parts.length > 1 ? _initialChar(parts.last) : '';
    final combined = (first + last).trim();
    if (combined.isNotEmpty) return combined;
    if (first.isNotEmpty) return first;
    return '؟';
  }

  String _roleDisplayLabel(String role) {
    final normalized = role.trim().toLowerCase();
    switch (normalized) {
      case 'coach':
        return 'الكوتش';
      case 'client':
      case 'user':
      case 'customer':
      case 'member':
        return 'المستخدم';
      default:
        return normalized.isNotEmpty ? normalized : 'المستخدم';
    }
  }

  Widget _buildParticipantsHeader(List<dynamic> participants) {
    if (participants.isEmpty) return const SizedBox.shrink();
    final badges = participants.map(_buildParticipantBadge).toList();
    return Positioned(
      top: 12,
      left: 12,
      right: 12,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: badges),
      ),
    );
  }

  Widget _buildParticipantBadge(dynamic user) {
    final name = _getNameFromUser(user);
    final role = _getTypeFromUser(user);
    final display = name.isNotEmpty ? name : _roleDisplayLabel(role);
    final isCoach = role.trim().toLowerCase() == 'coach';
    final accentColor =
        isCoach ? AppColors.secondaryColor : AppColors.primaryColor;
    final initials = _buildInitials(display);
    final roleLabel = _roleDisplayLabel(role);

    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  accentColor.withOpacity(0.95),
                  accentColor.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                display,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  roleLabel,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _applyCameraStateToEngine(BookingController controller) async {
    try {
      final dynamic agoraClient = controller.client;
      if (agoraClient == null) return;

      bool stateApplied = false;

      if (agoraClient.engine != null) {
        await agoraClient.engine.muteLocalVideoStream(!_isCameraOn);
        stateApplied = true;
        if (kDebugMode) print('Applied camera state via agoraClient.engine');
      } else if (agoraClient.rtcEngine != null) {
        await agoraClient.rtcEngine.muteLocalVideoStream(!_isCameraOn);
        stateApplied = true;
        if (kDebugMode) {
          print('Applied camera state via agoraClient.rtcEngine');
        }
      } else if (agoraClient.controller != null &&
          agoraClient.controller.engine != null) {
        await agoraClient.controller.engine.muteLocalVideoStream(!_isCameraOn);
        stateApplied = true;
        if (kDebugMode) {
          print('Applied camera state via agoraClient.controller.engine');
        }
      }

      controller.updateLocalVideoState(_isCameraOn);

      if (!stateApplied && kDebugMode) {
        print('Camera state not applied: no engine reference available');
      }
    } catch (e) {
      if (kDebugMode) print('Could not apply camera state to engine: $e');
    }
  }

  Future<void> _sendPresenceAlert(String targetRole) async {
    try {
      await _bookingController.sendInCallNotification(targetRole);
      Get.snackbar(
        'تم الإرسال',
        'تم إرسال تنبيه للطرف الآخر.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل إرسال التنبيه: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _openSupportChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const SupportChatSheet(),
    );
  }

  // ---------- initialize socket & bind to ChatController (without navigating) ----------
  Future<bool> _attachChatControllerSocketIfNeeded() async {
    // if already in chat or socket connected, skip
    try {
      if (_chatController.inChatNow.value == true) {
        return true;
      }
    } catch (_) {}

    try {
      final s = _chatController.socket;
      try {
        if ((s as dynamic).connected == true) {
          _chatController.inChatNow.value = true;
          return true;
        }
      } catch (_) {}
    } catch (_) {}

    // Build a robust Conversation object with fallbacks for id
    final selectedBooking = _bookingController.selectedBooking.value;
    String convId = '';
    String bookingId = '';

    try {
      bookingId =
          selectedBooking?.id?.toString() ??
          _bookingController.bookingId.value ??
          '';
    } catch (_) {
      bookingId = _bookingController.bookingId.value;
    }

    try {
      convId =
          selectedBooking?.conversation?.id?.toString() ??
          selectedBooking?.conversation?.id?.toString() ??
          '';
    } catch (_) {
      convId = '';
    }

    // If still empty, try controller-level fields
    if (convId.isEmpty) {
      convId =
          _bookingController.selectedBooking.value?.conversation?.id
              ?.toString() ??
          '';
    }

    final Conversation conv = Conversation(
      id: convId.isEmpty ? null : convId,
      bookingId: bookingId,
    );

    // Use ChatController.initSocket with navigate=false so it doesn't push UI
    try {
      await _chatController.initSocket(context, conv, navigate: false);
    } catch (e) {
      if (kDebugMode) print('initSocket (in-call) error: $e');
      return false;
    }

    // ensure conversationId set on controller (defensive)
    try {
      if ((_chatController.conversationId.value ?? '').isEmpty &&
          conv.id != null) {
        _chatController.conversationId.value = conv.id!;
      }
    } catch (_) {}

    // Mark inChatNow true if socket is connected
    try {
      final s = _chat_controller_socket_safe();
      if (s != null && (s as dynamic).connected == true) {
        _chatController.inChatNow.value = true;
        _chatController.update();
        return true;
      }
    } catch (_) {}

    // We reached here without confirming a live socket, but setup completed.
    // Allow caller to open the chat sheet and show loading state.
    return true;
  }

  dynamic _chat_controller_socket_safe() {
    try {
      return _chatController.socket;
    } catch (_) {
      return null;
    }
  }

  void _chat_controller_initListeners() {
    try {
      _chatController.initListeners();
    } catch (e) {
      if (kDebugMode) print('failed to init chat listeners: $e');
    }
  }

  Future<void> _contactSupportByEmail() async {
    final booking = _bookingController.selectedBooking.value;
    final bookingId = booking?.id?.toString() ?? '';
    final subject = 'Call support request';
    final buffer = StringBuffer()
      ..writeln('Hello support,')
      ..writeln('')
      ..writeln('I need help with my current call.')
      ..writeln('Booking ID: $bookingId')
      ..writeln('Role: ${_getLocalRole(_bookingController)}')
      ..writeln('')
      ..writeln('Please assist. Thank you.');

    final uri = Uri(
      scheme: 'mailto',
      path: 'support@lifecoach.com.sa',
      queryParameters: {
        'subject': subject,
        'body': buffer.toString(),
      },
    );
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        Get.snackbar(
          'خطأ',
          'تعذر فتح البريد الإلكتروني.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'تعذر فتح البريد الإلكتروني.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ---------- open full chat screen ----------
  Future<void> _openInCallChatSheet() async {
    final attached = await _attachChatControllerSocketIfNeeded();
    if (!mounted) return;
    if (!attached) {
      Get.snackbar(
        'خطأ',
        'تعذر فتح المحادثة الآن.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      _chatController.inChatNow.value = true;
      _chatController.update();
    } catch (_) {}

    await Get.toNamed(
      AppRoutes.chatScreen,
      arguments: {'openedFromCall': true},
    );

    try {
      _chatController.inChatNow.value = false;
      _chatController.update();
    } catch (_) {}
  }

  // helper wrappers for BookingController local user fields (safe)
  String _getLocalId(BookingController controller) {
    try {
      final local = controller.localUser;
      if (local != null) {
        try {
          return local.id.toString();
        } catch (_) {}
      }
    } catch (_) {}
    try {
      final cur = controller.currentUser;
      if (cur != null) {
        try {
          return cur.id.toString();
        } catch (_) {}
      }
    } catch (_) {}
    return '';
  }

  String _getLocalName(BookingController controller) {
    try {
      final local = controller.localUser;
      if (local != null) {
        try {
          final dyn = local as dynamic;
          final n = dyn.name ?? dyn.displayName ?? 'أنت';
          return n?.toString() ?? 'أنت';
        } catch (_) {}
      }
    } catch (_) {}
    try {
      final cur = controller.currentUser;
      if (cur != null) {
        try {
          final dn =
              (cur as dynamic).name ?? (cur as dynamic).displayName ?? 'أنت';
          return dn?.toString() ?? 'أنت';
        } catch (_) {}
      }
    } catch (_) {}
    return 'أنت';
  }

  String _getLocalRole(BookingController controller) {
    try {
      final local = controller.localUser;
      if (local != null) {
        try {
          return (local.type.toString() ?? 'user').toLowerCase();
        } catch (_) {}
      }
    } catch (_) {}
    try {
      final cur = controller.currentUser;
      if (cur != null) {
        try {
          return (cur.type.toString() ?? 'user').toLowerCase();
        } catch (_) {}
      }
    } catch (_) {}
    return 'user';
  }

  Widget _buildWaitingOverlay(String waitingForRole) {
    final isWaitingForCoach = waitingForRole == 'coach';
    final headline =
        isWaitingForCoach
            ? 'call_waiting_coach_title'.tr
            : 'call_waiting_user_title'.tr;
    final description =
        isWaitingForCoach
            ? 'call_waiting_coach_body'.tr
            : 'call_waiting_user_body'.tr;
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.95),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 12),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.watch_later,
                  color: AppColors.lightTextColor,
                  size: 60,
                ),
                const SizedBox(height: 12),
                Text(
                  headline,
                  style: TextStyle(
                    color: AppColors.lightTextColor,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.grayColor),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => Text(
                    _formatDuration(
                      _bookingController.waitLeftSeconds.value < 0
                          ? 0
                          : _bookingController.waitLeftSeconds.value,
                    ),
                    style: TextStyle(
                      color: AppColors.secondaryColor,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Widget _buildLoadingMessage(String message) {
    return Scaffold(
      backgroundColor: AppColors.darkScaffoldColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: TextStyle(color: AppColors.grayColor, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryColor, AppColors.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.headset_mic,
              color: AppColors.lightTextColor.withOpacity(0.95),
              size: 90,
            ),
            const SizedBox(height: 20),
            Text(
              "المكالمه جارية",
              style: TextStyle(
                color: AppColors.lightTextColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiveMinuteReminderBanner() {
    return Obx(() {
      final visibleSeconds =
          _bookingController.fiveMinuteReminderSecondsLeft.value;
      if (visibleSeconds <= 0) {
        return const SizedBox.shrink();
      }
      final callSecondsLeft = _bookingController.callRemainingSeconds.value;
      return Positioned(
        top: 78,
        left: 16,
        right: 16,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.darkGreyColor.withOpacity(0.93),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.secondaryColor.withOpacity(0.45),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                Icons.hourglass_bottom,
                color: AppColors.secondaryColor,
                size: 26,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'call_five_min_warning'.tr,
                      style: TextStyle(
                        color: AppColors.lightTextColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'الوقت المتبقي',
                          style: TextStyle(
                            color: AppColors.lightTextColor.withOpacity(0.78),
                            fontSize: 13,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryColor.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatDuration(callSecondsLeft),
                            style: TextStyle(
                              color: AppColors.lightTextColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFinalMinuteBanner() {
    return Obx(() {
      final seconds = _bookingController.callRemainingSeconds.value;
      if (seconds <= 0 || seconds > 60) {
        return const SizedBox.shrink();
      }
      return Positioned(
        top: 120,
        left: 16,
        right: 16,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.errorColor.withOpacity(0.92),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.timer, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'call_final_minute_warning'.tr,
                      style: TextStyle(
                        color: AppColors.lightTextColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Cairo',
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatDuration(seconds),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments ?? {};
    final connectType =
        _bookingController.selectedBooking.value?.connectType ??
        (args['connectType'] ?? 'video');

    bool clientIsAvailable = false;
    try {
      clientIsAvailable = _bookingController.client != null;
    } catch (_) {}

    final bool isVideoCall = (connectType == 'video');
    final Color backgroundColor =
        isVideoCall ? AppColors.darkScaffoldColor : AppColors.primaryColor;

    final usersRaw = _bookingController.connectedUsers;
    final users = _normalizeUsers(usersRaw);

    // build distinct participants map using normalized id
    final Map<String, dynamic> distinct = {};
    for (var u in users) {
      final id = _getIdFromUser(u);
      if (id.isEmpty) continue;
      if (!distinct.containsKey(id)) distinct[id] = u;
    }
    final participants = distinct.values.toList();

    final coachPresent = participants.any(
      (u) => _getTypeFromUser(u) == 'coach',
    );
    final userPresent = participants.any((u) {
      final t = _getTypeFromUser(u);
      return t == 'user' || t == 'client';
    });

    try {
      if ((coachPresent || userPresent) && clientIsAvailable) {
        try {
          _bookingController.isCallLoading.value = false;
        } catch (_) {}
      }
    } catch (_) {}

    if (!clientIsAvailable) {
      return _buildLoadingMessage('جارٍ الانضمام إلى المكالمة...');
    }

    final localRole = _getLocalRole(_bookingController);
    final otherRole = localRole == 'coach' ? 'user' : 'coach';
    final otherPresent = otherRole == 'coach' ? coachPresent : userPresent;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            if (isVideoCall)
              AgoraVideoViewer(
                client: _bookingController.client!,
                layoutType: Layout.oneToOne,
                disabledVideoWidget: Container(
                  color: backgroundColor,
                  child: Center(
                    child: Icon(
                      Icons.person,
                      color: AppColors.grayColor,
                      size: 50,
                    ),
                  ),
                ),
              )
            else
              _buildAudioPlaceholder(),

            _buildParticipantsHeader(participants),
            _buildFiveMinuteReminderBanner(),
            _buildFinalMinuteBanner(),

            // waiting overlay
            Obx(() {
              final waitRunning = _bookingController.waitRunning.value;
              final waitTarget = _bookingController.waitingForRole.value;
              if (!waitRunning || waitTarget == null) {
                return const SizedBox.shrink();
              }
              final normalizedRole = localRole.toLowerCase();
              final shouldShow =
                  normalizedRole == 'user' && waitTarget == 'coach';
              if (!shouldShow) return const SizedBox.shrink();
              return _buildWaitingOverlay(waitTarget);
            }),

            // controls row
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                height: 72,
                decoration: BoxDecoration(
                  color:
                      isVideoCall
                          ? AppColors.primaryColor.withOpacity(0.08)
                          : AppColors.lightTextColor.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        isVideoCall
                            ? AppColors.primaryColor.withOpacity(0.12)
                            : AppColors.lightTextColor.withOpacity(0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Obx(
                      () => IconButton(
                        icon: Icon(
                          _bookingController.localMuted.value
                              ? Icons.mic_off
                              : Icons.mic,
                          color: AppColors.lightTextColor,
                        ),
                        onPressed:
                            () async =>
                                await _bookingController.toggleLocalMute(),
                      ),
                    ),
                    Obx(
                      () => IconButton(
                        icon: Icon(
                          _bookingController.speakerOn.value
                              ? Icons.volume_up
                              : Icons.volume_off,
                          color: AppColors.lightTextColor,
                        ),
                        onPressed:
                            () async =>
                                await _bookingController.toggleSpeaker(),
                      ),
                    ),
                    if (isVideoCall)
                      IconButton(
                        icon: Icon(
                          _isCameraOn ? Icons.videocam : Icons.videocam_off,
                          color: AppColors.lightTextColor,
                        ),
                        onPressed: () async {
                          setState(() => _isCameraOn = !_isCameraOn);
                          await _applyCameraStateToEngine(_bookingController);
                        },
                      ),
                    IconButton(
                      icon: Icon(
                        Icons.chat_bubble,
                        color: AppColors.lightTextColor,
                      ),
                      onPressed: _openInCallChatSheet,
                    ),
                    // IconButton(
                    //   icon: Icon(
                    //     Icons.support_agent,
                    //     color: AppColors.lightTextColor,
                    //   ),
                    //   onPressed: _openSupportChat,
                    // ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.errorColor,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(14),
                        elevation: 3,
                      ),
                      onPressed: () => _confirmLeaveCall(context),
                      child: const Icon(Icons.call_end, color: Colors.white),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.support_agent,
                        color: AppColors.lightTextColor,
                      ),
                      onPressed: _contactSupportByEmail,
                    ),
                  ],
                ),
              ),
            ),

            // presence alert button
            GetX<BookingController>(
              builder: (c) {
                final usersLocal = _normalizeUsers(c.connectedUsers);
                bool otherPresentLocal = false;
                try {
                  final Map<String, dynamic> uniq = {};
                  for (var u in usersLocal) uniq[_getIdFromUser(u)] = u;
                  final list = uniq.values.toList();
                  final coachExists = list.any(
                    (u) => _getTypeFromUser(u) == 'coach',
                  );
                  final userExists = list.any((u) {
                    final t = _getTypeFromUser(u);
                    return t == 'user' || t == 'client';
                  });
                  otherPresentLocal =
                      localRole == 'coach' ? userExists : coachExists;
                } catch (_) {
                  otherPresentLocal = otherPresent;
                }

                final waitRunning = c.waitRunning.value;
                final waitTarget = c.waitingForRole.value;
                final isWaitingForCounterpart =
                    waitRunning &&
                    waitTarget != null &&
                    ((waitTarget == 'coach' && localRole != 'coach') ||
                        (waitTarget == 'user' && localRole == 'coach'));

                if (!otherPresentLocal && isWaitingForCounterpart) {
                  return Positioned(
                    top: 80,
                    right: 16,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.notifications_active),
                      label: Text(
                        localRole == 'coach'
                            ? 'إرسال تنبيه للمستخدم'
                            : 'إرسال تنبيه للكوتش',
                      ),
                      onPressed:
                          () async => await _sendPresenceAlert(otherRole),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            Obx(
              () =>
                  _bookingController.isCallLoading.value
                      ? Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.65),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                _bookingController.callStatusLabelKey.value.tr,
                                style: TextStyle(
                                  color: AppColors.lightTextColor,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// --------- Support chat bottom sheet (basic) ----------
class SupportChatSheet extends StatefulWidget {
  const SupportChatSheet({super.key});

  @override
  State<SupportChatSheet> createState() => _SupportChatSheetState();
}

class _SupportChatSheetState extends State<SupportChatSheet> {
  final TextEditingController _ctrl = TextEditingController();
  final List<Map<String, dynamic>> _msgs = [];

  void _sendSupport() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _msgs.add({'from': 'me', 'text': text, 'time': DateTime.now()});
    });
    _ctrl.clear();

    final BookingController controller = Get.find<BookingController>();
    controller.openSupportTicket(text);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.darkGreyColor.withOpacity(0.98),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          children: [
            Text(
              'التحدث مع الدعم',
              style: TextStyle(
                color: AppColors.lightTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  _msgs.isEmpty
                      ? Center(
                        child: Text(
                          'بدأ المحادثة مع الدعم',
                          style: TextStyle(color: AppColors.grayColor),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _msgs.length,
                        itemBuilder: (_, i) {
                          final m = _msgs[i];
                          return ListTile(
                            title: Text(
                              m['text'],
                              style: TextStyle(color: AppColors.lightTextColor),
                            ),
                            subtitle: Text(
                              m['time'].toString(),
                              style: TextStyle(color: AppColors.grayColor),
                            ),
                          );
                        },
                      ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'اكتب رسالة للدعم...',
                      hintStyle: TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: AppColors.primaryColor),
                  onPressed: _sendSupport,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
