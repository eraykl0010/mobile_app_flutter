import 'package:flutter/material.dart';
import '../../main.dart';
import '../../constants/app_theme.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_constants.dart';
import '../../models/dashboard_summary.dart';
import '../../models/department.dart';
import '../../widgets/common_widgets.dart';
import '../module_selection_screen.dart';
import 'approval_list_screen.dart';
import 'personnel_detail_screen.dart';
import 'late_early_list_screen.dart';

/// activity_patron_dashboard.xml birebir karşılığı
class PatronDashboardScreen extends StatefulWidget {
  const PatronDashboardScreen({super.key});
  @override
  State<PatronDashboardScreen> createState() => _PatronDashboardScreenState();
}

class _PatronDashboardScreenState extends State<PatronDashboardScreen> {
  DashboardSummary _summary = DashboardSummary();
  List<Department> _depts = [];
  int? _selectedDeptId;
  int _annualC = 0, _dailyC = 0, _hourlyC = 0, _advanceC = 0;
  int _overtimeC = 0, _undertimeC = 0;
  bool _puantajLoading = false;

  @override
  void initState() { super.initState(); _loadAll(); }
  @override
  void didChangeDependencies() { super.didChangeDependencies(); }

  Future<void> _loadAll() async {
    await Future.wait([_loadDepts(), _loadSummary(), _loadOvertime(), _loadApprovals()]);
    if (mounted) setState(() {});
  }

  Future<void> _loadDepts() async { try { _depts = await apiService.getDepartments(); } catch (_) {} }

