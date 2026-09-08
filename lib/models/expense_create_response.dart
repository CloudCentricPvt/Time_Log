class ExpenseCreateResponse {
  final bool success;
  final String? expenseId;
  final String? monthlyExpenseId;
  final String? message;
  final List<dynamic>? errors;

  ExpenseCreateResponse({
    required this.success,
    this.expenseId,
    this.monthlyExpenseId,
    this.message,
    this.errors,
  });
}