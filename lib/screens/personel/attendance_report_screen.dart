import 'package:flutter/material.dart';
import '../../main.dart';
import '../../constants/app_theme.dart';
import '../../constants/app_strings.dart';
import '../../models/attendance_record.dart';
import '../../widgets/common_widgets.dart';

/// activity_attendance_report.xml + item_attendance.xml birebir karşılığı
class AttendanceReportScreen extends StatefulWidget {
  const AttendanceReportScreen({super.key});
  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<AttendanceRecord> _records = [];
  bool _loading = false;

  @override
  void initState() { super.initState(); _tab = TabController(length: 2, vsync: this); _tab.addListener(() { if (!_tab.indexIsChanging) _load(); }); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try { final id = sessionManager.personnelId; _records = _tab.index == 0 ? await apiService.getDailyReport(id) : await apiService.getWeeklyReport(id); } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text(AppStrings.titleAttendanceReport),
        bottom: TabBar(controller: _tab, labelColor: AppColors.white, unselectedLabelColor: AppColors.white.withOpacity(0.7),
            indicatorColor: AppColors.white, tabs: const [Tab(text: AppStrings.tabDaily), Tab(text: AppStrings.tabWeekly)]),
      ),
      body: RefreshIndicator(color: AppColors.primary, onRefresh: _load,
        child: _loading ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _records.isEmpty ? const EmptyState(message: 'Kayıt bulunamadı')
            : ListView.builder(padding: const EdgeInsets.all(AppDimens.spacingSm), itemCount: _records.length,
                itemBuilder: (_, i) => _AttItem(r: _records[i]))),
    );
  }
}

/// item_attendance.xml karşılığı
class _AttItem extends StatelessWidget {
  final AttendanceRecord r;
  const _AttItem({required this.r});

  @override
  Widget build(BuildContext context) {
    // Tarihten gün numarasını çıkar
    String dayNum = '';
    if (r.date != null && r.date!.contains('.')) dayNum = r.date!.split('.')[0];

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.spacingSm),
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1))]),
      padding: const EdgeInsets.all(AppDimens.spacingMd),
      child: Row(children: [
        // Tarih / gün
        SizedBox(width: 60, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(dayNum, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
          Text(r.dayName ?? '', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ])),
        Container(width: 1, height: 40, color: AppColors.divider, margin: const EdgeInsets.symmetric(horizontal: AppDimens.spacingSm)),
        // Giriş-çıkış
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('Giriş: ', style: TextStyle(fontSize: AppDimens.textCaption, color: AppColors.textHint)),
            Text(r.checkIn ?? '--:--', style: const TextStyle(fontSize: AppDimens.textBody, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Text('  Çıkış: ', style: TextStyle(fontSize: AppDimens.textCaption, color: AppColors.textHint)),
            Text(r.checkOut ?? '--:--', style: const TextStyle(fontSize: AppDimens.textBody, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 2),
          Text(r.overtimeHours != null && r.overtimeHours!.isNotEmpty
              ? 'Çalışma: ${r.workHours ?? '-'} | Mesai: ${r.overtimeHours}'
              : 'Çalışma: ${r.workHours ?? '-'}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ])),
        StatusBadge(status: r.status),
      ]),
    );
  }
}