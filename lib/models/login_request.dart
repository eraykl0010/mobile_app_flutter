class LoginRequest {
  final String companyCode;
  final String cardNo;
  final String deviceId;
  final String deviceModel;
  final String moduleType;
  final String macAddress;

  LoginRequest({
    required this.companyCode,
    required this.cardNo,
    required this.deviceId,
    required this.deviceModel,
    required this.moduleType,
    required this.macAddress,
  });

  Map<String, dynamic> toJson() => {
    'company_code': companyCode,
    'card_no': cardNo,
    'device_id': deviceId,
    'device_model': deviceModel,
    'module_type': moduleType,
    'mac_address': macAddress,
  };
}
