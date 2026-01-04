class BookingRequest {
  final String? coachId;
  final String? date;
  final String? time;
  final int? duration;
  final String? amount;
  final String? connectionType;
  final String? paymentStatus;
  final String? paymentId;
  final String? paymentMethod;

  BookingRequest({
    this.coachId,
    this.date,
    this.time,
    this.duration,
    this.amount,
    this.connectionType,
    this.paymentStatus,
    this.paymentId,
    this.paymentMethod
  });

  Map<String, dynamic> toJson() {
    return {
      'coach_id': coachId,
      'date': date,
      'time': time,
      'duration': duration,
      'amount': amount,
      'connect_type': connectionType,
      'payment_status': paymentStatus,
      'payment_id': paymentId,
      'payment_method': paymentMethod
    };
  }
}