import '../constants/app_constants.dart';

class LeaveRequest {
  final String? id, personnelName, department, startDate, endDate, startTime, endTime, reason, status, requestDate;
  final String leaveType;
  final double remainingDays;

  LeaveRequest({this.id, this.personnelName, this.department, this.leaveType='',
    this.startDate, this.endDate, this.startTime, this.endTime, this.reason,
    this.status, this.requestDate, this.remainingDays=0});

  String get leaveTypeDisplay {
    switch (leaveType) {
      case LeaveType.annual: return 'Yillik Izin';
      case LeaveType.daily: return 'Gunluk Izin';
      case LeaveType.hourly: return 'Saatlik Izin';
      default: return leaveType;
    }
  }

  factory LeaveRequest.fromJson(Map<String, dynamic> j) => LeaveRequest(
    id: j['id']?.toString(), personnelName: j['personnel_name'], department: j['department'],
    leaveType: j['leave_type']??'', startDate: j['start_date'], endDate: j['end_date'],
    startTime: j['start_time'], endTime: j['end_time'], reason: j['reason'],
    status: j['status'], requestDate: j['request_date'], remainingDays: (j['remaining_days']??0).toDouble(),
  );
}
