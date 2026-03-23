import '../constants/app_constants.dart';

class PersonnelInfo {
  final int id;
  final String name;
  final String? department, checkIn, checkOut;
  final String status;
  final bool isPatron;

  PersonnelInfo({required this.id, required this.name, this.department, this.checkIn, this.checkOut, this.status='', this.isPatron=false});

  String get statusDisplay => PersonnelStatus.display(status);

  factory PersonnelInfo.fromJson(Map<String, dynamic> j) {
    bool patron = false;
    final raw = j['is_patron'];
    if (raw is bool) patron = raw;
    if (raw is num) patron = raw.toInt() == 1;
    return PersonnelInfo(id: j['id']??0, name: j['name']??'', department: j['department'],
      checkIn: j['check_in'], checkOut: j['check_out'], status: j['status']??'', isPatron: patron);
  }
}
