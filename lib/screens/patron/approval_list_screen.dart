import 'package:flutter/material.dart';
import '../../main.dart';
import '../../constants/app_theme.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_constants.dart';
import '../../models/leave_request.dart';
import '../../models/advance_request.dart';
import '../../models/approval_request.dart';
import '../../widgets/common_widgets.dart';

/// activity_approval_list.xml + item_leave_approval.xml + item_advance_approval.xml
class ApprovalListScreen extends StatefulWidget {
  final String type;
  const ApprovalListScreen({super.key, required this.type});
  @override
  State<ApprovalListScreen> createState() => _ApprovalListScreenState();
}

class _ApprovalListScreenState extends State<ApprovalListScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<dynamic> _items = [];
  bool _loading = false;
  String _status = RequestStatus.pending;

  String get _title {
    switch (widget.type) {
      case LeaveType.annual: return AppStrings.titleAnnualLeave;
      case LeaveType.daily: return AppStrings.titleDailyLeave;
      case LeaveType.hourly: return AppStrings.titleHourlyLeave;
      case LeaveType.advance: return AppStrings.titleAdvanceApproval;
      default: return 'Talepler';
    }
  }

  @override
  void initState() { super.initState(); _tab = TabController(length: 3, vsync: this); _tab.addListener(() {
    if (!_tab.indexIsChanging) { _status = [RequestStatus.pending, RequestStatus.approved, RequestStatus.rejected][_tab.index]; _load(); }
  }); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      if (widget.type == LeaveType.advance) _items = await apiService.getPendingAdvanceRequests(status: _status);
      else _items = await apiService.getPendingLeaveRequests(type: widget.type, status: _status);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _doApproval(String id, String reqType, String action, int idx) async {
    final req = ApprovalRequest(requestId: id, requestType: reqType, action: action);
    try {
      final resp = action == ApprovalAction.approve ? await apiService.approveRequest(req) : await apiService.rejectRequest(req);
      if (resp.success && mounted) { setState(() => _items.removeAt(idx)); _msg(action == ApprovalAction.approve ? AppStrings.statusApproved : AppStrings.statusRejected); }
    } catch (_) {}
  }

  void _confirm(String id, String reqType, String action, int idx) {
    final isA = action == ApprovalAction.approve;
    final isAdv = widget.type == LeaveType.advance;
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text(isA ? AppStrings.confirmApproveTitle : AppStrings.confirmRejectTitle),
      content: Text(isA ? (isAdv ? AppStrings.confirmApproveAdvance : AppStrings.confirmApproveLeave) : (isAdv ? AppStrings.confirmRejectAdvance : AppStrings.confirmRejectLeave)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text(AppStrings.btnCancel)),
        TextButton(onPressed: () { Navigator.pop(context); _doApproval(id, reqType, action, idx); }, child: const Text(AppStrings.btnYes)),
      ],
    ));
  }

  void _msg(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text(_title),
        bottom: TabBar(controller: _tab, labelColor: AppColors.white, unselectedLabelColor: AppColors.white.withOpacity(0.7),
            indicatorColor: AppColors.white, labelStyle: const TextStyle(fontSize: 13),
            tabs: const [Tab(text: AppStrings.tabPending), Tab(text: AppStrings.tabApproved), Tab(text: AppStrings.tabRejected)]),
      ),
      body: RefreshIndicator(color: AppColors.primary, onRefresh: _load,
        child: _loading ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _items.isEmpty ? EmptyState(message: _status == RequestStatus.pending ? AppStrings.emptyPending : _status == RequestStatus.approved ? AppStrings.emptyApproved : AppStrings.emptyRejected)
            : ListView.builder(padding: const EdgeInsets.all(AppDimens.spacingSm), itemCount: _items.length, itemBuilder: (_, i) {
                final it = _items[i];
                final show = _status == RequestStatus.pending;
                if (it is AdvanceRequest) return _AdvApprovalItem(it: it, idx: i, show: show, onAction: _confirm);
                return _LeaveApprovalItem(it: it as LeaveRequest, idx: i, show: show, onAction: _confirm);
              })),
    );
  }
}

