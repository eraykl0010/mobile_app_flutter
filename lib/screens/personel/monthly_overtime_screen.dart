import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../constants/app_theme.dart';
import '../../constants/app_strings.dart';
import '../../models/monthly_overtime.dart';
import '../../widgets/common_widgets.dart';

/// activity_monthly_overtime.xml birebir karşılığı
class MonthlyOvertimeScreen extends StatefulWidget {
  const MonthlyOvertimeScreen({super.key});
  @override
  State<MonthlyOvertimeScreen> createState() => _MonthlyOvertimeScreenState();
}

class _MonthlyOvertimeScreenState extends State<MonthlyOvertimeScreen> {
  MonthlyOvertime? _data;
  bool _loading = false;
  late List<String> _labels, _values;
  int _selIdx = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _labels = List.generate(6, (i) { final d = DateTime(now.year, now.month - i); return DateFormat('MMMM yyyy', 'tr_TR').format(d); });
    _values = List.generate(6, (i) { final d = DateTime(now.year, now.month - i); return DateFormat('yyyy-MM').format(d); });
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try { _data = await apiService.getMonthlyOvertime(sessionManager.personnelId, _values[_selIdx]); } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PdksToolbar(title: AppStrings.titleMonthlyOvertime),
      body: SingleChildScrollView(padding: const EdgeInsets.all(AppDimens.spacingMd), child: Column(children: [
        // Ay seçici — bg_edit_text.xml stili
        Container(
          height: AppDimens.buttonHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingSm),
          margin: const EdgeInsets.only(bottom: AppDimens.spacingMd),
          decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(AppDimens.buttonRadius), border: Border.all(color: AppColors.divider)),
          child: DropdownButtonHideUnderline(child: DropdownButton<int>(isExpanded: true, value: _selIdx,
              items: List.generate(_labels.length, (i) => DropdownMenuItem(value: i, child: Text(_labels[i]))),
              onChanged: (v) { _selIdx = v ?? 0; _load(); })),
        ),

        if (_loading) const CircularProgressIndicator(color: AppColors.primary)
        else if (_data != null) PdksCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Aylık Mesai Özeti', style: TextStyle(fontSize: AppDimens.textSubtitle, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: AppDimens.spacingMd),
          // 2x3 GridLayout karşılığı
          GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.5, children: [
              _StatBox(label: 'Toplam Saat', value: _data!.totalWorkHours.toStringAsFixed(1), color: AppColors.primary),
              _StatBox(label: 'Mesai Saat', value: _data!.totalOvertimeHours.toStringAsFixed(1), color: AppColors.accent),
              _StatBox(label: 'İş Günü', value: '${_data!.totalWorkDays}', color: AppColors.statusSuccess),
              _StatBox(label: 'Devamsız', value: '${_data!.absentDays}', color: AppColors.statusDanger),
              _StatBox(label: 'Geç Gelme', value: '${_data!.lateCount}', color: AppColors.statusWarning),
              _StatBox(label: 'Erken Çıkma', value: '${_data!.earlyLeaveCount}', color: AppColors.statusEarly),
            ]),
        ])),
      ])),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatBox({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.spacingMd),
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppDimens.cardRadius)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(value, style: TextStyle(fontSize: AppDimens.textLargeNumber, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: AppDimens.textCaption, color: AppColors.textSecondary)),
      ]),
    );
  }
}