  Future<void> _calculatePuantaj() async {
    setState(() => _puantajLoading = true);
    try {
      final now = DateTime.now();
      final resp = await apiService.calculateDailyAttendance(startDate: now, endDate: now);
      if (!mounted) return;
      if (resp.success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(resp.message ?? AppStrings.puantajSuccess),
          backgroundColor: AppColors.statusSuccess,
        ));
        await _loadAll();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(resp.message ?? AppStrings.puantajFailed),
          backgroundColor: AppColors.statusDanger,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${AppStrings.puantajFailed}. Lütfen internet bağlantınızı kontrol edip tekrar deneyin.'),
          backgroundColor: AppColors.statusDanger,
        ));
      }
    } finally {
      if (mounted) setState(() => _puantajLoading = false);
    }
  }
  Future<void> _loadSummary() async { try { _summary = await apiService.getDashboardSummary(departmentId: _selectedDeptId); } catch (_) {} }
  Future<void> _loadOvertime() async {
    try {
      final d = await apiService.getLateEarlyReport();
      _overtimeC = d.where((r) => r.type == OvertimeType.overtime).length;
      _undertimeC = d.where((r) => r.type == OvertimeType.undertime).length;
    } catch (_) {}
  }
  Future<void> _loadApprovals() async {
    try {
      final r = await Future.wait([
        apiService.getPendingLeaveRequests(type: LeaveType.annual, status: RequestStatus.pending),
        apiService.getPendingLeaveRequests(type: LeaveType.daily, status: RequestStatus.pending),
        apiService.getPendingLeaveRequests(type: LeaveType.hourly, status: RequestStatus.pending),
        apiService.getPendingAdvanceRequests(status: RequestStatus.pending),
      ]);
      _annualC = r[0].length; _dailyC = r[1].length; _hourlyC = r[2].length; _advanceC = (r[3] as List).length;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        // Toolbar
        Container(
          color: AppColors.primary,
          child: SafeArea(bottom: false, child: SizedBox(
            height: AppDimens.toolbarHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingMd),
              child: Row(children: [
                const Expanded(child: Text('Patron Paneli', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white))),
                _puantajLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                    : GestureDetector(
                        onTap: _calculatePuantaj,
                        child: const Tooltip(message: AppStrings.puantajTitle, child: Icon(Icons.refresh, color: AppColors.white)),
                      ),
                const SizedBox(width: AppDimens.spacingMd),
                GestureDetector(onTap: _confirmLogout, child: const Icon(Icons.close, color: AppColors.white)),
              ]),
            ),
          )),
        ),

        // Hoşgeldin
        Padding(
          padding: const EdgeInsets.all(AppDimens.spacingMd),
          child: Align(alignment: Alignment.centerLeft, child: Text(
            AppStrings.welcome(sessionManager.personnelName),
            style: const TextStyle(fontSize: AppDimens.textSubtitle, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          )),
        ),

        // İçerik — pull to refresh
        Expanded(child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadAll,
          child: ListView(padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingMd), children: [
            // ═══ KART 1: Personel Bilgi Kartı ═══
            _buildPersonnelInfoCard(),
            const SizedBox(height: AppDimens.spacingSm),

            // ═══ KART 2: Onay Bekleyenler ═══
            _buildApprovalsCard(),
            const SizedBox(height: AppDimens.spacingSm),

            // ═══ KART 3: Fazla/Eksik Mesai ═══
            _buildOvertimeCard(),
            const SizedBox(height: AppDimens.spacingLg),
          ]),
        )),
      ]),
    );
  }

  Widget _buildPersonnelInfoCard() {
    return PdksCard(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonnelDetailScreen())),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Başlık satırı
        Row(children: [
          Container(width: 4, height: 24, color: AppColors.primary),
          const SizedBox(width: AppDimens.spacingSm),
          const Expanded(child: Text('Personel Bilgi Kartı', style: TextStyle(fontSize: AppDimens.textSubtitle, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
          const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
        ]),
        const SizedBox(height: AppDimens.spacingSm),

        // 3x2 Özet grid
        GridView.count(
          crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.3,
          children: [
            SummaryBox(label: 'Mevcut', value: '${_summary.totalCount}', valueColor: AppColors.statusInfo),
            SummaryBox(label: 'Aktif', value: '${_summary.activeCount}', valueColor: AppColors.statusSuccess),
            SummaryBox(label: 'İzinli', value: '${_summary.onLeaveCount}', valueColor: AppColors.accent),
            SummaryBox(label: 'Devamsız', value: '${_summary.absentCount}', valueColor: AppColors.statusDanger),
            SummaryBox(label: 'Geç Gelen', value: '${_summary.lateCount}', valueColor: AppColors.statusWarning),
            SummaryBox(label: 'Erken Çıkan', value: '${_summary.earlyLeaveCount}', valueColor: AppColors.statusEarly),
          ],
        ),
        const SizedBox(height: AppDimens.spacingSm),

        // Departman spinner
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingSm),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
            border: Border.all(color: AppColors.divider),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              isExpanded: true, value: _selectedDeptId,
              hint: const Text(AppStrings.allDepartments, style: TextStyle(fontSize: AppDimens.textBody)),
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text(AppStrings.allDepartments)),
                ..._depts.map((d) => DropdownMenuItem<int?>(value: d.id, child: Text(d.name))),
              ],
              onChanged: (v) { _selectedDeptId = v; _loadSummary().then((_) => setState(() {})); },
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildApprovalsCard() {
    return PdksCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 4, height: 24, color: AppColors.accent),
          const SizedBox(width: AppDimens.spacingSm),
          const Expanded(child: Text('Onay Bekleyenler', style: TextStyle(fontSize: AppDimens.textSubtitle, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
        ]),
        const SizedBox(height: AppDimens.spacingSm),
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.8,
          children: [
            _ApprovalMiniCard(label: 'Yıllık İzin', count: _annualC, onTap: () => _openApproval(LeaveType.annual)),
            _ApprovalMiniCard(label: 'Günlük İzin', count: _dailyC, onTap: () => _openApproval(LeaveType.daily)),
            _ApprovalMiniCard(label: 'Saatlik İzin', count: _hourlyC, onTap: () => _openApproval(LeaveType.hourly)),
            _ApprovalMiniCard(label: 'Avans', count: _advanceC, onTap: () => _openApproval(LeaveType.advance)),
          ],
        ),
      ]),
    );
  }

  Widget _buildOvertimeCard() {
    return PdksCard(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LateEarlyListScreen())),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 4, height: 24, color: AppColors.statusWarning),
          const SizedBox(width: AppDimens.spacingSm),
          const Expanded(child: Text('Dünkü Fazla Mesai / Eksik Mesai', style: TextStyle(fontSize: AppDimens.textSubtitle, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
        ]),
        const SizedBox(height: AppDimens.spacingSm),
        Row(children: [
          Expanded(child: Container(
            padding: const EdgeInsets.all(AppDimens.spacingSm),
            decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppDimens.cardRadius)),
            child: Column(children: [
              Text('$_overtimeC', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.statusSuccess)),
              const Text('Fazla Mesai', style: TextStyle(fontSize: AppDimens.textCaption, color: AppColors.textSecondary)),
            ]),
          )),
          const SizedBox(width: AppDimens.spacingXs),
          Expanded(child: Container(
            padding: const EdgeInsets.all(AppDimens.spacingSm),
            decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppDimens.cardRadius)),
            child: Column(children: [
              Text('$_undertimeC', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.statusEarly)),
              const Text('Eksik Mesai', style: TextStyle(fontSize: AppDimens.textCaption, color: AppColors.textSecondary)),
            ]),
          )),
        ]),
        const SizedBox(height: AppDimens.spacingSm),
        const Text('Detaylar için dokunun →', style: TextStyle(fontSize: AppDimens.textCaption, color: AppColors.primary)),
      ]),
    );
  }

  void _openApproval(String type) => Navigator.push(context, MaterialPageRoute(builder: (_) => ApprovalListScreen(type: type)));

  void _confirmLogout() {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text(AppStrings.logoutTitle),
      content: const Text(AppStrings.logoutMessage),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text(AppStrings.btnCancel)),
        TextButton(onPressed: () async {
          await sessionManager.logoutPatron();
          if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const ModuleSelectionScreen()), (_) => false);
        }, child: const Text(AppStrings.btnYes)),
      ],
    ));
  }
}

class _ApprovalMiniCard extends StatelessWidget {
  final String label;
  final int count;
  final VoidCallback onTap;
  const _ApprovalMiniCard({required this.label, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryVeryLight,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: const Color(0x22FF6D00),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.spacingSm),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('$count', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ]),
        ),
      ),
    );
  }
}