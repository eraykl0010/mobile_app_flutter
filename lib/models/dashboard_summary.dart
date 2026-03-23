class DashboardSummary {
  final int activeCount, totalCount, onLeaveCount, absentCount, lateCount, earlyLeaveCount;
  final String? departmentName;

  DashboardSummary({this.activeCount=0, this.totalCount=0, this.onLeaveCount=0, this.absentCount=0, this.lateCount=0, this.earlyLeaveCount=0, this.departmentName});

  factory DashboardSummary.fromJson(Map<String, dynamic> j) => DashboardSummary(
    activeCount: j['active_count']??0, totalCount: j['total_count']??0,
    onLeaveCount: j['on_leave_count']??0, absentCount: j['absent_count']??0,
    lateCount: j['late_count']??0, earlyLeaveCount: j['early_leave_count']??0,
    departmentName: j['department_name'],
  );
}
