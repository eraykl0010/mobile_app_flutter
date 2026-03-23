class ApiResponse {
  final bool success;
  final String? message;

  ApiResponse({required this.success, this.message});

  factory ApiResponse.fromJson(Map<String, dynamic> json) => ApiResponse(
    success: json['success'] ?? false,
    message: json['message'],
  );
}
