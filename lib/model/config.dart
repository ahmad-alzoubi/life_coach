import 'package:coach_life/model/booking.dart';

class Config {
  String? currentDayBookingsCount;
  String? currentMonthProfit;
  String? currentDayProfit;
  String? averageRating;
  List<Booking>? currentDayBookings;
  List<String>? blockUsersPhone;
  String? paymentGatewayProfileId;
  String? paymentGatewayUrl;
  String? paymentGatewayKey;
  bool? tabbyEnabled;

  Config({
    this.currentDayBookingsCount,
    this.currentMonthProfit,
    this.currentDayProfit,
    this.averageRating,
    this.currentDayBookings,
    this.blockUsersPhone,
    this.paymentGatewayProfileId,
    this.paymentGatewayUrl,
    this.paymentGatewayKey,
    this.tabbyEnabled,
  });

  Config.fromJson(Map<String, dynamic> json) {
    currentDayBookingsCount = json['current_day_bookings_count'].toString();
    currentMonthProfit = json['current_month_profit'].toString();
    currentDayProfit = json['current_day_profit'].toString();
    averageRating = json['average_rating'].toString();
    if (json['current_day_bookings'] != null) {
      currentDayBookings = <Booking>[];
      json['current_day_bookings'].forEach((v) {
        currentDayBookings!.add(Booking.fromJson(v));
      });
      currentDayBookings!.sort((a, b) {
        final aDate = _resolveBookingDateTime(a);
        final bDate = _resolveBookingDateTime(b);
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });
    }
    if (json['blockUsersPhone'] != null) {
      blockUsersPhone = <String>[];
      json['blockUsersPhone'].forEach((v) {
        blockUsersPhone!.add(v.toString());
      });
    }
    paymentGatewayProfileId = json['paymentGatewayProfileId'].toString();
    paymentGatewayUrl = json['paymentGatewayUrl'].toString();
    paymentGatewayKey = json['paymentGatewayKey'].toString();
    tabbyEnabled = json['tabbyEnabled'].toString() == "1";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['current_day_bookings_count'] = currentDayBookingsCount;
    data['current_month_profit'] = currentMonthProfit;
    data['current_day_profit'] = currentDayProfit;
    data['average_rating'] = averageRating;
    if (currentDayBookings != null) {
      data['current_day_bookings'] =
          currentDayBookings!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

DateTime? _resolveBookingDateTime(Booking booking) {
  final datePart = booking.date?.trim();
  if (datePart == null || datePart.isEmpty) return null;
  final timePart = (booking.time ?? '').trim();
  DateTime? parsed;
  if (timePart.isNotEmpty) {
    parsed = DateTime.tryParse('$datePart $timePart');
    parsed ??= DateTime.tryParse('${datePart}T$timePart');
  } else {
    parsed = DateTime.tryParse(datePart);
  }
  return parsed?.toLocal();
}
