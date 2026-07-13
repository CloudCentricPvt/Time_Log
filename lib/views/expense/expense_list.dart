import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:time_log/controllers/expense_controller.dart';
import 'package:time_log/models/expense_list_res.dart';
import 'package:time_log/utils/constants/k_colors.dart';
import 'package:time_log/views/expense/update_expense.dart';

class ExpenseList extends StatefulWidget {
  const ExpenseList({super.key});

  @override
  State<ExpenseList> createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  final ExpenseController _controller = ExpenseController();
  bool _isLoading = true;
  ExpenseListResponse? _response;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    setState(() => _isLoading = true);
    String month = DateFormat('MMMM').format(DateTime.now());
    String year = DateFormat('yyyy').format(DateTime.now());

    var res = await _controller.getExpenses(context, month, year);
    setState(() {
      _response = res;
      _isLoading = false;
    });
  }

  /// Flatten all expenses from all monthly groups
  List<_ExpenseWithGroup> get _allExpenses {
    final List<_ExpenseWithGroup> result = [];
    for (var group in (_response?.data ?? [])) {
      for (var expense in (group.expenses ?? [])) {
        result.add(_ExpenseWithGroup(expense: expense, group: group));
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: KColors.appPrimary,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: KColors.appPrimary,
          statusBarIconBrightness: Brightness.light,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Expenses',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 12, bottom: 12),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: KColors.appPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                minimumSize: const Size(0, 30),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/create_expense')
                    .then((_) => _fetchExpenses());
              },
              child: const Text('Add Expense',
                  style:
                      TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: KColors.appPrimary),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedTabIndex = 0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _selectedTabIndex == 0
                                    ? KColors.appPrimary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.horizontal(
                                    left: const Radius.circular(20),
                                    right: _selectedTabIndex == 0
                                        ? const Radius.circular(20)
                                        : Radius.zero),
                              ),
                              alignment: Alignment.center,
                              child: Text('My Expense',
                                  style: TextStyle(
                                      color: _selectedTabIndex == 0
                                          ? Colors.white
                                          : KColors.appPrimary,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedTabIndex = 1),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _selectedTabIndex == 1
                                    ? KColors.appPrimary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.horizontal(
                                    right: const Radius.circular(20),
                                    left: _selectedTabIndex == 1
                                        ? const Radius.circular(20)
                                        : Radius.zero),
                              ),
                              alignment: Alignment.center,
                              child: Text('Team Expense',
                                  style: TextStyle(
                                      color: _selectedTabIndex == 1
                                          ? Colors.white
                                          : KColors.appPrimary,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange, width: 1.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child:
                      const Icon(Icons.tune, color: Colors.orange, size: 20),
                )
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchExpenses,
                    child: ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        _buildSummaryCard(),
                        const SizedBox(height: 16),
                        if (_allExpenses.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text("No expenses found."),
                            ),
                          )
                        else
                          ..._allExpenses.map((e) =>
                              _buildExpenseCard(e.expense, e.group)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final allExpenses = _allExpenses;
    double total = allExpenses.fold(
        0, (sum, e) => sum + (e.expense.expenseAmount ?? 0));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Expense',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            _response?.data?.isNotEmpty == true
                ? '${_response!.data!.first.month ?? ''} ${_response!.data!.first.year ?? ''}'
                : DateFormat('MMMM yyyy').format(DateTime.now()),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _summaryItem(
                  '${allExpenses.length}', 'Total', KColors.appPrimary),
              _summaryItem(
                  '₹ ${total.toStringAsFixed(0)}', 'Amount', Colors.blue),
              _summaryItem(
                  _response?.data?.firstOrNull?.status ?? 'N/A',
                  'Status',
                  Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(
      ExpenseModel expense, MonthlyExpenseGroup group) {
    final String groupStatus = group.status?.toLowerCase() ?? '';
    Color statusColor = Colors.grey;
    if (groupStatus.contains('approve')) statusColor = Colors.green;
    if (groupStatus.contains('review') || groupStatus.contains('draft'))
      statusColor = Colors.orange;
    if (groupStatus.contains('reject')) statusColor = Colors.red;

    final bool isDraft = groupStatus == 'draft';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            expense.expenseName ?? 'Expense',
                            style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            group.status ?? 'Draft',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1, color: Colors.grey),
                    const SizedBox(height: 8),
                    _detailRow('Category:', expense.expenseType ?? 'N/A'),
                    const SizedBox(height: 4),
                    _detailRow(
                        'Description:', expense.description ?? 'N/A'),
                    const SizedBox(height: 4),
                    _detailRow(
                        'Expense Date:', expense.formattedDate ?? 'N/A'),
                    if (expense.fromCity != null &&
                        expense.fromCity!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _detailRow('Route:',
                          '${expense.fromCity} → ${expense.toCity ?? ''}'),
                    ],
                    const SizedBox(height: 8),
                    const Divider(height: 1, color: Colors.grey),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.monthlyExpenseName ?? '',
                              style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Payment: ${expense.modeOfPayment ?? 'N/A'}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.lightBlue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '₹ ${expense.expenseAmount?.toStringAsFixed(2) ?? '0'}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        )
                      ],
                    ),
                    // Action Buttons
                    if (isDraft || groupStatus.contains('reject')) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (isDraft && group.monthlyExpenseId != null)
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: KColors.appPrimary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6)),
                                ),
                                icon: const Icon(Icons.send_rounded, size: 16),
                                label: const Text('Submit for Approval',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 13)),
                                onPressed: () =>
                                    _showApprovalDialog(group.monthlyExpenseId!),
                              ),
                            ),
                          if (isDraft && group.monthlyExpenseId != null)
                            const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: KColors.appPrimary,
                                side: BorderSide(color: KColors.appPrimary),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                              ),
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text('Edit',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 13)),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UpdateExpense(expense: expense),
                                  ),
                                ).then((result) {
                                  if (result == true) {
                                    _fetchExpenses();
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      )
                    ]
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(value,
              style: TextStyle(color: Colors.grey[700], fontSize: 12)),
        ),
      ],
    );
  }

  /// Shows a dialog to enter comments and submit for approval
  void _showApprovalDialog(String monthlyExpenseId) {
    final TextEditingController commentsController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Submit for Approval',
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add a comment for the approver (optional):',
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 12),
              TextField(
                controller: commentsController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g. Please approve my travel expenses...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: KColors.appPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      setDialogState(() => isSubmitting = true);
                      bool success =
                          await _controller.submitExpenseApproval(
                        context,
                        monthlyExpenseId,
                        commentsController.text.trim(),
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (success) _fetchExpenses();
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Submit',
                      style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper class to carry expense + its parent group
class _ExpenseWithGroup {
  final ExpenseModel expense;
  final MonthlyExpenseGroup group;
  _ExpenseWithGroup({required this.expense, required this.group});
}
