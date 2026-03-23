class LeaveType {
  static const String annual = 'yillik';
  static const String daily = 'gunluk';
  static const String hourly = 'saatlik';
  static const String advance = 'avans';
  static const List<String> values = [annual, daily, hourly];
  static const List<String> labels = ['Yıllık İzin', 'Günlük İzin', 'Saatlik İzin'];
}

class RequestStatus {
  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String rejected = 'rejected';
}

class ApprovalAction {
  static const String approve = 'approve';
  static const String reject = 'reject';
}

class AttendanceStatus {
  static const String normal = 'normal';
  static const String late = 'late';
  static const String early = 'early';
  static const String absent = 'absent';
  static const String leave = 'leave';

  static String display(String status) {
    switch (status) {
      case normal: return 'Normal';
      case late: return 'Geç';
      case early: return 'Erken Çıkış';
      case absent: return 'Devamsız';
      case leave: return 'İzinli';
      default: return status;
    }
  }
}

class PersonnelStatus {
  static const String active = 'active';
  static const String late = 'late';
  static const String early = 'early';
  static const String onLeave = 'on_leave';
  static const String absent = 'absent';
  static const String noRecord = 'no_record';

  static String display(String status) {
    switch (status) {
      case active: return 'Aktif';
      case onLeave: return 'İzinli';
      case absent: return 'Devamsız';
      case late: return 'Geç';
      case early: return 'Erken Çıkış';
      default: return status;
    }
  }
}

class OvertimeType {
  static const String overtime = 'overtime';
  static const String undertime = 'undertime';
}

class CheckInType {
  static const String location = 'location';
  static const String qrScan = 'qr_scan';
}

class RequestType {
  static const String leave = 'leave';
  static const String advance = 'advance';
}

class ModuleType {
  static const String patron = 'patron';
  static const String personel = 'personel';
}
