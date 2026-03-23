import 'package:flutter/material.dart';
import '../../main.dart';
import '../../constants/app_theme.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_constants.dart';
import '../../models/late_early_record.dart';
import '../../widgets/common_widgets.dart';

/// activity_late_early_list.xml + item_late_early.xml
class LateEarlyListScreen extends StatefulWidget {
  const LateEarlyListScreen({super.key});
  @override
  State<LateEarlyListScreen> createState() => _LateEarlyListScreenState();
}

class _LateEarlyListScreenState extends State<LateEarlyListScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<LateEarlyRecord> _all = [];
  String _filter = OvertimeType.overtime;
  bool _loading = false;

  @override
  void initState() { super.initState(); _tab = TabController(length: 2, vsync: this); _tab.addListener(() {
    if (!_tab.indexIsChanging) setState(() => _filter = _tab.index == 0 ? OvertimeType.overtime : OvertimeType.undertime);
  }); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try { _all = await apiService.getLateEarlyReport(); } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  List<LateEarlyRecord> get _filtered => _all.where((r) => r.type == _filter).toList();
  int get _oC => _all.where((r) => r.type == OvertimeType.overtime).length;
  int get _uC => _all.where((r) => r.type == OvertimeType.undertime).length;

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text(AppStrings.titleLateEarly),
        bottom: TabBar(controller: _tab, labelColor: AppColors.white, unselectedLabelColor: AppColors.white.withOpacity(0.7),
            indicatorColor: AppColors.white,
            tabs: [Tab(text: '${AppStrings.tabOvertime} ($_oC)'), Tab(text: '${AppStrings.tabUndertime} ($_uC)')]),
      ),
      body: _loading ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _filtered.isEmpty ? EmptyState(message: _filter == OvertimeType.overtime ? AppStrings.emptyOvertime : AppStrings.emptyUndertime)
          : ListView.builder(padding: const EdgeInsets.all(AppDimens.spacingSm), itemCount: _filtered.length,
              itemBuilder: (_, i) => _LeItem(r: _filtered[i])),
    );
  }
}

/// item_late_early.xml karşılığı
class _LeItem extends StatelessWidget {
  final LateEarlyRecord r;
  const _LeItem({required this.r});

  @override
  Widget build(BuildContext context) {
    final isOver = r.type == OvertimeType.overtime;
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.spacingSm),
      padding: const EdgeInsets.all(AppDimens.spacingMd),
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1))]),
      child: Row(children: [
        // Tür badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(gradient: AppColors.orangeGradient, borderRadius: BorderRadius.circular(4)),
          child: Text(isOver ? 'FAZLA' : 'EKSİK', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.white)),
        ),
        const SizedBox(width: AppDimens.spacingSm),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(r.personnelName ?? '-', style: const TextStyle(fontSize: AppDimens.textBody, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          Text(r.department ?? '', style: const TextStyle(fontSize: AppDimens.textCaption, color: AppColors.textSecondary)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(r.actualTime ?? '-', style: const TextStyle(fontSize: AppDimens.textBody, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          Text('+${r.differenceMinutes} dk', style: TextStyle(fontSize: AppDimens.textCaption, color: isOver ? AppColors.statusSuccess : AppColors.statusDanger)),
        ]),
      ]),
    );
  }
}
