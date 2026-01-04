class ApiRoutes {
  static const String baseUrl = "https://app.lifecoach.com.sa";
  // Socket base URL; prefer wss if available. Fallback to ws/http host if needed.
  static const String socketBaseUrl = "http://92.112.192.208:3000";

  static const String login = "api/login";
  static const String register = "api/register";
  static const String deleteAccount = "api/delete-account";

  static const String getAllCoachs = "api/coaches";

  ///Get Method
  static String rateCoach(String coachId) => "api/rate-coach/$coachId";

  /// Post Method
  static const String getSchedules = "api/coach/schedules";

  ///Get Method
  static const String createSchedule = "api/coach/schedules";

  ///Post Method
  static const String updateSchedule = "api/coach/schedules";

  ///Post Method
  static String deleteSchedule(String id) => "api/coach/schedules/$id";

  ///Delete Method
  static String getCoachSchedules(String id) => "api/coach/schedules/$id";

  ///Get Method
  static const String getWallet = "api/wallet";

  ///Get Method
  static const String getProfile = "api/profile";

  ///Get Method

  static const String getBookings = "api/bookings";

  ///Get Method
  static const String payWithWallet = "api/pay-with-wallet";

  ///Post Method
  static const String createBooking = "api/bookings";

  ///Post Method
  static const String checkBookingTime = "api/check-booking-time";

  ///Post Method
  static const String getConversations = "api/conversations";

  ///Get Method
  static const String checkBookingWillStart = "api/check-current-booking";

  ///Get Method
  static const String acceptCall = "api/accept-call";

  ///POST Method
  static const String quitCall = "api/quit-call";
  static String checkBookingStatus(String id) => "api/check-booking-status/$id";

  ///Get Method
  static const String sendTextMessage = "api/text-messages";

  ///Post Method
  static const String sendAudioMessage = "api/audio-messages";

  ///Post Method

  static const String updateProfile = "api/update-profile";

  static const String getNotifications = "api/notifications";

  ///Get Method

  static const String getConfig = "api/config";

  ///Get Method

  static const String getCoachAttributes = "api/getCoachAttributes";

  ///Get Method

  static const String getCourses = "api/courses";

  ///Get Method
  static String getCourseDetails(String id) => "api/courses/$id";

  ///Get Method
  static const String buyCourses = "api/buy-courses";

  ///Post Method

  static const String userLeftCall = "api/user-left-call";

  ///Post Method

  static String getBookingRemainingTime(String id) =>
      "api/booking-remaining-time/$id";

  ///Get Method
  static String getNewToken(String id) => "api/get-new-token/$id";

  ///Get Method

  /// In-call helpers
  static const String sendInCallNotification =
      "api/send-in-call-notification"; // POST { booking_id, role }
  static const String sendInCallMessage =
      "api/send-in-call-message"; // POST { booking_id, message }
  static const String uploadInCallFile =
      "api/upload-in-call-file"; // POST { booking_id, filename, file(Base64) }
  static const String openSupportTicket =
      "api/open-support-ticket"; // POST { booking_id, message }
  static const String refundBooking =
      "api/refund-booking"; // POST { booking_id, amount }
}
