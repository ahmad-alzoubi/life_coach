// lib/controller/chat_controller.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:coach_life/controller/dashboard_controller.dart';
import 'package:coach_life/model/conversation.dart';
import 'package:coach_life/model/message.dart';
import 'package:coach_life/model/user.dart';
import 'package:coach_life/repositories/booking_repository.dart';
import 'package:coach_life/repositories/chat_repository.dart';
import 'package:coach_life/repositories/coachs_repository.dart';
import 'package:coach_life/services/shared_preferances_manager.dart';
import 'package:coach_life/utils/messages/messages_manager.dart';
import 'package:coach_life/utils/utlis.dart';
import 'package:coach_life/view/widgets/rate_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:uuid/uuid.dart';

import '../routes/app_routes.dart';
import '../services/socket_service.dart';
import '../utils/api_routes.dart';
import '../view/widgets/chat_meesage_widget.dart';
import 'audio_player_manager.dart';

class ChatController extends GetxController {
  final SocketService _socketService = Get.find<SocketService>();
  late IO.Socket socket;
  RxList<Widget> chatMessages = <Widget>[].obs;
  RxString username = "".obs;
  final textController = TextEditingController();
  final scrollController = ScrollController();
  final RxString conversationId = "".obs;
  final RxBool isSending = false.obs;
  final RxBool inChatNow = false.obs;

  final Rx<Conversation> currentConversetion = Rx<Conversation>(Conversation());
  final record = AudioRecorder();
  late Timer recordingTimer;
  late Timer audioTimer;
  int recordingDuration = 0;
  RxBool isRecording = false.obs;
  RxBool showRecording = true.obs;
  final AudioPlayerManager _audioPlayerManager = Get.find<AudioPlayerManager>();
  List<Map<String, dynamic>> pendingMessages = [];
  final TextEditingController ratingController = TextEditingController();
  final RxBool isRatingLoading = false.obs;
  final RxInt rate = 0.obs;
  RxString conversatioId = "".obs;

  /// Initialize socket. If [navigate] is true, opens chat screen (old behavior).
  /// For in-call usage, pass navigate: false to only attach socket without navigation.
  Future<void> initSocket(
    BuildContext? context,
    Conversation conversation, {
    bool navigate = true,
  }) async {
    // normalize conversation id with fallbacks
    String convId =
        conversation.id ?? conversation.id ?? conversation.bookingId ?? '';
    convId = convId ?? '';

    if (convId.isEmpty) {
      if (kDebugMode) print('initSocket: conversation id empty');
    }

    // keep current conversation
    currentConversetion.value = conversation;
    conversationId.value = convId;
    conversatioId.value = convId;
    update();

    // create socket
    try {
      socket = _socketService.initSocket(
        baseUrl: ApiRoutes.socketBaseUrl,
        transports: ['websocket', 'polling'],
        autoConnect: false,
        reconnectionAttempts: 10,
        reconnectionDelayMs: 2000,
        timeoutMs: 1000000,
        path: '/socket.io',
        extraHeaders: {'Origin': ApiRoutes.baseUrl},
      );
    } catch (e) {
      if (kDebugMode) print('socket init error: $e');
      rethrow;
    }

    // Register listeners first
    socket.onConnect((_) {
      if (kDebugMode) print('socketConnected (chat)');
      final token =
          SharedPreferencesManager.instance?.getString(Utils.accessTokenKey) ??
          '';
      try {
        socket.emit('joinConversation', {
          'conversationId': convId,
          'authToken': token,
        });
      } catch (e) {
        if (kDebugMode) print('emit joinConversation error: $e');
      }
      try {
        if ((conversation.bookingId ?? '').isNotEmpty) {
          BookingRepository().acceptCall(conversation.bookingId!);
        }
      } catch (e) {
        if (kDebugMode) print('acceptCall error: $e');
      }
      resendPendingMessages();
      inChatNow.value = true;
      update();
      if (kDebugMode) print('ChatController: joined conversation $convId');
    });

    socket.onDisconnect((reason) {
      if (kDebugMode) print('socket disconnected: $reason');
      inChatNow.value = false;
      update();
    });

    socket.onReconnect((attempt) {
      if (kDebugMode) print('socket reconnect attempt: $attempt');
    });

    socket.onError((data) {
      if (kDebugMode) print('socket error: $data');
    });

    // detailed diagnostic hooks
    socket.on('connect_error', (data) {
      if (kDebugMode) print('connect_error: $data');
    });
    socket.on('connect_timeout', (data) {
      if (kDebugMode) print('connect_timeout: $data');
    });

    // init app listeners
    initListeners();

    // Connect
    try {
      socket.connect();
    } catch (e) {
      if (kDebugMode) print('socket.connect error: $e');
    }

    // navigate to chat screen only when requested (preserve old behavior)
    if (navigate == true && context != null) {
      try {
        inChatNow.value = true;
        Get.toNamed(AppRoutes.chatScreen)!.then((_) {
          inChatNow.value = false;
        });
      } catch (e) {
        if (kDebugMode) print('navigation to chat screen failed: $e');
      }
    }
  }

