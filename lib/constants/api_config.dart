class ApiConfig {
  static const String baseUrl = 'https://onlinepdks.com.tr/mobile/api/';

  // AUTH
  static const String login = 'login';
  static const String resetDevice = 'auth/reset-device';

  // PATRON
  static const String dashboardSummary = 'patron/dashboard-summary';
  static const String personnelList = 'patron/personnel-list';
  static const String departmentList = 'departments';
  static const String pendingLeaveRequests = 'patron/pending-leave-requests';
  static const String pendingAdvanceRequests = 'patron/pending-advance-requests';
  static const String approveRequest = 'patron/approve-request';
  static const String rejectRequest = 'patron/reject-request';
  static const String lateEarlyReport = 'patron/late-early-report';

  // PERSONEL
  static const String dailyReport = 'personel/daily-report';
  static const String weeklyReport = 'personel/weekly-report';
  static const String monthlyOvertime = 'personel/monthly-overtime';
  static const String leaveRequest = 'personel/submit-leave-request';
  static const String leaveHistory = 'personel/leave-history';
  static const String advanceRequest = 'personel/advance-request';
  static const String advanceHistory = 'personel/advance-history';
  static const String checkInOut = 'personel/check-in-out';
  static const String qrCheckInOut = 'personel/qr-check-in-out';
}
