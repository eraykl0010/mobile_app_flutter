class LeaveSubmitRequest {
  final int personnelId;
  final String leaveType, startDate, endDate, reason;
  final String? startTime, endTime;

  LeaveSubmitRequest({required this.personnelId, required this.leaveType,
    required this.startDate, required this.endDate, this.startTime, this.endTime, required this.reason});

  Map<String, dynamic> toJson() => {
    'personnel_id': personnelId, 'leave_type': leaveType,
    'start_date': startDate, 'end_date': endDate,
    'start_time': startTime, 'end_time': endTime, 'reason': reason,
  };
}
