class CheckInOutResponse {
  final bool success;
  final String? message, action, time;

  CheckInOutResponse({required this.success, this.message, this.action, this.time});

  factory CheckInOutResponse.fromJson(Map<String, dynamic> j) => CheckInOutResponse(
    success: j['success']??false, message: j['message'], action: j['action'], time: j['time'],
  );
}
