import 'package:coach_life/model/user.dart';

class CoachRate {
  final String? userId;
  final String? coachId;
  final String? rate;
  final String? comment;
  final User? user;

  CoachRate({this.userId, this.coachId, this.rate, this.comment, this.user});

  factory CoachRate.fromJson(Map<String, dynamic> json) {
    return CoachRate(
      userId: json['user_id']?.toString(),
      coachId: json['coach_id']?.toString(),
      rate: json['rate']?.toString(),
      comment: json['review']?.toString(),
      user: User.fromJson(json['user'])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'coach_id': coachId,
      'rate': rate,
      'review': comment,
    };
  }
}
