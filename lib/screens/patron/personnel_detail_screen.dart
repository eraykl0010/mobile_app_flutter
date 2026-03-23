import 'package:flutter/material.dart';
import '../../main.dart';
import '../../constants/app_theme.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_constants.dart';
import '../../models/personnel_info.dart';
import '../../models/dashboard_summary.dart';
import '../../models/department.dart';
import '../../models/reset_device_request.dart';
import '../../widgets/common_widgets.dart';

/// activity_personnel_detail.xml + item_personnel.xml
class PersonnelDetailScreen extends StatefulWidget {
  const PersonnelDetailScreen({super.key});
  @override
  State<PersonnelDetailScreen> createState() => _PersonnelDetailScreenState();
}

class _PersonnelDetailScreenState extends State<PersonnelDetailScreen> {
  List<PersonnelInfo> _all = [], _filtered = [];
  List<Department> _depts = [];
  DashboardSummary _sum = DashboardSummary();
  int? _deptId;
  String? _statusF;
  bool _loading = false;

  @override
  void initState() { super.initState(); _loadAll(); }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    await Future.wait([_loadDepts(), _loadList(), _loadSum()]);
    if (mounted) setState(() => _loading = false);
  }
  Future<void> _loadDepts() async { try { _depts = await apiService.getDepartments(); } catch (_) {} }
  Future<void> _loadList() async { try { _all = await apiService.getPersonnelList(); _filter(); } catch (_) {} }
  Future<void> _loadSum() async { try { _sum = await apiService.getDashboardSummary(departmentId: _deptId); } catch (_) {} }

  void _filter() {
    _filtered = _all.where((p) {
      if (_deptId != null) { final d = _depts.where((d) => d.id == _deptId).firstOrNull; if (d != null && p.department != d.name) return false; }
      if (_statusF != null && p.status != _statusF) return false;
      return true;
    }).toList();
  }

  void _onStatusTap(String s) { setState(() { _statusF = _statusF == s ? null : s; _filter(); }); }

  void _showOpts(PersonnelInfo p) {
    showModalBottomSheet(context: context, builder: (_) => SafeArea(child: ListTile(
      leading: const Icon(Icons.phonelink_erase, color: AppColors.statusDanger),
      title: const Text(AppStrings.deviceResetOption),
      onTap: () { Navigator.pop(context); _confirmReset(p); },
    )));
  }

  void _confirmReset(PersonnelInfo p) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Cihaz Kaydını Sıfırla'),
      content: Text(AppStrings.deviceResetMessage(p.name)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text(AppStrings.btnCancel)),
        TextButton(child: const Text('Sıfırla', style: TextStyle(color: AppColors.statusDanger)), onPressed: () async {
          Navigator.pop(context);
          try { final r = await apiService.resetDevice(ResetDeviceRequest(personnelId: p.id, resetBy: sessionManager.personnelId));
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(r.success ? AppStrings.deviceResetSuccess(p.name) : AppStrings.deviceResetFailed))); } catch (_) {}
        }),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PdksToolbar(title: AppStrings.titlePersonnelDetail),
      body: RefreshIndicator(color: AppColors.primary, onRefresh: _loadAll, child: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(children: [
              // Departman filtre
              Container(color: AppColors.white, padding: const EdgeInsets.all(AppDimens.spacingMd), child: Row(children: [
                const Text('Departman: ', style: TextStyle(fontSize: AppDimens.textBody, color: AppColors.textSecondary)),
                Expanded(child: Container(height: 40, padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingSm),
                  decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(AppDimens.buttonRadius), border: Border.all(color: AppColors.divider)),
                  child: DropdownButtonHideUnderline(child: DropdownButton<int?>(isExpanded: true, value: _deptId,
                    hint: const Text(AppStrings.allDepartments),
                    items: [const DropdownMenuItem<int?>(value: null, child: Text(AppStrings.allDepartments)), ..._depts.map((d) => DropdownMenuItem<int?>(value: d.id, child: Text(d.name)))],
                    onChanged: (v) { _deptId = v; _statusF = null; _filter(); _loadSum().then((_) => setState(() {})); },
                  )))),
              ])),

              // Özet grid — tıklanabilir
              Padding(padding: const EdgeInsets.all(AppDimens.spacingMd), child: PdksCard(padding: const EdgeInsets.all(AppDimens.spacingSm), child:
                GridView.count(crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.0, children: [
                    SummaryBox(label: 'Mevcut', value: '${_sum.totalCount}', valueColor: AppColors.statusInfo, onTap: () => setState(() { _statusF = null; _filter(); })),
                    SummaryBox(label: 'Aktif Çalışan', value: '${_sum.activeCount}', valueColor: AppColors.statusSuccess, onTap: () => _onStatusTap(PersonnelStatus.active)),
                    SummaryBox(label: 'İzinli', value: '${_sum.onLeaveCount}', valueColor: AppColors.accent, onTap: () => _onStatusTap(PersonnelStatus.onLeave)),
                    SummaryBox(label: 'Devamsız', value: '${_sum.absentCount}', valueColor: AppColors.statusDanger, onTap: () => _onStatusTap(PersonnelStatus.absent)),
                    SummaryBox(label: 'Geç Kalan', value: '${_sum.lateCount}', valueColor: AppColors.statusWarning, onTap: () => _onStatusTap(PersonnelStatus.late)),
                    SummaryBox(label: 'Erken Çıkan', value: '${_sum.earlyLeaveCount}', valueColor: AppColors.statusEarly, onTap: () => _onStatusTap(PersonnelStatus.early)),
                  ]),
              )),

              // Filtre göstergesi
              if (_statusF != null) Padding(padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingMd),
                child: Row(children: [
                  Expanded(child: Text('Filtre: ${PersonnelStatus.display(_statusF!)}', style: const TextStyle(fontSize: AppDimens.textCaption, fontWeight: FontWeight.bold, color: AppColors.primary))),
                  GestureDetector(onTap: () => setState(() { _statusF = null; _filter(); }),
                      child: const Text('✕ Temizle', style: TextStyle(fontSize: AppDimens.textCaption, fontWeight: FontWeight.bold, color: AppColors.statusDanger))),
                ])),

              Padding(padding: const EdgeInsets.fromLTRB(AppDimens.spacingMd, AppDimens.spacingSm, AppDimens.spacingMd, AppDimens.spacingSm),
                child: Text('Personel Listesi', style: const TextStyle(fontSize: AppDimens.textSubtitle, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),

              // Liste
              ..._filtered.map((p) => _PersonnelItem(p: p, onLong: () => _showOpts(p))),
              const SizedBox(height: AppDimens.spacingLg),
            ])),
    );
  }
}