  void setRate(int value) {
    rate.value = value;
    update();
  }

  void initListeners() {
    // remove old handlers then attach
    try {
      socket.off('newMessage');
      socket.off('voiceMessage');
      socket.off('loadMessages');
      socket.off('chatFinished');
    } catch (_) {}

    socket.on('newMessage', handleNewMessage);
    socket.on('voiceMessage', handleVoiceMessage);
    socket.on('loadMessages', handleLoadMessages);
    socket.on('chatFinished', handleChatFinished);

    // debug: listen to any event (optional, heavy in production)
    try {
      socket.onAny((event, data) {
        if (kDebugMode) print('socket onAny -> $event : $data');
      });
    } catch (_) {}
  }

  void handleNewMessage(dynamic message) {
    if (kDebugMode) {
      print('handleNewMessage -> $message');
    }
    try {
      chatMessages.add(
        ChatMessageWidget(
          message: message['message'].toString(),
          conversationId:
              (message['conversation_id'] ??
                      message['conversationId'] ??
                      conversationId.value)
                  .toString(),
          senderId:
              (message['sender_id'] ?? message['senderId'] ?? '').toString(),
          isRead: (message['is_read'] == 1 || message['is_read'] == true),
          type: 'text',
        ),
      );

      pendingMessages.removeWhere(
        (element) =>
            element['messageId'] == (message['messageId'] ?? message['id']),
      );

      // scroll to bottom
      try {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } catch (_) {}
      update();
    } catch (e) {
      if (kDebugMode) print('handleNewMessage error: $e');
    }
  }

  void handleVoiceMessage(dynamic message) {
    if (kDebugMode) print('handleVoiceMessage -> $message');
    try {
      final media =
          (message['media'] is List && message['media'].isNotEmpty)
              ? message['media'][0]['original_url']
              : null;
      chatMessages.add(
        ChatMessageWidget(
          message: message['message'].toString(),
          conversationId:
              (message['conversation_id'] ??
                      message['conversationId'] ??
                      conversationId.value)
                  .toString(),
          senderId:
              (message['sender_id'] ?? message['senderId'] ?? '').toString(),
          isRead: false,
          type: 'voice',
          recordUrl: media?.toString(),
        ),
      );
      pendingMessages.removeWhere(
        (element) =>
            element['messageId'] == (message['messageId'] ?? message['id']),
      );
      try {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } catch (_) {}
      update();
    } catch (e) {
      if (kDebugMode) print('handleVoiceMessage error: $e');
    }
  }

  void handleLoadMessages(dynamic messages) async {
    if (kDebugMode) print("Received messages: $messages");
    try {
      chatMessages.clear();
      List<String> audioUrls = [];
      for (var message in messages) {
        if (message['type'] == 'audio' || message['type'] == 'voice') {
          String audioUrl = message['media'][0]['original_url'].toString();
          audioUrls.add(audioUrl);
          chatMessages.add(
            ChatMessageWidget(
              message: audioUrl,
              conversationId: message['conversation_id'].toString(),
              senderId: message['sender_id'].toString(),
              isRead: message['is_read'] == 1,
              type: 'voice',
              recordUrl: audioUrl,
            ),
          );
        } else {
          chatMessages.add(
            ChatMessageWidget(
              message: message['message'].toString(),
              conversationId: message['conversation_id'].toString(),
              senderId: message['sender_id'].toString(),
              isRead: message['is_read'] == 1,
              type: 'text',
            ),
          );
        }
      }

      try {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } catch (_) {}

      update();
      if (kDebugMode) print("Messages loaded");
    } catch (e) {
      if (kDebugMode) print('handleLoadMessages error: $e');
    }
  }

