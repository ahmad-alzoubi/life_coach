// lib/controller/booking_controller.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart'
    show
        AudioProfileType,
        AudioScenarioType,
        AudioVolumeInfo,
        ConnectionChangedReasonType,
        ConnectionStateType,
        LocalAudioStreamState,
        RemoteAudioState,
        RemoteAudioStateReason,
        RemoteVideoState,
        RemoteVideoStateReason,
        RtcConnection,
        RtcEngine,
        RtcEngineEventHandler,
        UserOfflineReasonType;
import 'package:agora_uikit/agora_uikit.dart';
import 'package:agora_uikit/models/agora_user.dart';
import 'package:coach_life/controller/coach_controller.dart';
import 'package:coach_life/controller/dashboard_controller.dart';
import 'package:coach_life/model/booking.dart';
import 'package:coach_life/model/booking_request.dart';
import 'package:coach_life/model/coach.dart';
import 'package:coach_life/model/connected_user.dart';
import 'package:coach_life/repositories/booking_repository.dart';
import 'package:coach_life/repositories/coachs_repository.dart';
import 'package:coach_life/routes/app_routes.dart';
import 'package:coach_life/utils/messages/messages_manager.dart';
import 'package:coach_life/utils/theme/app_colors.dart';
import 'package:coach_life/utils/utlis.dart';
import 'package:coach_life/view/widgets/rate_widget.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';

import '../model/schedule.dart';
import '../services/auth_manager.dart';

enum CallTerminationReason {
  general,
  manualHangup,
  coachNoShow,
  userNoShow,
  coachEnded,
  userEnded,
  durationEnded,
  cancelled,
  completed,
  connectionError,
}

class BookingController extends GetxController {
  // ---------------- state fields ----------------
  final Rx<String> selectedConnectionType = "".obs;
  final Rx<Schedule> selectedSchedule = Schedule().obs;
  final Rx<Slot> selectedSlot = Slot().obs;
  final Rx<BookingRequest> bookingRequest = BookingRequest().obs;
  final RxBool isLoading = false.obs;
  final RxDouble amount = 0.0.obs;
  final RxDouble timeAmount = 0.0.obs;
  final RxDouble tax = 0.0.obs;

  AgoraClient? client;
  final RxString connectType = "audio".obs;
  final RxBool isCallLoading = false.obs;

  final Rxn<Booking> selectedBooking = Rxn<Booking>();
  final RxString coachId = "".obs;
  final Rx<Coach> selectedCoach = Coach().obs;
  final Rx<String> bookingId = "".obs;
  final RxInt rate = 0.obs;
  final TextEditingController ratingController = TextEditingController();
  final RxBool isRatingLoading = false.obs;

  final RxList<ConnectedUser> connectedUsers = <ConnectedUser>[].obs;

  // audio states
  final RxBool remoteAudioActive =
      false.obs; // true if we detect remote audio levels > 0
  final RxBool localMuted = false.obs; // app-level mute state
  final RxBool speakerOn = true.obs; // speakerphone

  // call status indicator label
  final RxString callStatusLabelKey = 'call_status_joining'.obs;

  // local video state (new)
  final RxBool localVideoEnabled = true.obs;

  // call timing fields (new)
  final RxBool callStarted = false.obs;
  final RxInt callRemainingSeconds = 0.obs; // updates every second if available
  final Rxn<DateTime> callEndTime =
      Rxn<DateTime>(); // optional absolute end time
  int? callDurationSeconds; // optional total duration in seconds (fallback)
  final RxInt fiveMinuteReminderSecondsLeft =
      0.obs; // controls in-call banner visibility

  // wait / no-show timer
  final int waitSeconds = 300;
  Timer? _waitTimer;
  final RxInt waitLeftSeconds = 0.obs;
  final RxBool waitRunning = false.obs;
  final Rx<String?> waitingForRole = Rx<String?>(null);
  String? _waitTargetRole;

  // booking context for refund
  String? activeBookingId;
  double paidAmount = 0.0;

  // internal timers/subscriptions
  Timer? _bookingStatusTimer;
  Timer? _callExpiryTimer; // leaves channel after expiry+buffer
  Timer?
  _callRemainingTimer; // ticks each second to update callRemainingSeconds
  Timer? _updateTimer;
  StreamSubscription? _firebaseSubscription;
  bool _isDisposed = false;
  bool _isLeavingChannel = false;
  CallTerminationReason? _lastTerminationReason;
  bool _fiveMinuteWarningSent = false;
  bool _oneMinuteCountdownTriggered = false;
  bool _callDurationHandled = false;
  bool _navigatedToSummary = false;

  // keep a reference to low-level engine for convenience when available
  RtcEngine? _engine;

  // --- New: helpers for UI and in-call features
  /// optional placeholders that some UI code may try to read (e.g., call_screen._getLocalRole)
  ConnectedUser? localUser;
  ConnectedUser? currentUser;

  @override
  void onClose() {
    _cleanup();
    super.onClose();
  }

  void _cleanup() {
    _isDisposed = true;
    _waitTimer?.cancel();
    _bookingStatusTimer?.cancel();
    _callExpiryTimer?.cancel();
    _callRemainingTimer?.cancel();
    _updateTimer?.cancel();
    _firebaseSubscription?.cancel();
    _safeLeaveAndRelease();
    ratingController.dispose();
  }

  // ---------------- safe engine access & cleanup ----------------
  RtcEngine? _getEngine() {
    // prefer client.engine, otherwise try sessionController.value.engine if available
    try {
      final eng = client?.engine ?? client?.sessionController.value.engine;
      return eng;
    } catch (e) {
      if (kDebugMode) print('_getEngine error: $e');
      return null;
    }
  }

  Future<void> _safeLeaveAndRelease() async {
    try {
      _engine = _getEngine();
      if (_engine != null) {
        try {
          await _engine!.leaveChannel();
        } catch (e) {
          if (kDebugMode) print('engine.leaveChannel failed: $e');
        }
        try {
          await _engine!.release();
        } catch (e) {
          if (kDebugMode) print('engine.release failed: $e');
        }
      }
    } catch (e) {
      if (kDebugMode) print('_safeLeaveAndRelease outer error: $e');
    }

    try {
      await client?.release();
    } catch (e) {
      if (kDebugMode) print('client.release fallback failed: $e');
    } finally {
      client = null;
      _engine = null;

      // reset call timing states
      callStarted.value = false;
      callRemainingSeconds.value = 0;
      callEndTime.value = null;
      callDurationSeconds = null;
      fiveMinuteReminderSecondsLeft.value = 0;
    }
  }

  Future<void> ensureBackgroundAudioMode() async {
    await _configureBackgroundAudioMode();
  }

  Future<void> _configureBackgroundAudioMode() async {
    final engine = _getEngine();
    if (engine == null) return;
    try {
      await engine.setAudioProfile(
        profile: AudioProfileType.audioProfileSpeechStandard,
        scenario: AudioScenarioType.audioScenarioMeeting,
      );
    } catch (e) {
      if (kDebugMode) print('setAudioProfile failed: $e');
    }

    try {
      await engine.setParameters('{"che.audio.keep.audiosession":true}');
    } catch (e) {
      if (kDebugMode) {
        print('setParameters(keep.audiosession) failed: $e');
      }
    }
  }

  // ---------------- small setters ----------------
  void setSelectedConnectionType(String value, int duration) {
    if (_isDisposed) return;
    selectedConnectionType.value = value;
    _updateAmountBasedOnConnectionType(value, duration);
    update();
  }

  void _updateAmountBasedOnConnectionType(String connectionType, int duration) {
    tax.value = 0.0;
    final coachAttributes = selectedCoach.value.coachAttributes;
    if (coachAttributes == null) {
      amount.value = 0.0;
      return;
    }
    String? priceString;
    switch (connectionType) {
      case 'chat':
        priceString =
            duration == 30
                ? coachAttributes.halfChatPrice
                : coachAttributes.chatPrice;
        break;
      case 'video':
        priceString =
            duration == 30
                ? coachAttributes.halfVideoPrice
                : coachAttributes.videoPrice;
        break;
      case 'audio':
        priceString =
            duration == 30
                ? coachAttributes.halfAudioPrice
                : coachAttributes.audioPrice;
        break;
      default:
        amount.value = 0.0;
        return;
    }
    amount.value = double.tryParse(priceString ?? "0") ?? 0.0;
  }

  void setSelectedSchedule(Schedule schedule) {
    if (_isDisposed) return;
    selectedSchedule.value = schedule;
    update();
  }

  void setRate(int value) {
    if (_isDisposed) return;
    rate.value = value;
    update();
  }

  void setSelectedSlot(Slot? slot) {
    if (_isDisposed) return;
    selectedSlot.value = slot ?? Slot();
    _updateTimeAmountBasedOnDuration();
    update();
  }

