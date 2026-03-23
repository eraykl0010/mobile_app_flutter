class ApprovalRequest {
  final String requestId, requestType, action;
  final String? note;

  ApprovalRequest({required this.requestId, required this.requestType, required this.action, this.note});

  Map<String, dynamic> toJson() => {'request_id': requestId, 'request_type': requestType, 'action': action, 'note': note};
}
