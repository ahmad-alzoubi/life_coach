class AppNotification {
  final String? userId;
  final String? title;
  final String? message;
  final String? type;
  final String? status;

  AppNotification({this.userId, this.title, this.message, this.type, this.status});

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      userId: json['user_id']?.toString(),
      title: json['title'],
      message: json['message'],
      type: json['type'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'status': status,
    };
  }
}
