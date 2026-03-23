class MonthlyOvertime {
  final String? month;
  final double totalWorkHours, totalOvertimeHours;
  final int totalWorkDays, absentDays, lateCount, earlyLeaveCount;

  MonthlyOvertime({this.month, this.totalWorkHours=0, this.totalOvertimeHours=0,
    this.totalWorkDays=0, this.absentDays=0, this.lateCount=0, this.earlyLeaveCount=0});

  factory MonthlyOvertime.fromJson(Map<String, dynamic> j) => MonthlyOvertime(
    month: j['month'], totalWorkHours: (j['total_work_hours']??0).toDouble(),
    totalOvertimeHours: (j['total_overtime_hours']??0).toDouble(),
    totalWorkDays: j['total_work_days']??0, absentDays: j['absent_days']??0,
    lateCount: j['late_count']??0, earlyLeaveCount: j['early_leave_count']??0,
  );
}
