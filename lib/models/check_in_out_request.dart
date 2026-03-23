class CheckInOutRequest {
  final int personnelId;
  final double latitude, longitude;
  final String? qrCode;
  final String type, deviceId;

  CheckInOutRequest({required this.personnelId, required this.latitude, required this.longitude,
    this.qrCode, required this.type, required this.deviceId});

  Map<String, dynamic> toJson() => {
    'personnel_id': personnelId, 'latitude': latitude, 'longitude': longitude,
    'qr_code': qrCode, 'type': type, 'device_id': deviceId,
  };
}