/// item_leave_approval.xml karşılığı
class _LeaveApprovalItem extends StatelessWidget {
  final LeaveRequest it;
  final int idx;
  final bool show;
  final void Function(String, String, String, int) onAction;
  const _LeaveApprovalItem({required this.it, required this.idx, required this.show, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.spacingSm),
      padding: const EdgeInsets.all(AppDimens.spacingMd),
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // İsim + tür badge
        Row(children: [
          Expanded(child: Text(it.personnelName ?? '-', style: const TextStyle(fontSize: AppDimens.textSubtitle, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), decoration: BoxDecoration(gradient: AppColors.orangeGradient, borderRadius: BorderRadius.circular(8)),
              child: Text(it.leaveTypeDisplay, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.white))),
        ]),
        const SizedBox(height: 2),
        Text(it.department ?? '', style: const TextStyle(fontSize: AppDimens.textCaption, color: AppColors.textSecondary)),
        const Divider(height: AppDimens.spacingMd * 2),
        // Tarih satırı
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Başlangıç', style: TextStyle(fontSize: 11, color: AppColors.textHint)),
            Text(it.startDate ?? '-', style: const TextStyle(fontSize: AppDimens.textBody, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ])),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Bitiş', style: TextStyle(fontSize: 11, color: AppColors.textHint)),
            Text(it.endDate ?? '-', style: const TextStyle(fontSize: AppDimens.textBody, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ])),
          if (it.leaveType == LeaveType.annual) Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            const Text('Kalan Hak', style: TextStyle(fontSize: 11, color: AppColors.textHint)),
            Text('${it.remainingDays.toStringAsFixed(0)} gün', style: const TextStyle(fontSize: AppDimens.textBody, fontWeight: FontWeight.bold, color: AppColors.statusInfo)),
          ]),
        ]),
        if (it.reason != null && it.reason != '-' && it.reason!.isNotEmpty) Padding(padding: const EdgeInsets.only(top: AppDimens.spacingSm),
            child: Text('Sebep: ${it.reason}', style: const TextStyle(fontSize: AppDimens.textCaption, color: AppColors.textSecondary))),
        if (show) Padding(padding: const EdgeInsets.only(top: AppDimens.spacingSm), child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          SizedBox(height: 38, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingMd)),
            onPressed: () => onAction(it.id ?? '', RequestType.leave, ApprovalAction.reject, idx),
            child: const Text('REDDET', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.white)),
          )),
          const SizedBox(width: AppDimens.spacingSm),
          SizedBox(height: 38, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingMd)),
            onPressed: () => onAction(it.id ?? '', RequestType.leave, ApprovalAction.approve, idx),
            child: const Text('ONAYLA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          )),
        ])),
      ]),
    );
  }
}

/// item_advance_approval.xml karşılığı
class _AdvApprovalItem extends StatelessWidget {
  final AdvanceRequest it;
  final int idx;
  final bool show;
  final void Function(String, String, String, int) onAction;
  const _AdvApprovalItem({required this.it, required this.idx, required this.show, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.spacingSm),
      padding: const EdgeInsets.all(AppDimens.spacingMd),
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(it.personnelName ?? '-', style: const TextStyle(fontSize: AppDimens.textSubtitle, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
          Text('₺${it.amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
        ]),
        const SizedBox(height: 2),
        Text(it.department ?? '', style: const TextStyle(fontSize: AppDimens.textCaption, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text('Talep: ${it.requestDate ?? '-'}', style: const TextStyle(fontSize: AppDimens.textCaption, color: AppColors.textHint)),
        if (it.reason != null && it.reason != '-' && it.reason!.isNotEmpty) Padding(padding: const EdgeInsets.only(top: AppDimens.spacingSm),
            child: Text(it.reason!, style: const TextStyle(fontSize: AppDimens.textCaption, color: AppColors.textSecondary))),
        if (show) Padding(padding: const EdgeInsets.only(top: AppDimens.spacingSm), child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          SizedBox(height: 38, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingMd)),
            onPressed: () => onAction(it.id ?? '', RequestType.advance, ApprovalAction.reject, idx),
            child: const Text('REDDET', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.white)),
          )),
          const SizedBox(width: AppDimens.spacingSm),
          SizedBox(height: 38, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingMd)),
            onPressed: () => onAction(it.id ?? '', RequestType.advance, ApprovalAction.approve, idx),
            child: const Text('ONAYLA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          )),
        ])),
      ]),
    );
  }
}
