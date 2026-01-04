class ConversationParticipant {
  final String? id;
  final String? conversationId;
  final String? firstUserId;
  final String? secondUserId;

  ConversationParticipant({this.id, this.conversationId, this.firstUserId, this.secondUserId});

  factory ConversationParticipant.fromJson(Map<String, dynamic> json) {
    return ConversationParticipant(
      id: json['id']?.toString(),
      conversationId: json['conversation_id']?.toString(),
      firstUserId: json['first_user_id']?.toString(),
      secondUserId: json['second_user_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'first_user_id': firstUserId,
      'second_user_id': secondUserId,
    };
  }
}
