import 'package:coach_life/model/user.dart';

import 'message.dart';

class Conversation {
  final String? id;
  final String? name;
  final String? bookingId;
  final List<Message>? messages;
  final User? user;
  final User? coach;

  Conversation({
    this.id,
    this.name,
    this.bookingId,
    this.messages,
    this.user,
    this.coach,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id']?.toString(),
      name: json['name'],
      bookingId: json['booking_id'].toString(),
      messages:
          json['messages'] != null
              ? List<Message>.from(
                json['messages'].map((x) => Message.fromJson(x)),
              )
              : null,
      user:
          json['participants']?['first_user'] != null
              ? User.fromJson(json['participants']['first_user'])
              : null,
      coach:
          json['participants']?['second_user'] != null
              ? User.fromJson(json['participants']['second_user'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'booking_id': bookingId,
      'messages': messages?.map((x) => x.toJson()).toList(),
      'user': user?.toJson(),
      'coach': coach?.toJson(),
    };
  }
}