  void _updateTimeAmountBasedOnDuration() {
    tax.value = 0.0;
    final duration = Get.find<CoachController>().duration.value;
    final connectionTypeLocal = selectedConnectionType.value;
    final coachAttributes = selectedCoach.value.coachAttributes;
    if (coachAttributes == null) {
      timeAmount.value = 0.0;
      amount.value = 0.0;
      return;
    }
    String? priceString;
    if (duration == 30) {
      switch (connectionTypeLocal) {
        case 'chat':
          priceString = coachAttributes.halfChatPrice;
          break;
        case 'video':
          priceString = coachAttributes.halfVideoPrice;
          break;
        case 'audio':
          priceString = coachAttributes.halfAudioPrice;
          break;
      }
    } else {
      switch (connectionTypeLocal) {
        case 'chat':
          priceString = coachAttributes.chatPrice;
          break;
        case 'video':
          priceString = coachAttributes.videoPrice;
          break;
        case 'audio':
          priceString = coachAttributes.audioPrice;
          break;
      }
    }
    timeAmount.value = double.tryParse(priceString ?? "0") ?? 0.0;
    amount.value = timeAmount.value;
  }

  void setIsLoading(bool value) {
    if (_isDisposed) return;
    isLoading.value = value;
    update();
  }

  void setIsCallLoading(bool value) {
    if (_isDisposed) return;
    isCallLoading.value = value;
    update();
  }

  void setCallStatusLabel(String labelKey) {
    if (_isDisposed) return;
    callStatusLabelKey.value = labelKey;
    update();
  }

  void setSelectedBooking(Booking? booking) {
    if (_isDisposed) return;
    selectedBooking.value = booking;
    if (booking != null) {
      bookingId.value = booking.id ?? bookingId.value;
      activeBookingId = booking.id ?? activeBookingId;
      final parsedAmount = double.tryParse(booking.amount ?? '') ?? paidAmount;
      paidAmount = parsedAmount;
      final connect = booking.connectType?.toLowerCase();
      if (connect != null && connect.isNotEmpty) {
        connectType.value = connect;
      }
    }
    update();
  }

  void setCoachId(String id, Coach coach) {
    if (_isDisposed) return;
    coachId.value = id;
    selectedCoach.value = coach;
    update();
  }

  void setBookingContext({
    required String bookingIdParam,
    required double paid,
  }) {
    activeBookingId = bookingIdParam;
    paidAmount = paid;
  }

  DateTime? _parseBookingDateTime(String? date, String? time) {
    if (date == null || date.trim().isEmpty) return null;
    final datePart = date.trim();
    final timePart = (time ?? '').trim();

    DateTime? tryParseIso(String candidate) {
      try {
        return DateTime.tryParse(candidate)?.toLocal();
      } catch (_) {
        return null;
      }
    }

    if (timePart.isEmpty) {
      return tryParseIso(datePart);
    }

    final isoCandidate = '$datePart${_normalizeIsoTime(timePart)}';
    final isoParsed = tryParseIso(isoCandidate);
    if (isoParsed != null) return isoParsed;

    final formats = <DateFormat>[
      DateFormat('yyyy-MM-dd HH:mm:ss'),
      DateFormat('yyyy-MM-dd HH:mm'),
      DateFormat('yyyy-MM-dd hh:mm a'),
      DateFormat('yyyy-MM-dd h:mm a'),
    ];

    for (final format in formats) {
      try {
        final parsed = format.parse('$datePart $timePart', true).toLocal();
        return parsed;
      } catch (_) {
        continue;
      }
    }

    try {
      return DateFormat('yyyy-MM-dd').parse(datePart, true).toLocal();
    } catch (_) {
      return null;
    }
  }

  String _normalizeIsoTime(String raw) {
    var time = raw.trim();
    if (time.contains(RegExp('[a-zA-Z]'))) {
      return time.replaceAll(' ', '');
    }
    if (time.length == 5) return '$time:00';
    return time;
  }

  Duration? timeUntilCallStart() {
    final booking = selectedBooking.value;
    if (booking == null) return null;
    final startAt = _parseBookingDateTime(booking.date, booking.time);
    if (startAt == null) return null;
    return startAt.difference(DateTime.now());
  }

  bool canStartCallNow({bool showMessage = true}) {
    final booking = selectedBooking.value;
    if (booking == null) return true;
    final startAt = _parseBookingDateTime(booking.date, booking.time);
    if (startAt == null) return true;
    final now = DateTime.now();
    if (now.isBefore(startAt)) {
      if (showMessage) {
        MessagesManager.showErrorMessage('call_cannot_start_early'.tr);
      }
      return false;
    }
    return true;
  }

  // ---------------- logging user-left ----------------
  void handleUserLeft(
    DateTime leftAt,
    String userId,
    String userType,
    String bookingIdParam,
    String reason,
  ) {
    if (_isDisposed) return;
    final formattedTime = DateFormat('HH:mm:ss').format(leftAt);
    BookingRepository().userLeftCall(
      userId,
      formattedTime,
      bookingIdParam,
      reason,
    );
  }

  // ---------------- init Agora + attach diagnostics ----------------
  Future<void> initAgoraCall(
    String channelName,
    String connectTypeParam,
    String bookingIdParam,
    int minutes,
  ) async {
    if (_isDisposed) return;
    try {
      await _safeLeaveAndRelease();

      connectType.value = connectTypeParam;
      setCallStatusLabel('call_status_joining');
      setIsCallLoading(true);

      // remaining_seconds from backend (prefer seconds)
      int remainingSecondsFromServer = 0;
      String tempToken = "";
      String agoraAppId = Utils.agoraAppId;

      try {
        await AuthManager().getAccessToken();
      } catch (_) {}

      // fetch remaining time etc.
      final response = await BookingRepository().getBookingRemainingTime(
        bookingIdParam,
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final rem =
            responseData['remaining_time'] ??
            responseData['remainingTime'] ??
            0;
        if (rem is num)
          remainingSecondsFromServer = rem.toInt();
        else
          remainingSecondsFromServer =
              (double.tryParse(rem.toString()) ?? 0).toInt();

        tempToken =
            responseData['temp_token'] ?? responseData['tempToken'] ?? "";
        agoraAppId =
            responseData['agora_app_id'] ??
            responseData['agoraAppId'] ??
            agoraAppId;
      } else {
        throw Exception('Failed to get booking time: ${response.statusCode}');
      }

      // ensure permissions
      await _ensurePermissions();

      client = AgoraClient(
        agoraConnectionData: AgoraConnectionData(
          appId: agoraAppId,
          channelName: channelName,
          username: Get.find<DashboardController>().user.value.name ?? '',
          rtmUid:
              Get.find<DashboardController>().user.value.id?.toString() ?? '',
          tempToken: tempToken,
          cloudRecordingUrl: "https://api.agora.io/v1/apps/$agoraAppId",
        ),
        enabledPermission: [Permission.camera, Permission.microphone],
        agoraEventHandlers: _createAgoraEventHandlers(bookingIdParam),
      );

      if (client!.isInitialized) {
        setIsCallLoading(false);
        // still set call timing if backend provided value
        if (remainingSecondsFromServer > 0) {
          _startCallDurationTimerSeconds(remainingSecondsFromServer);
        }
        return;
      }

      // initialize with camera if video
      await client!.initialize(withCamera: connectType.value == "video");

      // cache engine reference if available
      _engine = _getEngine();
      await _configureBackgroundAudioMode();

      // attach detailed debug handlers to engine to trace audio issues
      _attachEngineDiagnostics();

      // enable audio volume indication so we can detect speaking
      _enableAudioVolumeIndication();

      bookingId.value = bookingIdParam;
      activeBookingId = bookingIdParam;

      try {
        _evaluateWaitTimer();
      } catch (_) {}

      _startBookingStatusMonitoring(bookingIdParam);
      // start timers related to call duration and remaining seconds
      if (remainingSecondsFromServer > 0) {
        _startCallDurationTimerSeconds(remainingSecondsFromServer);
      }

      setIsCallLoading(false);
    } catch (e, st) {
      if (kDebugMode) print("Error initializing Agora: $e\n$st");
      setIsCallLoading(false);
      MessagesManager.showErrorMessage('Failed to initialize call'.tr);
    }
  }

  Future<void> _ensurePermissions() async {
    try {
      final statuses =
          await [Permission.camera, Permission.microphone].request();
      if (statuses[Permission.microphone]?.isDenied == true ||
          statuses[Permission.camera]?.isDenied == true) {
        MessagesManager.showErrorMessage('Permissions denied'.tr);
      }
    } catch (e) {
      if (kDebugMode) print("Permission error: $e");
    }
  }

