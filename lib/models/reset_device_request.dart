class ResetDeviceRequest {
  final int personnelId, resetBy;
  ResetDeviceRequest({required this.personnelId, required this.resetBy});
  Map<String, dynamic> toJson() => {'personnel_id': personnelId, 'reset_by': resetBy};
}
