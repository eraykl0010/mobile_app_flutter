import '../constants/app_constants.dart';

class LateEarlyRecord {
  final String? personnelName, department, scheduledTime, actualTime, date;
  final String type;
  final int differenceMinutes;

  LateEarlyRecord({this.personnelName, this.department, this.type='',
    this.scheduledTime, this.actualTime, this.differenceMinutes=0, this.date});

  String get typeDisplay {
    switch (type) {
      case OvertimeType.overtime: return 'Fazla Mesai';
      case OvertimeType.undertime: return 'Eksik Mesai';
      case AttendanceStatus.late: return 'Gec Geldi';
      case AttendanceStatus.early: return 'Erken Cikti';
      default: return type;
    }
  }

  factory LateEarlyRecord.fromJson(Map<String, dynamic> j) => LateEarlyRecord(
    personnelName: j['personnel_name'], department: j['department'], type: j['type']??'',
    scheduledTime: j['scheduled_time'], actualTime: j['actual_time'],
    differenceMinutes: j['difference_minutes']??0, date: j['date'],
  );
}