  /// Creates Agora RTC event handlers used when constructing `AgoraClient`.
  /// Place this inside your `BookingController` class.
  AgoraRtcEventHandlers _createAgoraEventHandlers(String bookingId) {
    return AgoraRtcEventHandlers(
      onJoinChannelSuccess: (connection, elapsed) {
        if (_isDisposed) return;
        try {
          if (kDebugMode) print('Agora: onJoinChannelSuccess elapsed=$elapsed');

          final localUid =
              connection.localUid?.toString() ??
              Get.find<DashboardController>().user.value.id?.toString() ??
              'local';
          final currentType =
              Get.find<DashboardController>().user.value.type?.toLowerCase() ??
              'user';

          // add local user if not present
          final exists = connectedUsers.any((u) => u.id == localUid);
          if (!exists) {
            connectedUsers.add(
              ConnectedUser(
                id: localUid,
                type: currentType,
                joinedAt: DateTime.now(),
              ),
            );
          } else {
            // update type/lastSeen
            final idx = connectedUsers.indexWhere((u) => u.id == localUid);
            if (idx != -1) {
              connectedUsers[idx].type = currentType;
              connectedUsers[idx].lastSeen = DateTime.now();
            }
          }

          // set localUser reference for UI helpers
          try {
            localUser = connectedUsers.firstWhere(
              (u) => u.id == localUid,
              orElse: () => ConnectedUser(id: localUid, type: currentType),
            );
          } catch (_) {
            localUser = ConnectedUser(
              id: localUid,
              type: currentType,
              joinedAt: DateTime.now(),
            );
          }

          // also set currentUser placeholder (useful for some UI code)
          currentUser = localUser;

          // Inform backend that call was accepted (non-blocking)
          Future.microtask(() => BookingRepository().acceptCall(bookingId));

          // Log join timestamp for backend analytics
          Future.microtask(() {
            handleUserLeft(
              DateTime.now(),
              localUid,
              currentType,
              bookingId,
              "joined",
            );
          });

          // Re-evaluate wait timer state
          try {
            _evaluateWaitTimer();
          } catch (_) {}
        } catch (e) {
          if (kDebugMode) print('onJoinChannelSuccess handler error: $e');
        }
      },

      onUserJoined: (connection, remoteUid, elapsed) {
        if (_isDisposed) return;
        try {
          if (kDebugMode)
            print('Agora: onUserJoined uid=$remoteUid elapsed=$elapsed');

          final uidStr = remoteUid.toString() ?? 'unknown';
          final userType = _determineUserType(
            remoteUid is int ? remoteUid : int.tryParse(uidStr) ?? 0,
          );

          final idx = connectedUsers.indexWhere((u) => u.id == uidStr);
          if (idx == -1) {
            connectedUsers.add(
              ConnectedUser(
                id: uidStr,
                type: userType,
                joinedAt: DateTime.now(),
              ),
            );
          } else {
            connectedUsers[idx].lastSeen = DateTime.now();
            connectedUsers[idx].type = userType;
          }

          // if remote joined and matches local user id, update localUser (defensive)
          try {
            final localUid =
                connection.localUid?.toString() ??
                Get.find<DashboardController>().user.value.id?.toString();
            if (uidStr == localUid) {
              localUser = connectedUsers.firstWhere((u) => u.id == uidStr);
              currentUser = localUser;
            }
          } catch (_) {}

          _handleUserEvent(
            "joined",
            bookingId,
            userId: uidStr,
            userType: userType,
          );
          _evaluateWaitTimer();
        } catch (e) {
          if (kDebugMode) print('onUserJoined handler error: $e');
        }
      },

      onUserMuteVideo: (connection, remoteUid, muted) {
        if (_isDisposed) return;
        try {
          final uidStr = remoteUid.toString() ?? 'unknown';
          updateRemoteVideoState(uidStr, !muted);
        } catch (e) {
          if (kDebugMode) print('onUserMuteVideo handler error: $e');
        }
      },

      onUserOffline: (connection, remoteUid, reason) async {
        if (_isDisposed) return;
        try {
          if (kDebugMode)
            print('Agora: onUserOffline uid=$remoteUid reason=$reason');

          final uidStr = remoteUid.toString() ?? 'unknown';
          String? removedType;
          final idx = connectedUsers.indexWhere((u) => u.id == uidStr);
          if (idx != -1) {
            removedType = connectedUsers[idx].type;
            connectedUsers.removeAt(idx);
          }

          // if removed user was localUser, clear
          if (localUser?.id == uidStr) {
            localUser = null;
          }

          // determine if we should end the call immediately
          if (!_isLeavingChannel) {
            final inferredType =
                removedType ??
                _determineUserType(remoteUid is int ? remoteUid : 0);
            final termination = _mapRemoteLeaveReason(inferredType, reason);
            if (termination != null) {
              _stopWaitTimer();
              unawaited(leavChannel(reason: termination));
              return;
            }
          }

          _handleUserEvent(
            "user_offline",
            bookingId,
            userId: uidStr,
            userType: removedType,
          );
          _evaluateWaitTimer();
        } catch (e) {
          if (kDebugMode) print('onUserOffline handler error: $e');
        }
      },

      onLeaveChannel: (connection, stats) async {
        if (_isDisposed) return;
        try {
          if (kDebugMode) print('Agora: onLeaveChannel stats=$stats');
          _handleUserEvent("left", bookingId);
          connectedUsers.clear();
          _stopWaitTimer();
        } catch (e) {
          if (kDebugMode) print('onLeaveChannel handler error: $e');
        }
      },

      onRequestToken: (connection) async {
        if (_isDisposed) return;
        try {
          if (kDebugMode) print('Agora: onRequestToken - fetching new token');
          final newToken = await BookingRepository().getNewToken(bookingId);
          if (kDebugMode) print('Agora: new token fetched');
          try {
            await client?.sessionController.value.engine?.renewToken(newToken);
          } catch (e) {
            if (kDebugMode) print('renewToken via engine failed: $e');
          }
        } catch (e) {
          if (kDebugMode) print('onRequestToken handler error: $e');
        }
      },

      onError: (err, message) {
        if (_isDisposed) return;
        try {
          if (kDebugMode) print('Agora Error: $err message=$message');
          MessagesManager.showErrorMessage('Call error occurred'.tr);
        } catch (e) {
          if (kDebugMode) print('onError handler error: $e');
        }
      },

      // Optional: update audio state when remote audio changes (some versions support this)
      onRemoteAudioStateChanged: (
        connection,
        remoteUid,
        state,
        reason,
        elapsed,
      ) {
        if (_isDisposed) return;
        try {
          if (kDebugMode)
            print(
              'Agora: onRemoteAudioStateChanged uid=$remoteUid state=$state reason=$reason elapsed=$elapsed',
            );

          final uidStr = remoteUid.toString() ?? 'unknown';
          final idx = connectedUsers.indexWhere((u) => u.id == uidStr);

          // Heuristic mapping: state values differ by SDK; treat 'Decoding'/'Starting' as receiving audio.
          final receiving =
              state.index == 2 ||
              state.index == 3 ||
              state.toString().toLowerCase().contains('decoding') ||
              state.toString().toLowerCase().contains('starting');

          if (idx != -1) {
            connectedUsers[idx].audioEnabled = receiving;
            connectedUsers[idx].lastSeen = DateTime.now();
          }

          remoteAudioActive.value = connectedUsers.any((u) => u.audioEnabled);
        } catch (e) {
          if (kDebugMode) print('onRemoteAudioStateChanged handler error: $e');
        }
      },

      onRemoteVideoStateChanged: (
        connection,
        remoteUid,
        state,
        reason,
        elapsed,
      ) {
        if (_isDisposed) return;
        try {
          final uidStr = remoteUid.toString() ?? 'unknown';
          if (state == RemoteVideoState.remoteVideoStateStopped ||
              state == RemoteVideoState.remoteVideoStateFrozen ||
              state == RemoteVideoState.remoteVideoStateFailed) {
            updateRemoteVideoState(uidStr, false);
          } else if (state == RemoteVideoState.remoteVideoStateDecoding ||
              reason ==
                  RemoteVideoStateReason.remoteVideoStateReasonRemoteUnmuted ||
              state == RemoteVideoState.remoteVideoStateStarting) {
            updateRemoteVideoState(uidStr, true);
          }
        } catch (e) {
          if (kDebugMode) print('onRemoteVideoStateChanged handler error: $e');
        }
      },
    );
  }

  // ---------------- engine diagnostics & volume ----------------

  Future<void> _enableAudioVolumeIndication() async {
    try {
      _engine = _getEngine();
      if (_engine == null) {
        if (kDebugMode) print('_enableAudioVolumeIndication: engine null');
        return;
      }
      // interval(ms)=200, smooth=3, enableVad=true
      try {
        await _engine!.enableAudioVolumeIndication(
          interval: 200,
          smooth: 3,
          reportVad: true,
        );
        if (kDebugMode) print('enableAudioVolumeIndication OK');
      } catch (e) {
        if (kDebugMode) print('enableAudioVolumeIndication error: $e');
      }
    } catch (e) {
      if (kDebugMode) print('_enableAudioVolumeIndication outer error: $e');
    }
  }

