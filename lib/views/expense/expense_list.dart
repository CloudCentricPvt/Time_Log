import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:time_log/controllers/expense_controller.dart';
import 'package:time_log/models/expense_list_res.dart';
import 'package:time_log/utils/constants/k_colors.dart';
import 'package:time_log/views/expense/update_expense.dart';

import '../../models/expense_list_response.dart';
import '../../models/expense_summary_response.dart';
import '../../network/salesforce_api_service.dart';
import '../../utils/constants/k_fonts.dart';
import 'expense_detail_dialog.dart';

// ============================================================================
// MAIN WIDGET
// ============================================================================

class ExpenseList extends StatefulWidget {
  const ExpenseList({super.key});

  @override
  State<ExpenseList> createState() => _ExpenseListState();
}

// ============================================================================
// STATE CLASS
// ============================================================================

class _ExpenseListState extends State<ExpenseList> {
  // ==========================================================================
  // DEPENDENCIES
  // ==========================================================================

  late final ExpenseController _controller;
  final localStorage = GetStorage();

  // ==========================================================================
  // STATE VARIABLES
  // ==========================================================================

  ExpenseSummaryResponse? _summaryResponse;
  bool _isSummaryLoading = true;

  bool _isLoading = true;
  ExpenseListResponse? _expenseResponse;
  int _selectedTabIndex = 0;

  // ==========================================================================
  // LIFECYCLE
  // ==========================================================================

  @override
  void initState() {
    super.initState();
    _controller = ExpenseController(SalesforceAPIService());
    _fetchExpenseSummary();
    _fetchExpenses();
  }

  // ==========================================================================
  // DATA FETCHING
  // ==========================================================================

  Future<void> _fetchExpenseSummary() async {
    setState(() => _isSummaryLoading = true);

    try {
      final empId = localStorage.read("EMP_ID") ?? '';

      if (empId.isEmpty) {
        setState(() {
          _summaryResponse = ExpenseSummaryResponse(
            totalSize: 0,
            done: true,
            records: [],
          );
          _isSummaryLoading = false;
        });
        return;
      }

      final response = await _controller.getExpenseSummary(empId);

      setState(() {
        _summaryResponse = response;
        _isSummaryLoading = false;
      });
    } catch (e) {
      setState(() {
        _summaryResponse = ExpenseSummaryResponse(
          totalSize: 0,
          done: true,
          records: [],
        );
        _isSummaryLoading = false;
      });
    }
  }

  // Helper method to get amount by status
  double _getAmountByStatus(String status) {
    if (_summaryResponse == null) return 0.0;

    final record = _summaryResponse!.records.firstWhere(
      (r) => r.approvalStatus?.toLowerCase() == status.toLowerCase(),
      orElse: () => ExpenseSummaryRecord(),
    );
    return record.totalAmount ?? 0.0;
  }

  // Get total expense (sum of all statuses)
  double get _totalExpense {
    if (_summaryResponse == null) return 0.0;
    return _summaryResponse!.records.fold(
      0.0,
      (sum, record) => sum + (record.totalAmount ?? 0.0),
    );
  }

