import 'package:coach_life/model/coach.dart';
import 'package:coach_life/model/conversation.dart';
import 'package:coach_life/model/user.dart';

class Booking {
  final String? id;
  final Conversation? conversation;
  final String? userId;
  final String? coachId;
  final String? date;
  final String? time;
  final String? status;
  final String? paymentStatus;
  final String? paymentId;
  final String? paymentMethod;
  final String? amount;
  final String? currency;
  final String? connectType;
  final String? connectId;
  final String? connectPassword;
  final String? connectUrl;
  final String? connectExpiresAt;
  final String? connectStatus;
  final String? connectError;
  final String? connectErrorDescription;
  final String? connectErrorCode;
  final String? duration;
  final Coach? coach;
  final User? user;

  Booking({
    this.id,
    this.userId,
    this.coachId,
    this.date,
    this.time,
    this.conversation,
    this.status,
    this.paymentStatus,
    this.paymentId,
    this.paymentMethod,
    this.amount,
    this.currency,
    this.connectType,
    this.connectId,
    this.connectPassword,
    this.connectUrl,
    this.connectExpiresAt,
    this.connectStatus,
    this.connectError,
    this.connectErrorDescription,
    this.connectErrorCode,
    this.duration,
    this.coach,
    this.user,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      coachId: json['coach_id']?.toString(),
      date: json['date']?.toString(),
      time: json['time']?.toString(),
      status: json['status']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      paymentId: json['payment_id']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      amount: json['amount']?.toString(),
      currency: json['currency']?.toString(),
      connectType: json['connect_type']?.toString(),
      connectId: json['connect_id']?.toString(),
      connectPassword: json['connect_password']?.toString(),
      connectUrl: json['connect_url']?.toString(),
      connectExpiresAt: json['connect_expires_at']?.toString(),
      connectStatus: json['connect_status']?.toString(),
      connectError: json['connect_error']?.toString(),
      connectErrorDescription: json['connect_error_description']?.toString(),
      connectErrorCode: json['connect_error_code']?.toString(),
      coach: json['coach'] != null ? Coach.fromJson(json['coach']) : null,
      duration: json['duration']?.toString(),
      conversation:
          json['conversation'] != null
              ? Conversation.fromJson(json['conversation'])
              : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  static List<Booking> listFromJson(List<dynamic> json) {
    List<Booking> bookings = [];
    for (var booking in json) {
      bookings.add(Booking.fromJson(booking));
    }
    return bookings;
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'coach_id': coachId,
      'date': date,
      'time': time,
      'status': status,
      'payment_status': paymentStatus,
      'payment_id': paymentId,
      'payment_method': paymentMethod,
      'amount': amount,
      'currency': currency,
      'connect_type': connectType,
      'connect_id': connectId,
      'connect_password': connectPassword,
      'connect_url': connectUrl,
      'connect_expires_at': connectExpiresAt,
      'connect_status': connectStatus,
      'connect_error': connectError,
      'connect_error_description': connectErrorDescription,
      'connect_error_code': connectErrorCode,
      'duration': duration,
      'conversation': conversation,
    };
  }
}