  // ---------------- determine user type (placeholder) ----------------
  String _determineUserType(int remoteUid) {
    String inferredRemoteRole = 'coach';
    try {
      final dashboard = Get.find<DashboardController>();
      final localTypeRaw =
          dashboard.user.value.type?.toLowerCase().trim() ?? 'user';
      inferredRemoteRole = localTypeRaw == 'coach' ? 'user' : 'coach';

      // Handle the common roles explicitly
      switch (localTypeRaw) {
        case 'coach':
          return 'user';
        case 'user':
        case 'client':
        case 'customer':
        case 'member':
        case 'coachee':
        case 'student':
          return 'coach';
      }

      final booking = selectedBooking.value;
      if (booking != null) {
        final remoteUidStr = remoteUid.toString();
        if ((booking.coachId ?? '').toString() == remoteUidStr) {
          return 'coach';
        }
        if ((booking.userId ?? '').toString() == remoteUidStr) {
          return 'user';
        }
        if ((booking.coach?.id ?? '').toString() == remoteUidStr) {
          return 'coach';
        }
        if ((booking.user?.id ?? '').toString() == remoteUidStr) {
          return 'user';
        }
      }

      return inferredRemoteRole;
    } catch (_) {
      return inferredRemoteRole;
    }
  }

  void _handleUserEvent(
    String reason,
    String bookingIdParam, {
    String? userId,
    String? userType,
  }) {
    if (_isDisposed) return;
    Future.microtask(() {
      String uid =
          userId ??
          Get.find<DashboardController>().user.value.id?.toString() ??
          "0";
      String utype =
          (userType ??
                  Get.find<DashboardController>().user.value.type ??
                  "user")
              .toString()
              .toLowerCase();
      handleUserLeft(DateTime.now(), uid, utype, bookingIdParam, reason);
    });
  }

  // ---------------- booking status monitoring ----------------
  void _startBookingStatusMonitoring(String bookingIdParam) {
    _bookingStatusTimer?.cancel();
    _bookingStatusTimer = Timer.periodic(const Duration(seconds: 30), (
      timer,
    ) async {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      try {
        final response = await BookingRepository().checkBookingStatus(
          bookingIdParam,
        );
        if (response.statusCode == 200) {
          final body = jsonDecode(response.body);
          final status =
              (body is Map && body['status'] != null)
                  ? body['status'].toString()
                  : response.body.toString();
          if (status.toLowerCase().contains('cancel')) {
            MessagesManager.showErrorMessage('Booking cancelled'.tr);
            await leaveChannel(reason: CallTerminationReason.cancelled);
            timer.cancel();
          } else if (status.toLowerCase().contains('complete') ||
              status.toLowerCase().contains('completed')) {
            MessagesManager.showSuccessMessage('Booking completed'.tr);
            await leaveChannel(reason: CallTerminationReason.completed);
            timer.cancel();
          }
        }
      } catch (e) {
        if (kDebugMode) print("Error checking booking status: $e");
      }
    });
  }

  /// Start call expiry and remaining timers using server-provided remaining seconds.
  void _startCallDurationTimerSeconds(int remainingSeconds) {
    // cancel existing timers if any
    _callExpiryTimer?.cancel();
    _callRemainingTimer?.cancel();
    _fiveMinuteWarningSent = false;
    _oneMinuteCountdownTriggered = false;
    _callDurationHandled = false;
    fiveMinuteReminderSecondsLeft.value = 0;

    // set callEndTime and remaining seconds (UI will use callRemainingSeconds)
    callRemainingSeconds.value = remainingSeconds;
    callDurationSeconds = remainingSeconds;
    callEndTime.value = DateTime.now().toUtc().add(
      Duration(seconds: remainingSeconds),
    );
    callStarted.value = true;

    // expiry timer: leave after remainingSeconds + buffer (buffer = 2 minutes)
    const int bufferSeconds = 120;
    _callExpiryTimer = Timer(
      Duration(seconds: remainingSeconds + bufferSeconds),
      () async {
        if (!_isDisposed) {
          if (kDebugMode) print("Call duration timer expired, leaving channel");
          await leaveChannel(reason: CallTerminationReason.durationEnded);
        }
      },
    );

    // per-second timer to update remaining seconds for UI and trigger alerts
    _callRemainingTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_isDisposed) {
        t.cancel();
        return;
      }
      final nextValue = (callRemainingSeconds.value - 1).clamp(0, 1 << 31);
      callRemainingSeconds.value = nextValue;

      if (fiveMinuteReminderSecondsLeft.value > 0) {
        fiveMinuteReminderSecondsLeft
            .value = (fiveMinuteReminderSecondsLeft.value - 1).clamp(0, 10);
      }

      if (!_fiveMinuteWarningSent && nextValue == 300) {
        _fiveMinuteWarningSent = true;
        fiveMinuteReminderSecondsLeft.value = 10;
      }

      if (!_oneMinuteCountdownTriggered && nextValue <= 60) {
        _oneMinuteCountdownTriggered = true;
        _showInCallNotification(
          'call_time_warning_title'.tr,
          'call_final_minute_warning'.tr,
        );
      }

