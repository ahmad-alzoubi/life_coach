import 'package:coach_life/model/booking.dart';
import 'package:coach_life/model/coach_attributes.dart';
import 'package:coach_life/model/schedule.dart';

import 'coach_rate.dart';
import 'media.dart';

class Coach {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? type;
  final String? bio;
  final List<Schedule>? schedules;
  final double? rating;
  final int? totalBookings;
  final List<CoachRate>? coachRates;
  final List<Booking>? coachBookings;
  final List<Media>? media;
  final String? price;
  final CoachAttributes? coachAttributes;


  Coach({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.type,
    this.bio,
    this.schedules,
    this.rating,
    this.totalBookings,
    this.coachRates,
    this.coachBookings,
    this.media,
    this.price,
    this.coachAttributes
  });

  factory Coach.fromJson(Map<String, dynamic> json) {
    return Coach(
      id: json['id']?.toString(),
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      type: json['type'],
      bio: json['bio'],
      schedules: json['schedules'] != null
          ? List<Schedule>.from(json['schedules'].map((x) => Schedule.fromJson(x)))
          : null,
      rating: json['rating'] != null ? double.parse(json['rating'].toString()) : null,
      totalBookings: json['total_bookings'],
      coachRates: json['coach_rates'] != null
          ? List<CoachRate>.from(json['coach_rates'].map((x) => CoachRate.fromJson(x)))
          : null,
      coachBookings: json['coach_bookings'] != null
          ? List<Booking>.from(json['coach_bookings'].map((x) => Booking.fromJson(x)))
          : null,
      media: json['media'] != null
          ? List<Media>.from(json['media'].map((x) => Media.fromJson(x)))
          : null,
      price: json['price']?.toString(),
      coachAttributes: json['coach_attributes'] != null ? CoachAttributes.fromJson(json['coach_attributes']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'type': type,
      'schedules': schedules?.map((x) => x.toJson()).toList(),
      'rating': rating,
      'total_bookings': totalBookings,
      'coach_rates': coachRates?.map((x) => x.toJson()).toList(),
      'coach_bookings': coachBookings?.map((x) => x.toJson()).toList(),
      'media': media,
      'price': price
    };
  }
}
