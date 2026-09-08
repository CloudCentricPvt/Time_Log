class ExpenseUpdateResult {
  final bool success;
  final String? message;
  final String? error;
  final int uploadedCount;
  final int totalUploads;
  final int successfulUploads;
  final bool hasUploads;
  final bool hasUploadErrors;

  ExpenseUpdateResult({
    required this.success,
    this.message,
    this.error,
    this.uploadedCount = 0,
    this.totalUploads = 0,
    this.successfulUploads = 0,
    this.hasUploads = false,
    this.hasUploadErrors = false,
  });
}