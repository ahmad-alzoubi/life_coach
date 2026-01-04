class Schedule {
  final String? day;
  final String? date;
  final List<Slot>? slots;

  Schedule({this.day, this.date, this.slots});

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      day: json['day'],
      date: json['date'],
      slots: json['slots'] != null
          ? List<Slot>.from(json['slots'].map((x) => Slot.fromJson(x)))
          : null,
    );
  }

  static List<Schedule> fromJsonList(List<dynamic> jsonList) {
    List<Schedule> items = [];
    for (var element in jsonList) {
      items.add(Schedule.fromJson(element));
    }
    return items;
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'date': date,
      'slots': slots?.map((x) => x.toJson()).toList(),
    };
  }
}

class Slot {
  final String? time;
  final bool? booked;

  Slot({this.time, this.booked});

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      time: json['time'],
      booked: json['booked'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'booked': booked,
    };
  }
}
