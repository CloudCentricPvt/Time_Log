import 'content_version_request.dart';

class ExpenseCreationResult {
  final bool success;
  final String? expenseId;
  final List<ContentVersionResponse> uploadResponses;
  final int successfulUploads;
  final int totalUploads;
  final String? message;
  final String? error;

  ExpenseCreationResult({
    required this.success,
    this.expenseId,
    this.uploadResponses = const [],
    this.successfulUploads = 0,
    this.totalUploads = 0,
    this.message,
    this.error,
  });

  bool get hasUploadErrors => successfulUploads < totalUploads;
  bool get hasUploads => totalUploads > 0;
}