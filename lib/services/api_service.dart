import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../constants/api_config.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/api_response.dart';
import '../models/dashboard_summary.dart';
import '../models/department.dart';
import '../models/personnel_info.dart';
import '../models/attendance_record.dart';
import '../models/leave_request.dart';
import '../models/leave_submit_request.dart';
import '../models/advance_request.dart';
import '../models/advance_submit_request.dart';
import '../models/approval_request.dart';
import '../models/check_in_out_request.dart';
import '../models/check_in_out_response.dart';
import '../models/late_early_record.dart';
import '../models/monthly_overtime.dart';
import '../models/reset_device_request.dart';
import 'session_manager.dart';

class ApiService {
  late Dio _dio;
  final SessionManager _session;

  ApiService(this._session) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _session.token;
        if (token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        final company = _session.companyCode;
        if (company.isNotEmpty) {
          options.headers['X-Company-Code'] = company;
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Oturum süresi dolmuş — ana ekrana yönlendir
          debugPrint('401 Unauthorized — session expired');
        }
        return handler.next(error);
      },
    ));
  }

  // ══════════ AUTH ══════════

  Future<LoginResponse> login(LoginRequest request) async {
    final resp = await _dio.post(ApiConfig.login, data: request.toJson());
    return LoginResponse.fromJson(resp.data);
  }

  Future<ApiResponse> resetDevice(ResetDeviceRequest request) async {
    final resp = await _dio.post(ApiConfig.resetDevice, data: request.toJson());
    return ApiResponse.fromJson(resp.data);
  }

  // ══════════ PATRON ══════════

  Future<DashboardSummary> getDashboardSummary({int? departmentId}) async {
    final resp = await _dio.get(ApiConfig.dashboardSummary,
        queryParameters: departmentId != null ? {'department_id': departmentId} : null);
    return DashboardSummary.fromJson(resp.data);
  }

  Future<List<PersonnelInfo>> getPersonnelList({int? departmentId}) async {
    final resp = await _dio.get(ApiConfig.personnelList,
        queryParameters: departmentId != null ? {'department_id': departmentId} : null);
    return (resp.data as List).map((e) => PersonnelInfo.fromJson(e)).toList();
  }

  Future<List<Department>> getDepartments() async {
    final resp = await _dio.get(ApiConfig.departmentList);
    return (resp.data as List).map((e) => Department.fromJson(e)).toList();
  }

  Future<List<LeaveRequest>> getPendingLeaveRequests({String? type, String? status}) async {
    final resp = await _dio.get(ApiConfig.pendingLeaveRequests,
        queryParameters: {'type': type, 'status': status});
    return (resp.data as List).map((e) => LeaveRequest.fromJson(e)).toList();
  }

  Future<List<AdvanceRequest>> getPendingAdvanceRequests({String? status}) async {
    final resp = await _dio.get(ApiConfig.pendingAdvanceRequests,
        queryParameters: {'status': status});
    return (resp.data as List).map((e) => AdvanceRequest.fromJson(e)).toList();
  }

  Future<ApiResponse> approveRequest(ApprovalRequest request) async {
    final resp = await _dio.post(ApiConfig.approveRequest, data: request.toJson());
    return ApiResponse.fromJson(resp.data);
  }

  Future<ApiResponse> rejectRequest(ApprovalRequest request) async {
    final resp = await _dio.post(ApiConfig.rejectRequest, data: request.toJson());
    return ApiResponse.fromJson(resp.data);
  }

  Future<List<LateEarlyRecord>> getLateEarlyReport({String? date}) async {
    final resp = await _dio.get(ApiConfig.lateEarlyReport,
        queryParameters: date != null ? {'date': date} : null);
    return (resp.data as List).map((e) => LateEarlyRecord.fromJson(e)).toList();
  }

  // ══════════ PERSONEL ══════════

  Future<List<AttendanceRecord>> getDailyReport(int personnelId) async {
    final resp = await _dio.get(ApiConfig.dailyReport,
        queryParameters: {'personnel_id': personnelId});
    return (resp.data as List).map((e) => AttendanceRecord.fromJson(e)).toList();
  }

  Future<List<AttendanceRecord>> getWeeklyReport(int personnelId) async {
    final resp = await _dio.get(ApiConfig.weeklyReport,
        queryParameters: {'personnel_id': personnelId});
    return (resp.data as List).map((e) => AttendanceRecord.fromJson(e)).toList();
  }

  Future<MonthlyOvertime> getMonthlyOvertime(int personnelId, String month) async {
    final resp = await _dio.get(ApiConfig.monthlyOvertime,
        queryParameters: {'personnel_id': personnelId, 'month': month});
    return MonthlyOvertime.fromJson(resp.data);
  }

  Future<ApiResponse> submitLeaveRequest(LeaveSubmitRequest request) async {
    final resp = await _dio.post(ApiConfig.leaveRequest, data: request.toJson());
    return ApiResponse.fromJson(resp.data);
  }

  Future<List<LeaveRequest>> getLeaveHistory(int personnelId) async {
    final resp = await _dio.get(ApiConfig.leaveHistory,
        queryParameters: {'personnel_id': personnelId});
    return (resp.data as List).map((e) => LeaveRequest.fromJson(e)).toList();
  }

  Future<ApiResponse> submitAdvanceRequest(AdvanceSubmitRequest request) async {
    final resp = await _dio.post(ApiConfig.advanceRequest, data: request.toJson());
    return ApiResponse.fromJson(resp.data);
  }

  Future<List<AdvanceRequest>> getAdvanceHistory(int personnelId) async {
    final resp = await _dio.get(ApiConfig.advanceHistory,
        queryParameters: {'personnel_id': personnelId});
    return (resp.data as List).map((e) => AdvanceRequest.fromJson(e)).toList();
  }

  Future<CheckInOutResponse> checkInOut(CheckInOutRequest request) async {
    final resp = await _dio.post(ApiConfig.checkInOut, data: request.toJson());
    return CheckInOutResponse.fromJson(resp.data);
  }

  Future<CheckInOutResponse> qrCheckInOut(CheckInOutRequest request) async {
    final resp = await _dio.post(ApiConfig.qrCheckInOut, data: request.toJson());
    return CheckInOutResponse.fromJson(resp.data);
  }
}