  Future<void> _fetchExpenses() async {
    setState(() => _isLoading = true);

    try {
      // Get employee ID from storage
      final empId = localStorage.read("EMP_ID") ?? '';

      if (empId.isEmpty) {
        print("❌ Employee ID not found in storage");
        setState(() {
          _expenseResponse = ExpenseListResponse(
            totalSize: 0,
            done: true,
            records: [],
          );
          _isLoading = false;
        });
        return;
      }

      // Fetch expenses from Salesforce
      final response = await _controller.getExpensesByEmployee(empId);

      setState(() {
        _expenseResponse = response;
        _isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching expenses: $e");
      setState(() {
        _expenseResponse = ExpenseListResponse(
          totalSize: 0,
          done: true,
          records: [],
        );
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load expenses'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==========================================================================
  // COMPUTED PROPERTIES
  // ==========================================================================

  /// All expenses from the response
  List<ExpenseRecord> get _allExpenses => _expenseResponse?.records ?? [];

  /// Current month/year display string
  String get _currentMonthYear {
    if (_allExpenses.isNotEmpty) {
      final firstExpense = _allExpenses.first;
      if (firstExpense.expenseDate != null) {
        try {
          final date = DateTime.parse(firstExpense.expenseDate!);
          return DateFormat('MMMM yyyy').format(date);
        } catch (e) {
          return DateFormat('MMMM yyyy').format(DateTime.now());
        }
      }
    }
    return DateFormat('MMMM yyyy').format(DateTime.now());
  }

  /// Expense count
  int get _expenseCount => _allExpenses.length;

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: KColors.appSecondary, // Status bar color
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () async {
                        await Future.wait(
                            [_fetchExpenseSummary(), _fetchExpenses()]);
                      },
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 24.0),
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
                            ..._allExpenses
                                .map((expense) => _buildExpenseCard(expense)),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // APP BAR
  // ==========================================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: KColors.appPrimary,
      // AppBar color
      elevation: 0,
      centerTitle: false,
      leading: Container(
        height: 44,
        width: 44,
        margin: const EdgeInsets.only(left: 16),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => Navigator.pop(context),
            highlightColor: Colors.white.withOpacity(0.1), // Standard highlight
            child: const Center(
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ),
      title: Text('Expenses',
          style: KTextStyle.titleLarge
              .copyWith(color: Colors.white, letterSpacing: 0.7, fontSize: 17)),
      actions: [
        _buildAddExpenseButton(),
      ],
    );
  }

  Widget _buildAddExpenseButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 24.0, top: 12, bottom: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: KColors.appPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
          minimumSize: const Size(0, 34),
        ),
        onPressed: _navigateToCreateExpense,
        child: const Text(
          'Add Expense',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.5),
        ),
      ),
    );
  }

  // ==========================================================================
  // TAB BAR
  // ==========================================================================

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabContainer(),
          ),
          const SizedBox(width: 12),
          _buildFilterButton(),
        ],
      ),
    );
  }

  Widget _buildTabContainer() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: KColors.appPrimary),
      ),
      child: Row(
        children: [
          _buildTab(
            index: 0,
            label: 'My Expense',
          ),
          _buildTab(
            index: 1,
            label: 'Team Expense',
          ),
        ],
      ),
    );
  }

  Widget _buildTab({required int index, required String label}) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? KColors.appPrimary : Colors.transparent,
            borderRadius: BorderRadius.only(
              topLeft: index == 0 ? const Radius.circular(20) : Radius.zero,
              bottomLeft: index == 0 ? const Radius.circular(20) : Radius.zero,
              topRight: index == 1 ? const Radius.circular(20) : Radius.zero,
              bottomRight: index == 1 ? const Radius.circular(20) : Radius.zero,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : KColors.appPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.orange, width: 1.5),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.tune, color: Colors.orange, size: 20),
    );
  }

  // ==========================================================================
  // SUMMARY CARD
  // ==========================================================================

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: _isSummaryLoading
          ? const Center(
              child: SizedBox(
                height: 24,
                child: CircularProgressIndicator(),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Expense',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  _currentMonthYear,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _summaryItem(
                        value:
                            _getAmountByStatus('Approved').toStringAsFixed(0),
                        label: 'Approved',
                        color: KColors.greenColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryItem(
                        value: (_getAmountByStatus('Pending RM Approval')
                                    .toInt() +
                                _getAmountByStatus('Pending Finance Approval')
                                    .toInt())
                            .toStringAsFixed(0),
                        label: 'Under Review',
                        color: KColors.orangeColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryItem(
                        value:
                            _getAmountByStatus('Rejected').toStringAsFixed(0),
                        label: 'Rejected',
                        color: KColors.appPrimaryRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: KColors.lightGray),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Expense Submitted",
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                    Text(
                      "₹ ${_totalExpense.toStringAsFixed(0)}",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    )
                  ],
                )
              ],
            ),
    );
  }

  Widget _summaryItem({
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: KColors.lightGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "₹ $value",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 18,
              color: KColors.textGrey,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // EXPENSE CARD
  // ==========================================================================

  Widget _buildExpenseCard(ExpenseRecord expense) {
    final statusColor = expense.expenseStatusColor;
    final isRejected = expense.approvalStatus?.toLowerCase() == 'rejected';
    final isDraft = expense.approvalStatus?.toLowerCase() == 'draft';

    return GestureDetector(
      onTap: () => {
        showDialog(
          context: context,
          builder: (context) => ExpenseDetailDialog(
            id: expense.id,
            title: expense.name,
            statusColor: expense.expenseStatusColor,
            amount: expense.expenseAmount ?? 0.0,
            status: expense.approvalStatus,
            category: expense.expenseType ?? '',
            customer: expense.accountName ?? '',
            date: expense.formattedDate,
            desc: expense.description,
            submittedDate: expense.formattedCreatedDate,
            approvedBy: expense.employeeId,
            rejectedBy: expense.employeeId,
            controller: _controller,
            // Pass the controller
            onEditTap:
                isRejected ? () => _navigateToUpdateExpense(expense) : null,
            onSubmitTap: (isDraft || isRejected)
                ? () => {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Expense approval is currently in progress'),
                          backgroundColor: Colors.orange,
                        ),
                      )
                    } // _showApprovalDialog(expense)
                : null,
          ),
        )
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatusIndicator(statusColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCardHeader(expense, statusColor),
                      const SizedBox(height: 8),
                      const Divider(height: 1, color: KColors.lightGray),
                      const SizedBox(height: 8),
                      _buildCardDetails(expense),
                      const SizedBox(height: 8),
                      const Divider(height: 1, color: KColors.lightGray),
                      const SizedBox(height: 8),
                      _buildCardFooter(expense, isRejected, isDraft)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(int statusColor) {
    return Container(
      width: 4,
      decoration: BoxDecoration(
        color: Color(statusColor),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        ),
      ),
    );
  }

  Widget _buildCardHeader(ExpenseRecord expense, int statusColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            expense.name ?? 'Expense',
            style: TextStyle(
              color: Color(statusColor),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
        _buildStatusBadge(expense, statusColor),
      ],
    );
  }

  Widget _buildStatusBadge(ExpenseRecord expense, int statusColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Color(statusColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        expense.approvalStatus ?? 'Draft',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildCardDetails(ExpenseRecord expense) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _detailRow('Category:', expense.expenseType ?? 'N/A'),
        const SizedBox(height: 4),
        _detailRow('Expense Date:', expense.formattedDate),
        if (expense.hasProject) ...[
          const SizedBox(height: 4),
          _detailRow('Project:', expense.projectName),
        ],
        if (expense.hasAccount) ...[
          const SizedBox(height: 4),
          _detailRow('Account:', expense.accountName),
        ],
      ],
    );
  }

  Widget _buildCardFooter(
      ExpenseRecord expense, bool isRejected, bool isDraft) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Submitted Date : ${expense.formattedCreatedDate}",
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              'Payment: ${expense.modeOfPayment ?? 'N/A'}',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ],
        ),
        _buildAmountBadge(expense.expenseAmount),
      ],
    );
  }

  Widget _buildAmountBadge(double? amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: KColors.appPrimary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '₹ ${amount?.toStringAsFixed(2) ?? '0'}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildActionButtons(ExpenseRecord expense, MonthlyExpenseGroup group) {
    final isDraft = group.status?.toLowerCase() == 'draft';
    final isRejected = group.status?.toLowerCase() == 'reject';

    return Row(
      children: [
        if (isDraft && group.monthlyExpenseId != null)
          Expanded(
            flex: 2,
            child: _buildSubmitButton(expense),
          ),
        if (isDraft || isRejected) const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: _buildEditButton(expense),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(ExpenseRecord expense) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: KColors.appPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      //icon: const Icon(Icons.send_rounded, size: 16),
      label: const Text(
        'Submit for Approval',
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      onPressed: () => _showApprovalDialog(expense),
    );
  }

  Widget _buildEditButton(ExpenseRecord expense) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: KColors.appPrimary,
        side: BorderSide(color: KColors.appPrimary),
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      //icon: const Icon(Icons.edit, size: 16),
      label: const Text(
        'Edit',
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      onPressed: () => _navigateToUpdateExpense(expense),
    );
  }

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    if (status.contains('approve')) return KColors.greenColor;
    if (status.contains('review') || status.contains('draft'))
      return KColors.orangeColor;
    if (status.contains('reject')) return KColors.appPrimaryRed;
    return KColors.grayLight;
  }

  // ==========================================================================
  // NAVIGATION
  // ==========================================================================

  void _navigateToCreateExpense() {
    Navigator.pushNamed(context, '/create_expense')
        .then((_) => _fetchExpenses());
  }

  void _navigateToUpdateExpense(ExpenseRecord expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateExpense(expense: expense),
      ),
    ).then((result) {
      if (result == true) _fetchExpenses();
    });
  }

  // ==========================================================================
  // APPROVAL DIALOG
  // ==========================================================================

  void _showApprovalDialog(ExpenseRecord expense) {
    final commentsController = TextEditingController();
    var isSubmitting = false;
    var expenseId = expense.id;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Submit for Approval',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add a comment for the approver (optional):',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentsController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g. Please approve my travel expenses...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: KColors.appPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      setDialogState(() => isSubmitting = true);
                      final success = await _controller.submitExpenseApproval(
                        context,
                        expenseId,
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
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Submit',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
