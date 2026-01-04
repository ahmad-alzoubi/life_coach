class CoachSchedules {
  String? id;
  final String? coachId;
  final String? startTime;
  final String? endTime;
  final String? day;
  final String? status;

  CoachSchedules({this.coachId, this.startTime, this.endTime, this.day, this.status, this.id});

  factory CoachSchedules.fromJson(Map<String, dynamic> json) {
    return CoachSchedules(
      id: json['id']?.toString(),
      coachId: json['coach_id']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      day: json['day']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coach_id': coachId,
      'start_time': startTime,
      'end_time': endTime,
      'day': day,
      'status': status,
    };
  }
}