      if (!_callDurationHandled && nextValue == 0) {
        _callDurationHandled = true;
        t.cancel();
        _callExpiryTimer?.cancel();
        setCallStatusLabel('call_status_leaving');
        setIsCallLoading(true);
        unawaited(leaveChannel(reason: CallTerminationReason.durationEnded));
      }
    });
  }

  void _showInCallNotification(String title, String message) {
    if (Get.isSnackbarOpen == true) {
      Get.closeCurrentSnackbar();
    }
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.primaryColor,
      colorText: AppColors.lightTextColor,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
    );
  }

  // ---------------- public leave / alias ----------------
  Future<void> leaveChannel({
    CallTerminationReason reason = CallTerminationReason.general,
    bool showSummary = true,
  }) async {
    await leavChannel(reason: reason, showSummary: showSummary);
  }

  Future<void> leavChannel({
    CallTerminationReason reason = CallTerminationReason.general,
    bool showSummary = true,
  }) async {
    await _leaveChannelInternal(reason: reason, showSummary: showSummary);
  }

  Future<void> _leaveChannelInternal({
    required CallTerminationReason reason,
    required bool showSummary,
  }) async {
    if (_isDisposed) return;
    if (_isLeavingChannel) return;
    _isLeavingChannel = true;
    try {
      setCallStatusLabel('call_status_leaving');
      setIsCallLoading(true);
      _navigatedToSummary = false;
      _bookingStatusTimer?.cancel();
      _callExpiryTimer?.cancel();
      _callRemainingTimer?.cancel();
      await _safeLeaveAndRelease();
      connectedUsers.clear();
      _lastTerminationReason = reason;
      Future.delayed(const Duration(milliseconds: 200), () async {
        if (_isDisposed) return;
        await onLeaveChannel(showSummary: showSummary);
      });
    } catch (e) {
      if (kDebugMode) print("Error leaving channel: $e");
      if (showSummary) {
        await _navigateToSummary(reason);
      } else if (Get.currentRoute != AppRoutes.dashboardScreen) {
        Get.toNamed(AppRoutes.dashboardScreen);
      }
    } finally {
      _isLeavingChannel = false;
      setIsCallLoading(false);
    }
  }

  Future<void> _navigateToSummary(CallTerminationReason reason) async {
    if (_navigatedToSummary) return;
    _navigatedToSummary = true;
    final args = _buildSummaryArgs(reason);
    await Get.offAllNamed(AppRoutes.callSummaryScreen, arguments: args);
    _lastTerminationReason = null;
  }

  Map<String, String> _buildSummaryArgs(CallTerminationReason reason) {
    switch (reason) {
      case CallTerminationReason.manualHangup:
        return {
          'title': 'call_summary_manual_title'.tr,
          'message': 'call_summary_manual_message'.tr,
        };
      case CallTerminationReason.coachNoShow:
        return {
          'title': 'call_summary_no_show_title'.tr,
          'message': 'call_summary_no_show_message'.tr,
        };
      case CallTerminationReason.userNoShow:
        return {
          'title': 'call_summary_user_no_show_title'.tr,
          'message': 'call_summary_user_no_show_message'.tr,
        };
      case CallTerminationReason.coachEnded:
        return {
          'title': 'call_summary_coach_ended_title'.tr,
          'message': 'call_summary_coach_ended_message'.tr,
        };
      case CallTerminationReason.userEnded:
        return {
          'title': 'call_summary_user_ended_title'.tr,
          'message': 'call_summary_user_ended_message'.tr,
        };
      case CallTerminationReason.durationEnded:
        return {
          'title': 'call_summary_duration_title'.tr,
          'message': 'call_summary_duration_message'.tr,
        };
      case CallTerminationReason.cancelled:
        return {
          'title': 'call_summary_cancelled_title'.tr,
          'message': 'call_summary_cancelled_message'.tr,
        };
      case CallTerminationReason.completed:
        return {
          'title': 'call_summary_completed_title'.tr,
          'message': 'call_summary_completed_message'.tr,
        };
      case CallTerminationReason.connectionError:
        return {
          'title': 'call_summary_error_title'.tr,
          'message': 'call_summary_error_message'.tr,
        };
      case CallTerminationReason.general:
        return {
          'title': 'call_summary_generic_title'.tr,
          'message': 'call_summary_generic_message'.tr,
        };
    }
  }

  Future<void> onLeaveChannel({bool showSummary = true}) async {
    if (_isDisposed) return;
    final dashboard = Get.find<DashboardController>();
    final userType = dashboard.user.value.type?.toLowerCase() ?? 'user';
    handleUserLeft(
      DateTime.now(),
      dashboard.user.value.id ?? "0",
      userType,
      bookingId.value,
      "left",
    );
    connectedUsers.clear();
    try {
      await BookingRepository().quitCall(bookingId.value);
    } catch (_) {}
    final terminationReason =
        _lastTerminationReason ?? CallTerminationReason.general;

    if (userType == "user") {
      if (terminationReason == CallTerminationReason.coachNoShow) {
        if (showSummary) {
          await _navigateToSummary(terminationReason);
        } else if (Get.currentRoute != AppRoutes.dashboardScreen) {
          Get.offAllNamed(AppRoutes.dashboardScreen);
        }
        return;
      }
      await Get.bottomSheet(
        GetBuilder<BookingController>(
          builder: (controller) {
            return RateWidget(
              onRatingChanged: (rating) => controller.setRate(rating),
              rating: controller.rate.value,
              commentController: ratingController,
              onSubmit: () {
                controller.isRatingLoading.value = true;
                controller.update();
                CoachsRepository()
                    .rateCoach(
                      controller.rate.value,
                      controller.ratingController.text,
                      bookingId.value,
                    )
                    .then((response) {
                      controller.isRatingLoading.value = false;
                      controller.update();
                      if (response.statusCode == 200) {
                        MessagesManager.showSuccessMessage(
                          'Rated successfully'.tr,
                        );
                        if (showSummary) {
                          Get.back();
                          _lastTerminationReason ??=
                              CallTerminationReason.general;
                          unawaited(
                            _navigateToSummary(_lastTerminationReason!),
                          );
                        } else {
                          Get.back();
                          if (Get.currentRoute != AppRoutes.dashboardScreen) {
                            Get.offAllNamed(AppRoutes.dashboardScreen);
                          }
                        }
                      } else {
                        MessagesManager.showErrorMessage('Failed to rate'.tr);
                      }
                    });
              },
              isSubmitting: controller.isRatingLoading.value,
            );
          },
        ),
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
      );
    } else {
      if (showSummary) {
        _lastTerminationReason ??= CallTerminationReason.general;
        await _navigateToSummary(_lastTerminationReason!);
      } else if (Get.currentRoute != AppRoutes.dashboardScreen) {
        Get.offAllNamed(AppRoutes.dashboardScreen);
      }
    }
  }

  // ---------------- wait/no-show logic ----------------
  void reevaluateWaitTimer() {
    if (_isDisposed) return;
    _evaluateWaitTimer();
  }

  String _resolveLocalRole() {
    try {
      final type =
          Get.find<DashboardController>().user.value.type?.toLowerCase();
      if (type == 'coach') {
        return 'coach';
      }
    } catch (_) {}
    return 'user';
  }

  String? _resolveLocalParticipantId() {
    if (localUser != null && localUser!.id.isNotEmpty) {
      return localUser!.id;
    }
    try {
      final dashId = Get.find<DashboardController>().user.value.id?.toString();
      if (dashId != null && dashId.isNotEmpty) {
        return dashId;
      }
    } catch (_) {}
    final booking = selectedBooking.value;
    if (booking != null) {
      final localRole = _resolveLocalRole();
      if (localRole == 'coach') {
        final coachId = booking.coachId?.toString();
        if (coachId != null && coachId.isNotEmpty) return coachId;
      } else {
        final userId = booking.userId?.toString();
        if (userId != null && userId.isNotEmpty) return userId;
      }
    }
    return null;
  }

  bool _hasParticipantWithRole(String role) {
    final target = role.toLowerCase();
    return connectedUsers.any((u) => (u.type).toLowerCase() == target);
  }

  bool _hasOtherParticipantsInChannel() {
    if (connectedUsers.isEmpty) return false;
    final localId = _resolveLocalParticipantId();
    if (localId == null || localId.isEmpty) {
      return connectedUsers.length > 1;
    }
    return connectedUsers.any((u) => u.id != localId);
  }

  void _evaluateWaitTimer() {
    final currentType = _resolveLocalRole();
    final targetRole = currentType == 'coach' ? 'user' : 'coach';

    if (_hasParticipantWithRole(targetRole) ||
        _hasOtherParticipantsInChannel()) {
      _stopWaitTimer();
    } else {
      _startWaitTimer(targetRole: targetRole);
    }
  }

  void _startWaitTimer({required String targetRole}) {
    final sameTarget = waitRunning.value && _waitTargetRole == targetRole;
    if (sameTarget) return;
    waitLeftSeconds.value = waitSeconds;
    waitRunning.value = true;
    waitingForRole.value = targetRole;
    _waitTargetRole = targetRole;
    _logWaitEvent(targetRole);
    _waitTimer?.cancel();
    _waitTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_isDisposed) {
        t.cancel();
        waitRunning.value = false;
        waitingForRole.value = null;
        return;
      }
      waitLeftSeconds.value = waitLeftSeconds.value - 1;
      if (waitLeftSeconds.value <= 0) {
        t.cancel();
        waitRunning.value = false;
        waitingForRole.value = null;
        handleNoShowTimeout();
      }
    });
  }

  void _stopWaitTimer() {
    _waitTimer?.cancel();
    waitRunning.value = false;
    waitLeftSeconds.value = 0;
    waitingForRole.value = null;
    _waitTargetRole = null;
  }

  void _logWaitEvent(String targetRole) {
    try {
      final dashboard = Get.find<DashboardController>();
      final uid = dashboard.user.value.id?.toString() ?? "0";
      final utype = dashboard.user.value.type?.toLowerCase() ?? "user";
      final bookingIdLocal = activeBookingId ?? bookingId.value;
      if (bookingIdLocal.isEmpty) return;
      final reason =
          targetRole == 'coach' ? 'waiting_for_coach' : 'waiting_for_user';
      handleUserLeft(DateTime.now(), uid, utype, bookingIdLocal, reason);
    } catch (_) {}
  }

  void updateLocalVideoState(bool enabled) {
    try {
      final session = client?.sessionController;
      if (session != null) {
        final localUid = session.value.localUid;
        if (localUid != 0) {
          session.updateUserVideo(uid: localUid, videoDisabled: !enabled);
        } else {
          session.value = session.value.copyWith(
            isLocalVideoDisabled: !enabled,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) print('updateLocalVideoState session error: $e');
    }

    final localId = _resolveLocalParticipantId();
    if (localId == null || localId.isEmpty) return;

    final idx = connectedUsers.indexWhere((u) => u.id == localId);
    if (idx != -1) {
      connectedUsers[idx].videoEnabled = enabled;
      connectedUsers[idx].lastSeen = DateTime.now();
    }
  }

  void updateRemoteVideoState(String uid, bool enabled) {
    if (uid.isEmpty) return;
    final idx = connectedUsers.indexWhere((u) => u.id == uid);
    if (idx != -1) {
      connectedUsers[idx].videoEnabled = enabled;
      connectedUsers[idx].lastSeen = DateTime.now();
    }
  }

  void syncConnectedUsersFromSession() {
    if (_isDisposed) return;
    try {
      final sessionController = client?.sessionController;
      if (sessionController == null) return;
      final session = sessionController.value;
      final localUidStr = session.localUid.toString();
      final localRole = _resolveLocalRole();

      final Map<String, ConnectedUser> merged = {
        for (final user in connectedUsers) user.id: user,
      };

      void upsertFromAgoraUser(AgoraUser agUser, {required bool remote}) {
        final uidStr = agUser.uid.toString();
        if (uidStr.isEmpty) return;
        final existing =
            merged[uidStr] ??
            ConnectedUser(
              id: uidStr,
              type: remote ? _determineUserType(agUser.uid) : localRole,
              joinedAt: DateTime.now(),
            );
        existing.type = remote ? _determineUserType(agUser.uid) : localRole;
        existing.lastSeen = DateTime.now();
        existing.audioEnabled = !agUser.muted;
        existing.videoEnabled = !agUser.videoDisabled;
        merged[uidStr] = existing;
        if (!remote) {
          localUser = existing;
          currentUser = existing;
        }
      }

      final mainUser = session.mainAgoraUser;
      if (mainUser.uid != 0) {
        final isRemote = mainUser.uid.toString() != localUidStr;
        upsertFromAgoraUser(mainUser, remote: isRemote);
      }

      for (final agUser in session.users) {
        final isRemote = agUser.uid.toString() != localUidStr;
        upsertFromAgoraUser(agUser, remote: isRemote);
      }

      connectedUsers.assignAll(merged.values);
      _evaluateWaitTimer();
    } catch (e) {
      if (kDebugMode) print('syncConnectedUsersFromSession error: $e');
    }
  }

  Future<void> _processCoachNoShowRefund(
    String bookingId,
    double amount,
  ) async {
    try {
      final res = await BookingRepository().refundBooking(bookingId, amount);
      if (res.statusCode != 200 && kDebugMode) {
        print('Refund failed: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      if (kDebugMode) print('refundBooking error: $e');
    }
  }

  double _resolvePaidAmount() {
    if (paidAmount > 0) return paidAmount;
    final booking = selectedBooking.value;
    if (booking != null) {
      final parsed = double.tryParse(booking.amount ?? '');
      if (parsed != null && parsed > 0) return parsed;
    }
    return 0.0;
  }

  Future<void> handleNoShowTimeout() async {
    if (_isDisposed) return;
    final targetRole = waitingForRole.value ?? _waitTargetRole;
    final bookingIdLocal = activeBookingId ?? bookingId.value;
    final normalizedTarget = targetRole?.toLowerCase();
    final expectedJoined =
        normalizedTarget != null &&
        normalizedTarget.isNotEmpty &&
        _hasParticipantWithRole(normalizedTarget);
    final othersPresent = _hasOtherParticipantsInChannel();

    if (expectedJoined || othersPresent) {
      _stopWaitTimer();
      return;
    }

    if (normalizedTarget == 'coach') {
      final refundAmount = _resolvePaidAmount();
      _stopWaitTimer();

      unawaited(leavChannel(reason: CallTerminationReason.coachNoShow));

      if (bookingIdLocal.isEmpty) {
        if (kDebugMode) {
          print('No booking ID resolved; skipping refund API');
        }
        return;
      }

      if (refundAmount <= 0) {
        if (kDebugMode) {
          print('No refund amount resolved; skipping refund API');
        }
        return;
      }

      unawaited(_processCoachNoShowRefund(bookingIdLocal, refundAmount));
      return;
    }

    if (normalizedTarget == 'user') {
      _stopWaitTimer();
      unawaited(leavChannel(reason: CallTerminationReason.userNoShow));
      return;
    }

    _stopWaitTimer();
  }

  CallTerminationReason? _mapRemoteLeaveReason(
    String? remoteRole,
    UserOfflineReasonType reason,
  ) {
    final normalizedRole = (remoteRole ?? '').toLowerCase();
    switch (reason) {
      case UserOfflineReasonType.userOfflineQuit:
        if (normalizedRole == 'coach' || normalizedRole == 'trainer') {
          return CallTerminationReason.coachEnded;
        }
        if (normalizedRole == 'user' ||
            normalizedRole == 'client' ||
            normalizedRole == 'customer' ||
            normalizedRole == 'member' ||
            normalizedRole == 'coachee' ||
            normalizedRole == 'student') {
          return CallTerminationReason.userEnded;
        }
        return CallTerminationReason.general;
      case UserOfflineReasonType.userOfflineDropped:
        return CallTerminationReason.connectionError;
      case UserOfflineReasonType.userOfflineBecomeAudience:
        return CallTerminationReason.general;
    }
  }

  // ---------------- mute / speaker / retry helpers ----------------
  Future<void> toggleLocalMute() async {
    localMuted.value = !localMuted.value;
    final engine = _getEngine();
    try {
      if (engine != null) {
        await engine.muteLocalAudioStream(localMuted.value);
        if (kDebugMode) print('muteLocalAudioStream -> ${localMuted.value}');
      } else {
        // try sessionController high-level API if present
        try {
          await engine?.muteLocalAudioStream(localMuted.value);
        } catch (e) {
          if (kDebugMode) print('fallback muteLocalAudio failed: $e');
        }
      }
    } catch (e) {
      if (kDebugMode) print('toggleLocalMute error: $e');
    }
  }

  Future<void> forceUnmuteLocal() async {
    localMuted.value = false;
    final engine = _getEngine();
    try {
      if (engine != null) {
        await engine.muteLocalAudioStream(false);
        if (kDebugMode) print('forceUnmuteLocal done');
      } else {
        try {
          await engine?.muteLocalAudioStream(false);
        } catch (e) {
          if (kDebugMode) print('forceUnmuteLocal fallback failed: $e');
        }
      }
    } catch (e) {
      if (kDebugMode) print('forceUnmuteLocal error: $e');
    }
  }

  Future<void> toggleSpeaker() async {
    speakerOn.value = !speakerOn.value;
    final engine = _getEngine();
    try {
      if (engine != null) {
        await engine.setEnableSpeakerphone(speakerOn.value);
        if (kDebugMode) print('setEnableSpeakerphone -> ${speakerOn.value}');
      } else {
        try {
          await engine?.setEnableSpeakerphone(speakerOn.value);
        } catch (e) {
          if (kDebugMode) print('fallback setSpeakerphone failed: $e');
        }
      }
    } catch (e) {
      if (kDebugMode) print('toggleSpeaker error: $e');
    }
  }

  Future<void> forceSpeakerOn() async {
    speakerOn.value = true;
    final engine = _getEngine();
    try {
      if (engine != null) {
        await engine.setEnableSpeakerphone(true);
        if (kDebugMode) print('forceSpeakerOn done');
      } else {
        try {
          await engine?.setEnableSpeakerphone(true);
        } catch (e) {
          if (kDebugMode) print('forceSpeakerOn fallback failed: $e');
        }
      }
    } catch (e) {
      if (kDebugMode) print('forceSpeakerOn error: $e');
    }
  }

  Future<void> retryConnection() async {
    if (_isDisposed) return;
    setCallStatusLabel('call_status_reconnecting');
    setIsCallLoading(true);
    try {
      // simple retry: leave & allow UI to call initAgoraCall again with same params
      await _safeLeaveAndRelease();
      // clear participants
      connectedUsers.clear();
    } catch (e) {
      if (kDebugMode) print('retryConnection error: $e');
    } finally {
      setIsCallLoading(false);
    }
  }

  // ---------------- new: set local video enabled ----------------
  Future<void> setLocalVideoEnabled(bool enabled) async {
    if (_isDisposed) return;
    localVideoEnabled.value = enabled;
    final engine = _getEngine();
    try {
      if (engine != null) {
        // enable/disable local camera preview & stream
        try {
          await engine.enableLocalVideo(enabled);
        } catch (_) {
          // some versions may not support enableLocalVideo; fallback to muteLocalVideoStream
        }
        try {
          await engine.muteLocalVideoStream(!enabled);
        } catch (_) {}
        if (kDebugMode) print('setLocalVideoEnabled -> $enabled');
      } else {
        if (kDebugMode) print('setLocalVideoEnabled engine null');
      }
    } catch (e) {
      if (kDebugMode) print('setLocalVideoEnabled error: $e');
    }
    updateLocalVideoState(enabled);
  }

  // ---------------- new: apply preview settings and mark joined ----------------
  /// Apply preview preferences (micOn, camOn) locally and mark call as started.
  /// The UI (pre-call) calls this so user won't see extra notifications.
  Future<void> applyPreviewAndJoin(bool micOn, bool camOn) async {
    if (_isDisposed) return;

    try {
      // 1) apply mic preference
      // micOn == true -> want unmuted
      if (micOn) {
        if (localMuted.value) {
          await forceUnmuteLocal();
        }
      } else {
        if (!localMuted.value) {
          await toggleLocalMute();
        }
      }

      // 2) apply camera preference
      await setLocalVideoEnabled(camOn);

      // 3) mark call as started in controller (UI relies on this)
      callStarted.value = true;

      // Note: actual joining of the channel normally happens during client.initialize()
      // or elsewhere in your flow (initAgoraCall). Here we only ensure local settings
      // and controller timing states are set. If you need to explicitly join here,
      // implement a joinChannel() method that calls client.sessionController.join() or similar.
    } catch (e) {
      if (kDebugMode) print('applyPreviewAndJoin error: $e');
      rethrow;
    }
  }

  // ---------------- In-call messaging / notifications / support (NEW) ----------------

  /// Send an in-call presence notification to the other role (e.g., notify coach that user is waiting).
  /// This calls an API in BookingRepository if available. If repository doesn't implement it,
  /// the method will print debug info and throw.
  Future<void> sendInCallNotification(String targetRole) async {
    if (_isDisposed) return;
    final bookingIdLocal = activeBookingId ?? bookingId.value;
    if (bookingIdLocal.isEmpty) {
      if (kDebugMode) print('sendInCallNotification: no booking id available');
      throw Exception('No booking id available');
    }
    try {
      // Expectation: BookingRepository has a method sendInCallNotification(bookingId, role)
      final res = await BookingRepository().sendInCallNotification(
        bookingIdLocal,
        targetRole,
      );
      if (res.statusCode == 200) {
        if (kDebugMode) print('sendInCallNotification succeeded');
        return;
      } else {
        if (kDebugMode) print('sendInCallNotification failed: ${res.body}');
        throw Exception('sendInCallNotification failed');
      }
    } catch (e) {
      if (kDebugMode) print('sendInCallNotification error: $e');
      // rethrow so caller (UI) can show snackbar if needed
      rethrow;
    }
  }

  /// Send an in-call chat message to backend (text-based). `message` is a map with keys
  /// like 'fromRole','text','timestamp','attachmentUrl' (optional).
  Future<void> sendInCallMessage(Map<String, dynamic> message) async {
    if (_isDisposed) return;
    final bookingIdLocal = activeBookingId ?? bookingId.value;
    if (bookingIdLocal.isEmpty) {
      if (kDebugMode) print('sendInCallMessage: no booking id available');
      throw Exception('No booking id available');
    }
    try {
      // Expectation: BookingRepository has sendInCallMessage(bookingId, message)
      final res = await BookingRepository().sendInCallMessage(
        bookingIdLocal,
        message,
      );
      if (res.statusCode == 200) {
        if (kDebugMode) print('sendInCallMessage succeeded');
        return;
      } else {
        if (kDebugMode) print('sendInCallMessage failed: ${res.body}');
        throw Exception('sendInCallMessage failed');
      }
    } catch (e) {
      if (kDebugMode) print('sendInCallMessage error: $e');
      rethrow;
    }
  }

  /// Upload a file for in-call chat, then send a message referencing the uploaded file.
  /// Expects BookingRepository.uploadInCallFile(bookingId, File) to return {url: "..."} or similar.
  Future<void> uploadInCallFile(File file, Map<String, dynamic> message) async {
    if (_isDisposed) return;
    final bookingIdLocal = activeBookingId ?? bookingId.value;
    if (bookingIdLocal.isEmpty) {
      if (kDebugMode) print('uploadInCallFile: no booking id available');
      throw Exception('No booking id available');
    }
    try {
      final res = await BookingRepository().uploadInCallFile(
        bookingIdLocal,
        file,
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final url = body['url'] ?? body['fileUrl'];
        if (url != null) {
          message['attachmentUrl'] = url;
          // forward the message now (text + attachmentUrl)
          await sendInCallMessage(message);
          return;
        } else {
          if (kDebugMode)
            print('uploadInCallFile: no url in response: ${res.body}');
          throw Exception('uploadInCallFile: invalid response');
        }
      } else {
        if (kDebugMode) print('uploadInCallFile failed: ${res.body}');
        throw Exception('uploadInCallFile failed');
      }
    } catch (e) {
      if (kDebugMode) print('uploadInCallFile error: $e');
      rethrow;
    }
  }

  /// Open a support ticket / send a message to support (used by support modal).
  Future<void> openSupportTicket(String text) async {
    if (_isDisposed) return;
    final bookingIdLocal = activeBookingId ?? bookingId.value;
    try {
      final res = await BookingRepository().openSupportTicket(
        bookingIdLocal,
        text,
      );
      if (res.statusCode == 200) {
        if (kDebugMode) print('openSupportTicket succeeded');
        return;
      } else {
        if (kDebugMode) print('openSupportTicket failed: ${res.body}');
        throw Exception('openSupportTicket failed');
      }
    } catch (e) {
      if (kDebugMode) print('openSupportTicket error: $e');
      rethrow;
    }
  }

  // ---------------- booking & payments (kept) ----------------
  bool setBookingRequest({
    String? paymentStatus,
    String? paymentId,
    String? paymentMethod,
  }) {
    final coachIdLocal = Get.find<CoachController>().selectedCoach.value.id;
    if (coachIdLocal == null || coachIdLocal.isEmpty) {
      MessagesManager.showErrorMessage('Please select a coach'.tr);
      return false;
    } else if (selectedSchedule.value.date == null) {
      MessagesManager.showErrorMessage('Please select a schedule'.tr);
      return false;
    } else if (selectedSlot.value.time == null) {
      MessagesManager.showErrorMessage('Please select a slot'.tr);
      return false;
    } else if (selectedConnectionType.value.isEmpty) {
      MessagesManager.showErrorMessage('Please select a connection type'.tr);
      return false;
    } else {
      String time = selectedSlot.value.time.toString();
      List<String> timeList = time.split(":");
      if (timeList.length >= 2) {
        time = "${timeList[0]}:${timeList[1]}:00";
      } else {
        time = "${timeList[0]}:00:00";
      }
      bookingRequest.value = BookingRequest(
        coachId: coachIdLocal,
        connectionType: selectedConnectionType.value,
        date: selectedSchedule.value.date.toString(),
        time: time,
        duration: Get.find<CoachController>().duration.value,
        amount: (tax.value + amount.value + timeAmount.value).toString(),
        paymentStatus: paymentStatus,
        paymentId: paymentId,
        paymentMethod: paymentMethod,
      );
      return true;
    }
  }

  Future<bool> book(
    String paymentStatus,
    String paymentId,
    String paymentMethod,
  ) async {
    if (_isDisposed) return false;
    final validation = setBookingRequest(
      paymentStatus: paymentStatus,
      paymentId: paymentId,
      paymentMethod: paymentMethod,
    );
    if (!validation) return false;
    setIsLoading(true);
    try {
      final response = await BookingRepository().createBooking(
        bookingRequest.value.toJson(),
      );
      if (response.statusCode == 200) {
        final booking = Booking.fromJson(jsonDecode(response.body));
        if (paymentMethod != "tabby") {
          await successBooking(booking);
        }
        return true;
      } else {
        final errorBody = jsonDecode(response.body);
        if (errorBody['error'] != null) {
          Get.back();
          await MessagesManager.showErrorMessage(
            errorBody['error'].toString().tr,
          );
          return false;
        } else {
          if (paymentMethod != "tabby")
            MessagesManager.showErrorMessage('Failed to book'.tr);
          return false;
        }
      }
    } catch (e) {
      if (kDebugMode) print("Error in booking: $e");
      await MessagesManager.showErrorMessage(
        'An error occurred while booking'.tr,
      );
      return false;
    } finally {
      setIsLoading(false);
    }
  }

  Future<void> successBooking(Booking booking) async {
    MessagesManager.showSuccessMessage('Booking successful'.tr);
    Utils.subscribeToTopic(booking.connectId.toString());
    Get.find<DashboardController>().fetchAppointments();
    try {
      Utils.logInAppPurchaseEvent(
        "booking from user with id ${Get.find<DashboardController>().user.value.id} ios",
        amount.value + tax.value + timeAmount.value,
      );
      FacebookAppEvents().logPurchase(
        amount: amount.value + tax.value + timeAmount.value,
        currency: "SAR",
        parameters: {
          "booking_id": booking.id.toString(),
          "booking_status": booking.status,
          "booking_date": selectedSchedule.value.date.toString(),
          "booking_time": selectedSlot.value.time.toString(),
          "booking_duration": Get.find<CoachController>().duration.value,
          "booking_connection_type": selectedConnectionType.value,
        },
      );
      Utils.logTikTokEvent("purchase");
    } catch (e) {
      if (kDebugMode) print("Error logging events: $e");
    }
    selectedBooking.value = booking;
    Get.offNamedUntil(
      AppRoutes.bookingDetails,
      (route) => route.settings.name == AppRoutes.dashboardScreen,
    );
    amount.value = 0.0;
    tax.value = 0.0;
    timeAmount.value = 0.0;
  }

  void initialisePayment() async {
    if (_isDisposed) return;
    setIsLoading(true);
    try {
      final validation = setBookingRequest();
      if (!validation) {
        setIsLoading(false);
        return;
      }
      final response = await BookingRepository().checkBookingTime(
        bookingRequest.value.toJson(),
      );
      if (response.statusCode == 200) {
        try {
          Utils.logEvent("add_payment_info", {
            "amount": amount.value + tax.value + timeAmount.value,
            "currency": "SAR",
            "value": "0",
            "payment_type": "wallet",
            "booking_id": "0",
            "booking_status": "pending",
            "booking_date": selectedSchedule.value.date.toString(),
            "booking_time": selectedSlot.value.time.toString(),
            "booking_duration": Get.find<CoachController>().duration.value,
            "booking_connection_type": selectedConnectionType.value,
          });
          FacebookAppEvents().logEvent(
            name: "add_payment_info",
            parameters: {
              "amount": amount.value + tax.value + timeAmount.value,
              "currency": "SAR",
              "value": "0",
              "payment_type": "wallet",
              "booking_id": "0",
              "booking_status": "pending",
              "booking_date": selectedSchedule.value.date.toString(),
              "booking_time": selectedSlot.value.time.toString(),
              "booking_duration": Get.find<CoachController>().duration.value,
              "booking_connection_type": selectedConnectionType.value,
            },
          );
          Utils.logTikTokEvent("add_payment_info");
        } catch (e) {
          if (kDebugMode) print("Error logging payment events: $e");
        }
        await Utils.initializePayWithCardSdk(
          amount.value + tax.value + timeAmount.value,
          "test@test.com",
          "+201093455436",
          true,
        );
      } else {
        final errorBody = jsonDecode(response.body);
        if (errorBody['error'] != null) {
          MessagesManager.showErrorMessage(errorBody['error'].toString().tr);
        } else {
          MessagesManager.showErrorMessage('Failed to book'.tr);
        }
      }
    } catch (e) {
      if (kDebugMode) print("Error in payment initialization: $e");
      MessagesManager.showErrorMessage(
        'An error occurred during payment initialization'.tr,
      );
    } finally {
      setIsLoading(false);
    }
  }

  void payWithWallet() async {
    if (_isDisposed) return;
    setIsLoading(true);
    try {
      final validation = setBookingRequest();
      if (!validation) {
        setIsLoading(false);
        return;
      }
      final response = await BookingRepository().checkBookingTime(
        bookingRequest.value.toJson(),
      );
      if (response.statusCode == 200) {
        final paymentResponse = await BookingRepository().payWithWallet(
          bookingRequest.value.toJson(),
        );
        if (paymentResponse.statusCode == 200) {
          final booking = Booking.fromJson(jsonDecode(paymentResponse.body));
          MessagesManager.showSuccessMessage('Booking successful'.tr);
          Utils.logTikTokEvent("purchase");
          Utils.subscribeToTopic(booking.connectId.toString());
          Get.find<DashboardController>().fetchAppointments();
          selectedBooking.value = booking;
          Get.offNamedUntil(
            AppRoutes.bookingDetails,
            (route) => route.settings.name == AppRoutes.dashboardScreen,
          );
          amount.value = 0.0;
          tax.value = 0.0;
          timeAmount.value = 0.0;
        } else {
          final errorBody = jsonDecode(paymentResponse.body);
          if (errorBody['error'] != null) {
            MessagesManager.showErrorMessage(errorBody['error'].toString().tr);
          } else {
            MessagesManager.showErrorMessage('Failed to book'.tr);
          }
        }
      } else {
        final errorBody = jsonDecode(response.body);
        if (errorBody['error'] != null) {
          MessagesManager.showErrorMessage(errorBody['error'].toString().tr);
        } else {
          MessagesManager.showErrorMessage('Failed to book'.tr);
        }
      }
    } catch (e) {
      if (kDebugMode) print("Error in wallet payment: $e");
      MessagesManager.showErrorMessage('An error occurred during payment'.tr);
    } finally {
      setIsLoading(false);
    }
  }

  void payWithTapy(BuildContext context) async {
    if (_isDisposed) return;
    setIsLoading(true);
    try {
      String uuid = Utils.generateUuid();
      final mockPayload = Payment(
        amount: (amount.value + tax.value + timeAmount.value).toString(),
        currency: Currency.sar,
        buyer: Buyer(
          email: '',
          phone: Get.find<DashboardController>().user.value.phone ?? "",
          name: Get.find<DashboardController>().user.value.name ?? "",
        ),
        buyerHistory: BuyerHistory(
          loyaltyLevel: 1,
          registeredSince:
              Get.find<DashboardController>().user.value.createdAt ?? "",
          isPhoneNumberVerified: true,
        ),
        shippingAddress: null,
        order: Order(
          referenceId: uuid,
          items: [
            OrderItem(
              title: 'online booking',
              quantity: 1,
              unitPrice:
                  (amount.value + tax.value + timeAmount.value).toString(),
              category: 'online booking',
            ),
          ],
        ),
        orderHistory: [],
      );

      final session = await TabbySDK().createSession(
        TabbyCheckoutPayload(
          merchantCode: 'Life coachsau',
          lang: Get.locale!.languageCode == 'ar' ? Lang.ar : Lang.en,
          payment: mockPayload,
        ),
      );

      bool successBooking = await book("draft", session.paymentId, "tabby");
      if (successBooking) {
        TabbyWebView.showWebView(
          context: Get.context!,
          webUrl: session.availableProducts.installments?.webUrl ?? '',
          onResult: (WebViewResult resultCode) {
            if (kDebugMode) print("WebView Result: $resultCode");
            Get.back();
            Get.offAllNamed(AppRoutes.waitingPaymentScreen);
          },
        );
      }
    } catch (e) {
      if (kDebugMode) print("Error in Tabby payment: $e");
      MessagesManager.showErrorMessage('Payment initialization failed'.tr);
    } finally {
      setIsLoading(false);
    }
  }

  // ---------------- debounced update ----------------
  @override
  void update([List<Object>? ids, bool condition = true]) {
    if (_isDisposed) return;
    _updateTimer?.cancel();
    _updateTimer = Timer(const Duration(milliseconds: 50), () {
      if (!_isDisposed) super.update(ids, condition);
    });
  }

  void _attachEngineDiagnostics() {
    try {
      final engine = client?.sessionController.value.engine;
      if (engine == null) {
        if (kDebugMode) print('attachAgoraDebugHandlers: engine is null');
        return;
      }

      // enable audio volume indication (interval ms, smooth, vad)
      try {
        // 200 ms interval, smooth level 3, enable VAD reporting
        engine.enableAudioVolumeIndication(
          interval: 200,
          smooth: 3,
          reportVad: true,
        );
        if (kDebugMode) print('AudioVolumeIndication enabled');
      } catch (e) {
        if (kDebugMode) print('enableAudioVolumeIndication failed: $e');
      }

      // set event handler
      engine.registerEventHandler(
        RtcEngineEventHandler(
          // user joined
          onUserJoined: (RtcConnection rt, int uid, int elapsed) {
            if (kDebugMode) print('RTC onUserJoined uid=$uid elapsed=$elapsed');
          },

          // user offline / left
          onUserOffline: (
            RtcConnection rt,
            int uid,
            UserOfflineReasonType reason,
          ) {
            if (kDebugMode) print('RTC onUserOffline uid=$uid reason=$reason');
          },

          // remote audio state changed
          onRemoteAudioStateChanged: (
            RtcConnection rt,
            int uid,
            RemoteAudioState state,
            RemoteAudioStateReason reason,
            int elapsed,
          ) {
            if (kDebugMode)
              print(
                'RTC onRemoteAudioStateChanged uid=$uid state=$state reason=$reason elapsed=$elapsed',
              );
            // update your connectedUsers audio flag if desired
            final idx = connectedUsers.indexWhere(
              (u) => u.id == uid.toString(),
            );
            if (idx != -1) {
              final receiving =
                  (state == RemoteAudioState.remoteAudioStateFailed ||
                          state == RemoteAudioState.remoteAudioStateDecoding ||
                          state == RemoteAudioState.remoteAudioStateStarting)
                      ? true
                      : (state == RemoteAudioState.remoteAudioStateStopped ||
                              state == RemoteAudioState.remoteAudioStateFrozen
                          ? false
                          : true);
              connectedUsers[idx].audioEnabled = receiving;
            }
            // recompute aggregate
            remoteAudioActive.value = connectedUsers.any((u) => u.audioEnabled);
          },

          // local audio state (muted/unmuted)
          onLocalAudioStateChanged: (
            RtcConnection rt,
            LocalAudioStreamState state,
            LocalAudioStreamReason error,
          ) {
            if (kDebugMode) print('RTC onLocalAudioStateChanged state=$state ');
          },

          // volume indication
          onAudioVolumeIndication: (
            RtcConnection rt,
            List<AudioVolumeInfo> speakers,
            int totalVolume,
            int? vad,
          ) {
            try {
              if (kDebugMode) {
                for (final s in speakers) {
                  print(
                    'RTC onAudioVolumeIndication uid=${s.uid} volume=${s.volume} vad=${s.vad}',
                  );
                }
                print('RTC onAudioVolumeIndication totalVolume=$totalVolume');
              }
            } catch (e) {
              if (kDebugMode) print('onAudioVolumeIndication error: $e');
            }
          },

          onConnectionLost: (RtcConnection rt) {
            if (kDebugMode) print('RTC onConnectionLost');
          },

          onConnectionStateChanged: (
            RtcConnection rt,
            ConnectionStateType state,
            ConnectionChangedReasonType reason,
          ) {
            if (kDebugMode)
              print('RTC onConnectionStateChanged state=$state reason=$reason');
          },
        ),
      );
    } catch (e) {
      if (kDebugMode) print('attachAgoraDebugHandlers unexpected: $e');
    }
  }
}
