class ExpenseSummaryResponse {
  final int totalSize;
  final bool done;
  final List<ExpenseSummaryRecord> records;

  ExpenseSummaryResponse({
    required this.totalSize,
    required this.done,
    required this.records,
  });

  factory ExpenseSummaryResponse.fromJson(Map<String, dynamic> json) {
    return ExpenseSummaryResponse(
      totalSize: json['totalSize'] ?? 0,
      done: json['done'] ?? true,
      records: (json['records'] as List?)
          ?.map((e) => ExpenseSummaryRecord.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class ExpenseSummaryRecord {
  final String? approvalStatus;
  final double? totalAmount;

  ExpenseSummaryRecord({
    this.approvalStatus,
    this.totalAmount,
  });

  factory ExpenseSummaryRecord.fromJson(Map<String, dynamic> json) {
    return ExpenseSummaryRecord(
      approvalStatus: json['Approval_Status__c'],
      totalAmount: json['totalAmount']?.toDouble(),
    );
  }
}