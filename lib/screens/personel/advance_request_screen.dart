import 'package:flutter/material.dart';
import '../../main.dart';
import '../../constants/app_theme.dart';
import '../../constants/app_strings.dart';
import '../../models/advance_submit_request.dart';
import '../../models/advance_request.dart';
import '../../widgets/common_widgets.dart';

/// activity_advance_request.xml + fragment_advance_form.xml + item_advance_history.xml
class AdvanceRequestScreen extends StatefulWidget {
  const AdvanceRequestScreen({super.key});
  @override
  State<AdvanceRequestScreen> createState() => _AdvanceRequestScreenState();
}

class _AdvanceRequestScreenState extends State<AdvanceRequestScreen> with SingleTickerProviderStateMixin {
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
        title: const Text(AppStrings.titleAdvanceRequest),
        bottom: TabBar(controller: _tab, labelColor: AppColors.white, unselectedLabelColor: AppColors.white.withOpacity(0.7),
            indicatorColor: AppColors.white, tabs: const [Tab(text: AppStrings.tabNewRequest), Tab(text: AppStrings.tabHistory)]),
      ),
      body: TabBarView(controller: _tab, children: const [_AdvForm(), _AdvHist()]),
    );
  }
}

class _AdvForm extends StatefulWidget { const _AdvForm(); @override State<_AdvForm> createState() => _AdvFormState(); }
class _AdvFormState extends State<_AdvForm> {
  final _amtC = TextEditingController(), _resC = TextEditingController();
  bool _loading = false;
  void _msg(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _submit() async {
    if (_amtC.text.isEmpty) { _msg(AppStrings.errorAmountRequired); return; }
    final amt = double.tryParse(_amtC.text.trim());
    if (amt == null) { _msg(AppStrings.errorAmountInvalid); return; }
    if (amt <= 0) { _msg(AppStrings.errorAmountPositive); return; }
    setState(() => _loading = true);
    try {
      final req = AdvanceSubmitRequest(personnelId: sessionManager.personnelId, amount: amt, reason: _resC.text.isEmpty ? '-' : _resC.text);
      final resp = await apiService.submitAdvanceRequest(req);
      if (mounted) { _msg(resp.success ? AppStrings.advanceRequestSent : (resp.message ?? AppStrings.errorSubmitFailed)); if (resp.success) { _amtC.clear(); _resC.clear(); } }
    } catch (e) { if (mounted) _msg('Hata: $e'); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.all(AppDimens.spacingMd), child: PdksCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Avans Tutarı (₺)', style: TextStyle(fontSize: AppDimens.textCaption, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
      const SizedBox(height: AppDimens.spacingXs),
      TextField(controller: _amtC, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Tutar girin')),
      const SizedBox(height: AppDimens.spacingMd),
      const Text('Açıklama', style: TextStyle(fontSize: AppDimens.textCaption, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
      const SizedBox(height: AppDimens.spacingXs),
      TextField(controller: _resC, maxLines: 3, decoration: const InputDecoration(hintText: 'Avans sebebinizi yazın')),
      const SizedBox(height: AppDimens.spacingMd),
      SizedBox(width: double.infinity, height: AppDimens.buttonHeight, child: ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: _loading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white)) : const Text('TALEP GÖNDER'))),
    ])));
  }
}

class _AdvHist extends StatefulWidget { const _AdvHist(); @override State<_AdvHist> createState() => _AdvHistState(); }
class _AdvHistState extends State<_AdvHist> {
  List<AdvanceRequest> _items = [];
  bool _loading = true;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() => _loading = true);
    try { _items = await apiService.getAdvanceHistory(sessionManager.personnelId); } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (_items.isEmpty) return const EmptyState(message: AppStrings.advanceHistoryEmpty);
    return ListView.builder(padding: const EdgeInsets.all(AppDimens.spacingSm), itemCount: _items.length, itemBuilder: (_, i) {
      final it = _items[i];
      return Container(
        margin: const EdgeInsets.only(bottom: AppDimens.spacingSm),
        padding: const EdgeInsets.all(AppDimens.spacingMd),
        decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1))]),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('₺${it.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: AppDimens.textBody, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            if (it.reason != null && it.reason != '-') Text(it.reason!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: AppDimens.textCaption, color: AppColors.textSecondary)),
            Text('Talep: ${it.requestDate ?? '-'}', style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
          ])),
          StatusBadge(status: it.status),
        ]),
      );
    });
  }
}
