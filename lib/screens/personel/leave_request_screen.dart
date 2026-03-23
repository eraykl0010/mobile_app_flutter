import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../constants/app_theme.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_constants.dart';
import '../../models/leave_submit_request.dart';
import '../../models/leave_request.dart';
import '../../widgets/common_widgets.dart';

/// activity_leave_request.xml + fragment_leave_form.xml + fragment_leave_history.xml + item_leave_history.xml
class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});
  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  @override
  void initState() { super.initState(); _tab = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text(AppStrings.titleLeaveRequest),
        bottom: TabBar(controller: _tab, labelColor: AppColors.white, unselectedLabelColor: AppColors.white.withOpacity(0.7),
            indicatorColor: AppColors.white, tabs: const [Tab(text: AppStrings.tabNewRequest), Tab(text: AppStrings.tabHistory)]),
      ),
      body: TabBarView(controller: _tab, children: const [_LeaveForm(), _LeaveHist()]),
    );
  }
}

class _LeaveForm extends StatefulWidget { const _LeaveForm(); @override State<_LeaveForm> createState() => _LeaveFormState(); }
class _LeaveFormState extends State<_LeaveForm> {
  int _typeIdx = 0;
  final _startD = TextEditingController(), _endD = TextEditingController(), _startT = TextEditingController(), _endT = TextEditingController(), _reason = TextEditingController();
  bool _loading = false;
  final _df = DateFormat('dd.MM.yyyy'), _tf = DateFormat('HH:mm');
  bool get _hourly => _typeIdx == 2;
  bool get _daily => _typeIdx == 1;

  Future<void> _pickDate(TextEditingController c) async {
    final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
    if (d != null) { c.text = _df.format(d); if ((_daily || _hourly) && c == _startD) _endD.text = c.text; setState(() {}); }
  }
  Future<void> _pickTime(TextEditingController c) async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) { c.text = _tf.format(DateTime(0, 0, 0, t.hour, t.minute)); setState(() {}); }
  }
  void _msg(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _submit() async {
    if (_startD.text.isEmpty) { _msg(AppStrings.errorStartDateRequired); return; }
    if (_typeIdx == 0 && _endD.text.isEmpty) { _msg(AppStrings.errorEndDateRequired); return; }
    if (_hourly && (_startT.text.isEmpty || _endT.text.isEmpty)) { _msg(AppStrings.errorTimeRangeRequired); return; }
    if (_daily || _hourly) _endD.text = _startD.text;
    setState(() => _loading = true);
    try {
      final req = LeaveSubmitRequest(personnelId: sessionManager.personnelId, leaveType: LeaveType.values[_typeIdx],
          startDate: _startD.text, endDate: _endD.text, startTime: _hourly ? _startT.text : null, endTime: _hourly ? _endT.text : null,
          reason: _reason.text.isEmpty ? '-' : _reason.text);
      final resp = await apiService.submitLeaveRequest(req);
      if (mounted) { _msg(resp.success ? AppStrings.leaveRequestSent : (resp.message ?? AppStrings.errorSubmitFailed)); if (resp.success) { _startD.clear(); _endD.clear(); _startT.clear(); _endT.clear(); _reason.clear(); setState(() => _typeIdx = 0); } }
    } catch (e) { if (mounted) _msg('Hata: $e'); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.all(AppDimens.spacingMd), child: PdksCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('İzin Türü', style: TextStyle(fontSize: AppDimens.textCaption, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
      const SizedBox(height: AppDimens.spacingXs),
      Container(height: AppDimens.buttonHeight, padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingSm),
        decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(AppDimens.buttonRadius), border: Border.all(color: AppColors.divider)),
        child: DropdownButtonHideUnderline(child: DropdownButton<int>(isExpanded: true, value: _typeIdx,
            items: List.generate(3, (i) => DropdownMenuItem(value: i, child: Text(LeaveType.labels[i]))),
            onChanged: (v) => setState(() { _typeIdx = v ?? 0; if (_daily || _hourly) _endD.text = _startD.text; }))),
      ),
      const SizedBox(height: AppDimens.spacingMd),
      const Text('Başlangıç Tarihi', style: TextStyle(fontSize: AppDimens.textCaption, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
      const SizedBox(height: AppDimens.spacingXs),
      TextField(controller: _startD, readOnly: true, onTap: () => _pickDate(_startD), decoration: const InputDecoration(hintText: 'Tarih seçin')),
      const SizedBox(height: AppDimens.spacingMd),
      const Text('Bitiş Tarihi', style: TextStyle(fontSize: AppDimens.textCaption, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
      const SizedBox(height: AppDimens.spacingXs),
      TextField(controller: _endD, readOnly: true, enabled: !_daily && !_hourly, onTap: () => _pickDate(_endD), decoration: const InputDecoration(hintText: 'Tarih seçin')),
      if (_hourly) ...[
        const SizedBox(height: AppDimens.spacingMd),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Başlangıç Saati', style: TextStyle(fontSize: AppDimens.textCaption, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            const SizedBox(height: AppDimens.spacingXs),
            TextField(controller: _startT, readOnly: true, onTap: () => _pickTime(_startT), decoration: const InputDecoration(hintText: 'Saat')),
          ])),
          const SizedBox(width: AppDimens.spacingSm),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Bitiş Saati', style: TextStyle(fontSize: AppDimens.textCaption, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            const SizedBox(height: AppDimens.spacingXs),
            TextField(controller: _endT, readOnly: true, onTap: () => _pickTime(_endT), decoration: const InputDecoration(hintText: 'Saat')),
          ])),
        ]),
      ],
      const SizedBox(height: AppDimens.spacingMd),
      const Text('Açıklama', style: TextStyle(fontSize: AppDimens.textCaption, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
      const SizedBox(height: AppDimens.spacingXs),
      TextField(controller: _reason, maxLines: 3, decoration: const InputDecoration(hintText: 'İzin sebebinizi yazın')),
      const SizedBox(height: AppDimens.spacingMd),
      SizedBox(width: double.infinity, height: AppDimens.buttonHeight, child: ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: _loading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white)) : const Text('TALEP GÖNDER'))),
    ])));
  }
}

class _LeaveHist extends StatefulWidget { const _LeaveHist(); @override State<_LeaveHist> createState() => _LeaveHistState(); }
class _LeaveHistState extends State<_LeaveHist> {
  List<LeaveRequest> _items = [];
  bool _loading = true;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() => _loading = true);
    try { _items = await apiService.getLeaveHistory(sessionManager.personnelId); } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (_items.isEmpty) return const EmptyState(message: 'Henüz izin talebi bulunmuyor');
    return ListView.builder(padding: const EdgeInsets.all(AppDimens.spacingSm), itemCount: _items.length, itemBuilder: (_, i) {
      final it = _items[i];
      return Container(
        margin: const EdgeInsets.only(bottom: AppDimens.spacingSm),
        padding: const EdgeInsets.all(AppDimens.spacingMd),
        decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1))]),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(it.leaveTypeDisplay, style: const TextStyle(fontSize: AppDimens.textBody, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Text('${it.startDate ?? ''} — ${it.endDate ?? ''}', style: const TextStyle(fontSize: AppDimens.textCaption, color: AppColors.textSecondary)),
            Text('Talep: ${it.requestDate ?? '-'}', style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
          ])),
          StatusBadge(status: it.status ?? ''),
        ]),
      );
    });
  }
}
