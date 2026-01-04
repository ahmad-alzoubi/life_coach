class Message {
  final String? id;
  final String? conversationId;
  final String? senderId;
  final String? message;
  final bool? isRead;

  Message({this.id, this.conversationId, this.senderId, this.message, this.isRead});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id']?.toString(),
      conversationId: json['conversation_id']?.toString(),
      senderId: json['sender_id']?.toString(),
      message: json['message'],
      isRead: json['is_read'] == 1,
    );
  }

  Map<String, String> toJson() {
    return {
      'id': id.toString(),
      'conversation_id': conversationId.toString(),
      'sender_id': senderId.toString(),
      'message': message.toString(),
      'is_read': isRead.toString(),
    };
  }
}