  void handleChatFinished(dynamic data) async {
    try {
      final bookingId = currentConversetion.value.bookingId;
      if (bookingId != null) BookingRepository().quitCall(bookingId);
    } catch (_) {}

    if (Get.find<DashboardController>().user.value.type == "user") {
      await Get.bottomSheet(
        GetBuilder<ChatController>(
          builder: (controller) {
            return RateWidget(
              onRatingChanged: (rating) {
                controller.setRate(rating);
              },
              rating: controller.rate.value,
              commentController: ratingController,
              onSubmit: () {
                controller.isRatingLoading.value = true;
                controller.update();
                CoachsRepository()
                    .rateCoach(
                      controller.rate.value,
                      controller.ratingController.text,
                      conversatioId.value,
                      isChat: true,
                    )
                    .then((response) {
                      if (response.statusCode == 200) {
                        MessagesManager.showSuccessMessage(
                          'Rated successfully'.tr,
                        );
                        Get.offAllNamed(AppRoutes.dashboardScreen);
                      } else {
                        MessagesManager.showErrorMessage('Failed to rate'.tr);
                      }
                      controller.isRatingLoading.value = false;
                      controller.update();
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
    }
    Get.find<DashboardController>().getConversations();
    Get.back();
    Get.dialog(
      AlertDialog(
        title: Text("Chat Finished".tr),
        content: Text("The chat has been finished".tr),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text("OK".tr),
          ),
        ],
      ),
    );
  }

  void sendMessage() async {
    if (isSending.isTrue || textController.text.isEmpty) {
      return;
    }
    isSending.value = true;
    update();

    String messageId = const Uuid().v4();
    String text = textController.text;
    String? senderId = Get.find<DashboardController>().user.value.id;

    // Ensure conversationId present
    final conv = conversationId.value;
    if (conv.isEmpty) {
      if (kDebugMode) print('sendMessage: conversationId is empty!');
    }

    final sendResponse = await ChatRepository().sendTextMessage(
      Message(
        id: messageId,
        conversationId: conv,
        senderId: senderId,
        message: text,
        isRead: false,
      ).toJson(),
    );

    if (sendResponse.statusCode != 200) {
      try {
        final body = jsonDecode(sendResponse.body);
        if (body['error'] == 'chatFinished') {
          try {
            socket.emit("chatFinished", {'conversationId': conv});
          } catch (_) {}
          handleChatFinished({});
          return;
        }
      } catch (_) {}
    }

    try {
      final body = jsonDecode(sendResponse.body);
      final messagePayload = body['message'] ?? body;
      socket.emit("sendMessage", {
        'message': messagePayload,
        'conversationId': conv,
        'messageId': messageId,
      });
    } catch (e) {
      if (kDebugMode) print('emit sendMessage error: $e');
    }

    textController.clear();

    Future.delayed(const Duration(seconds: 1), () {
      showRecording.value = true;
      isSending.value = false;
      update();
    });
  }

  void startRecording() async {
    if (await record.hasPermission()) {
      final dir = await getApplicationDocumentsDirectory();
      final path = "${dir.path}/${const Uuid().v4()}.wav";
      await record.start(
        path: path,

        const RecordConfig(
          encoder: AudioEncoder.wav,
          bitRate: 16000,
          sampleRate: 8000,
        ),
      );
      isRecording.value = true;
      update();
      audioTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        recordingDuration++;
        update();
      });

      // Limit the recording duration to 2 minutes (or 1 minute for users)
      User user = User.fromJson(
        jsonDecode(
          SharedPreferencesManager.instance!.getString(Utils.localUserKey) ??
              "",
        ),
      );
      recordingTimer = Timer(
        Duration(minutes: user.type == "user" ? 1 : 2),
        () async {
          await stopRecording();
          recordingDuration = 0;
          audioTimer.cancel();
        },
      );
    }
  }

  Future<void> stopRecording() async {
    try {
      recordingTimer.cancel();
    } catch (_) {}
    recordingDuration = 0;
    try {
      audioTimer.cancel();
    } catch (_) {}
    String? path = await record.stop();
    isRecording.value = false;
    update();

    await sendAudioThroughSocket(path ?? '');
  }

  Future<void> sendAudioThroughSocket(String filePath) async {
    isSending.value = true;
    update();
    final file = File(filePath);
    final fileBytes = await File(filePath).readAsBytes();
    final fileName = '${const Uuid().v4()}.wav';
    final conversationIdValue = conversationId.value;
    final senderId = Get.find<DashboardController>().user.value.id;
    final messageId = const Uuid().v4();
    if (kDebugMode) print("File size: ${fileBytes.lengthInBytes / 1024} KB");

    final sendResponse = await ChatRepository().sendAudioMessage(
      Message(
        id: messageId,
        conversationId: conversationIdValue,
        senderId: senderId,
        message: fileName,
        isRead: false,
      ).toJson(),
      file,
    );

    if (sendResponse.statusCode != 200) {
      try {
        final body = jsonDecode(sendResponse.body);
        if (body['error'] == 'chatFinished') {
          socket.emit("chatFinished", {'conversationId': conversationId.value});
          handleChatFinished({});
          return;
        }
      } catch (_) {}
    }

    try {
      final body = jsonDecode(sendResponse.body);
      final messagePayload = body['message'] ?? body;
      socket.emit("voiceMessage", {
        'message': messagePayload,
        'conversationId': conversationIdValue,
        'messageId': messageId,
      });
    } catch (e) {
      if (kDebugMode) print('emit voiceMessage error: $e');
    }

    isSending.value = false;
    update();
  }

  void setShowRecording(bool value) {
    showRecording.value = value;
    update();
  }

  void resendPendingMessages() {
    if (kDebugMode) print("Resending pending messages $pendingMessages");
    for (var message in pendingMessages) {
      try {
        socket.emit(
          message['type'] == 'text' ? 'sendMessage' : 'voiceMessage',
          message,
        );
      } catch (e) {
        if (kDebugMode) print('resend error: $e');
      }
    }
    // keep pendingMessages if you want retry later
  }

  @override
  void onClose() {
    try {
      socket.dispose();
    } catch (_) {}
    try {
      socket.disconnect();
    } catch (_) {}
    try {
      _socketService.dispose();
    } catch (_) {}
    super.onClose();
  }
}
