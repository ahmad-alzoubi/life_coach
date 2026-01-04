class CoachAttributes {
  final String id;
  final String userId;
  final String videoPrice;
  final String audioPrice;
  final String chatPrice;
  final String halfVideoPrice;
  final String halfAudioPrice;
  final String halfChatPrice;
  final bool enableVideo;
  final bool enableAudio;
  final bool enableChat;

  CoachAttributes({
    required this.id,
    required this.userId,
    required this.videoPrice,
    required this.audioPrice,
    required this.chatPrice,
    required this.halfVideoPrice,
    required this.halfAudioPrice,
    required this.halfChatPrice,
    required this.enableVideo,
    required this.enableAudio,
    required this.enableChat,
  });

  factory CoachAttributes.fromJson(Map<String, dynamic> json) {
    return CoachAttributes(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      videoPrice: json['video_price'].toString(),
      audioPrice: json['audio_price'].toString(),
      chatPrice: json['chat_price'].toString(),
      enableVideo: json['enable_video'].toString() == '1' ? true : false,
      enableAudio: json['enable_audio'].toString() == '1' ? true : false,
      enableChat: json['enable_chat'].toString() == '1' ? true : false,
      halfVideoPrice: json['half_video_price'].toString(),
      halfAudioPrice: json['half_audio_price'].toString(),
      halfChatPrice: json['half_chat_price'].toString(),
    );
  }
}