class AdvanceRequest {
  final String? id, personnelName, department, reason, requestDate;
  final double amount;
  final String status;

  AdvanceRequest({this.id, this.personnelName, this.department, this.amount=0, this.reason, this.status='', this.requestDate});

  factory AdvanceRequest.fromJson(Map<String, dynamic> j) => AdvanceRequest(
    id: j['id']?.toString(), personnelName: j['personnel_name'], department: j['department'],
    amount: (j['amount']??0).toDouble(), reason: j['reason'], status: j['status']??'', requestDate: j['request_date'],
  );
}
