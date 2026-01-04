import 'package:coach_life/model/coach_schedules.dart';

class WeeklySchedule {
  String name;
  List<CoachSchedules> schedules;

  WeeklySchedule({
    required this.name,
    required this.schedules,
  });

  factory WeeklySchedule.fromJson(Map<String, dynamic> json) {
    return WeeklySchedule(
      name: json["name"],
      schedules: List<CoachSchedules>.from(json["schedules"].map((x) => CoachSchedules.fromJson(x))),
    );
  }

  static List<WeeklySchedule> fromJsonList(List<dynamic> jsonList) {
    List<WeeklySchedule> list = [];
    for (var element in jsonList) {
      list.add(WeeklySchedule.fromJson(element));
    }
    return list;
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "schedules": List<dynamic>.from(schedules.map((x) => x.toJson())),
  };
}