class AdvanceSubmitRequest {
  final int personnelId;
  final double amount;
  final String reason;

  AdvanceSubmitRequest({required this.personnelId, required this.amount, required this.reason});

  Map<String, dynamic> toJson() => {'personnel_id': personnelId, 'amount': amount, 'reason': reason};
}
