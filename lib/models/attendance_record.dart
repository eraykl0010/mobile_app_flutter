import '../constants/app_constants.dart';

class AttendanceRecord {
  final String? date, dayName, checkIn, checkOut, workHours, overtimeHours;
  final String status;

  AttendanceRecord({this.date, this.dayName, this.checkIn, this.checkOut, this.workHours, this.overtimeHours, this.status=''});

  String get statusDisplay => AttendanceStatus.display(status);

  factory AttendanceRecord.fromJson(Map<String, dynamic> j) => AttendanceRecord(
    date: j['date'], dayName: j['day_name'], checkIn: j['check_in'], checkOut: j['check_out'],
    workHours: j['work_hours'], overtimeHours: j['overtime_hours'], status: j['status']??'',
  );
}
