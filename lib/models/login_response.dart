class LoginResponse {
  final bool success;
  final String? message;
  final String? token;
  final int personnelId;
  final String? personnelName;
  final bool isPatron;
  final String? department;

  LoginResponse({
    required this.success, this.message, this.token,
    this.personnelId = -1, this.personnelName,
    this.isPatron = false, this.department,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    success: json['success'] ?? false,
    message: json['message'],
    token: json['token'],
    personnelId: json['personnel_id'] ?? -1,
    personnelName: json['personnel_name'],
    isPatron: json['is_patron'] ?? false,
    department: json['department'],
  );
}