/// item_personnel.xml karşılığı
class _PersonnelItem extends StatelessWidget {
  final PersonnelInfo p;
  final VoidCallback onLong;
  const _PersonnelItem({required this.p, required this.onLong});

  Color get _indicatorColor {
    switch (p.status) {
      case PersonnelStatus.active: return AppColors.statusSuccess;
      case PersonnelStatus.onLeave: return AppColors.accent;
      case PersonnelStatus.absent: return AppColors.statusDanger;
      case PersonnelStatus.late: return AppColors.statusWarning;
      case PersonnelStatus.early: return AppColors.statusEarly;
      default: return AppColors.statusNeutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.spacingSm, vertical: AppDimens.spacingXs),
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1))]),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onLongPress: onLong,
        child: Padding(padding: const EdgeInsets.all(AppDimens.spacingMd), child: Row(children: [
          // Sol durum çizgisi
          Container(width: 6, height: 40, decoration: BoxDecoration(color: _indicatorColor, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: AppDimens.spacingSm),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.name, style: const TextStyle(fontSize: AppDimens.textBody, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Text(p.department ?? '', style: const TextStyle(fontSize: AppDimens.textCaption, color: AppColors.textSecondary)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('G: ${p.checkIn ?? '--:--'}', style: const TextStyle(fontSize: AppDimens.textCaption, color: AppColors.textPrimary)),
            Text('Ç: ${p.checkOut ?? '--:--'}', style: const TextStyle(fontSize: AppDimens.textCaption, color: AppColors.textSecondary)),
          ]),
          const SizedBox(width: AppDimens.spacingSm),
          StatusBadge(status: p.status),
        ])),
      ),
    );
  }
}
