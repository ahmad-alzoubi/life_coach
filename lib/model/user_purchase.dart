class UserPurchase {
  final int id;
  final int userId;
  final int courseId;

  UserPurchase({
    required this.id,
    required this.userId,
    required this.courseId,
  });

  factory UserPurchase.fromJson(Map<String, dynamic> json) {
    return UserPurchase(
      id: json['id'],
      userId: json['user_id'],
      courseId: json['course_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
    };
  }
}
