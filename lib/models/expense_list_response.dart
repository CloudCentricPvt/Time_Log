// expense_models.dart
// Complete data models for Salesforce Expense API response

import 'dart:convert';
import '../network/salesforce_api_service.dart';

// ============================================================================
// EXPENSE LIST RESPONSE
// ============================================================================

/// Root response from Salesforce query
class ExpenseListResponse {
  final int totalSize;
  final bool done;
  final List<ExpenseRecord> records;

  ExpenseListResponse({
    required this.totalSize,
    required this.done,
    required this.records,
  });

  factory ExpenseListResponse.fromJson(Map<String, dynamic> json) {
    return ExpenseListResponse(
      totalSize: json['totalSize'] ?? 0,
      done: json['done'] ?? true,
      records: (json['records'] as List?)
          ?.map((e) => ExpenseRecord.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  factory ExpenseListResponse.fromSalesforceQuery(SalesforceQueryResponse response) {
    return ExpenseListResponse(
      totalSize: response.totalSize,
      done: response.done,
      records: response.records.map((json) => ExpenseRecord.fromJson(json)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSize': totalSize,
      'done': done,
      'records': records.map((e) => e.toJson()).toList(),
    };
  }

  /// Get total expense amount
  double get totalExpenseAmount {
    return records.fold(
      0.0,
          (sum, record) => sum + (record.expenseAmount ?? 0.0),
    );
  }

  /// Get expenses grouped by expense type
  Map<String, List<ExpenseRecord>> get groupByExpenseType {
    final Map<String, List<ExpenseRecord>> grouped = {};
    for (final record in records) {
      final type = record.expenseType ?? 'Unknown';
      grouped.putIfAbsent(type, () => []);
      grouped[type]!.add(record);
    }
    return grouped;
  }

  /// Get expenses grouped by month (based on expense date)
  Map<String, List<ExpenseRecord>> get groupByMonth {
    final Map<String, List<ExpenseRecord>> grouped = {};
    for (final record in records) {
      final date = record.expenseDate;
      if (date != null && date.isNotEmpty) {
        final monthKey = date.length >= 7 ? date.substring(0, 7) : date;
        grouped.putIfAbsent(monthKey, () => []);
        grouped[monthKey]!.add(record);
      }
    }
    return grouped;
  }

  /// Get expenses grouped by monthly expense ID
  Map<String, List<ExpenseRecord>> get groupByMonthlyExpense {
    final Map<String, List<ExpenseRecord>> grouped = {};
    for (final record in records) {
      final id = record.monthlyExpenseId ?? 'Unassigned';
      grouped.putIfAbsent(id, () => []);
      grouped[id]!.add(record);
    }
    return grouped;
  }

  /// Get total amount by expense type
  Map<String, double> get totalByExpenseType {
    final Map<String, double> totals = {};
    for (final record in records) {
      final type = record.expenseType ?? 'Unknown';
      totals[type] = (totals[type] ?? 0.0) + (record.expenseAmount ?? 0.0);
    }
    return totals;
  }

  /// Get expenses for a specific month
  List<ExpenseRecord> getExpensesForMonth(int month, int year) {
    final monthStr = month.toString().padLeft(2, '0');
    return records.where((record) {
      final date = record.expenseDate;
      if (date == null || date.isEmpty) return false;
      return date.startsWith('$year-$monthStr');
    }).toList();
  }

  /// Get expenses for a specific expense type
  List<ExpenseRecord> getExpensesByType(String type) {
    return records
        .where((record) => record.expenseType?.toLowerCase() == type.toLowerCase())
        .toList();
  }
}

// ============================================================================
// EXPENSE RECORD
// ============================================================================

/// Individual expense record
class ExpenseRecord {
  final String id;
  final String? name;
  final String? approvalStatus;
  final String? expenseType;
  final bool? hasReceipt;
  //final String? expenseCategory;
  final double? expenseAmount;
  final String? description;
  final String? createdDate;
  final String? expenseDate;
  final String? modeOfPayment;
  final String? modeOfTravel;
  final Employee? employee;
  final Project? project;
  final MonthlyExpense? monthlyExpense;
  final Account? account;
  final CreatedBy? createdBy;
  final Attributes? attributes;

  ExpenseRecord({
    required this.id,
    this.name,
    this.approvalStatus,
    this.expenseType,
    this.hasReceipt,
    //this.expenseCategory,
    this.expenseAmount,
    this.description,
    this.createdDate,
    this.expenseDate,
    this.modeOfPayment,
    this.modeOfTravel,
    this.employee,
    this.project,
    this.monthlyExpense,
    this.account,
    this.createdBy,
    this.attributes,
  });

  factory ExpenseRecord.fromJson(Map<String, dynamic> json) {
    return ExpenseRecord(
      id: json['Id'] ?? '',
      name: json['Name'],
      approvalStatus: json['Approval_Status__c'],
      expenseType: json['Expense_Type__c'],
      hasReceipt: json['Do_you_have_an_expense_Receipt__c'],
      //expenseCategory: json['Expense_Category__c'],
      expenseAmount: (json['Expense_Amount__c'] as num?)?.toDouble(),
      description: json['Description__c'],
      createdDate: json['CreatedDate'],
      expenseDate: json['Expense_Date__c'],
      modeOfPayment: json['Mode_of_Payment__c'],
      modeOfTravel: json['Mode_of_Travel__c'],
      employee: json['Employee__r'] != null
          ? Employee.fromJson(json['Employee__r'])
          : null,
      project: json['Project__r'] != null
          ? Project.fromJson(json['Project__r'])
          : null,
      monthlyExpense: json['Monthly_Expense__r'] != null
          ? MonthlyExpense.fromJson(json['Monthly_Expense__r'])
          : null,
      account: json['Account__r'] != null
          ? Account.fromJson(json['Account__r'])
          : null,
      createdBy: json['CreatedBy'] != null
          ? CreatedBy.fromJson(json['CreatedBy'])
          : null,
      attributes: json['attributes'] != null
          ? Attributes.fromJson(json['attributes'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'Approval_Status__c': approvalStatus,
      'Expense_Type__c': expenseType,
      'Do_you_have_an_expense_Receipt__c': hasReceipt,
      //'Expense_Category__c': expenseCategory,
      'Expense_Amount__c': expenseAmount,
      'Description__c': description,
      'CreatedDate': createdDate,
      'Expense_Date__c': expenseDate,
      'Mode_of_Payment__c': modeOfPayment,
      'Mode_of_Travel__c': modeOfTravel,
      'Employee__r': employee?.toJson(),
      'Project__r': project?.toJson(),
      'Monthly_Expense__r': monthlyExpense?.toJson(),
      'Account__r': account?.toJson(),
      'CreatedBy': createdBy?.toJson(),
      'attributes': attributes?.toJson(),
    };
  }

  // ==========================================================================
  // UTILITY METHODS
  // ==========================================================================

  ///
  bool get hasAnyReceipt => hasReceipt == true;

  /// Check if expense has an account associated
  bool get hasAccount => account != null;

  /// Check if expense has a project associated
  bool get hasProject => project != null;

  /// Check if expense has a monthly expense associated
  bool get hasMonthlyExpense => monthlyExpense != null;

  /// Get employee ID
  String get employeeId => employee?.id ?? '';

  /// Get employee name
  String get employeeName => employee?.name ?? '';

  /// Get monthly expense ID
  String get monthlyExpenseId => monthlyExpense?.id ?? '';

  /// Get monthly expense name
  String get monthlyExpenseName => monthlyExpense?.name ?? '';

  /// Get account ID
  String get accountId => account?.id ?? '';

  /// Get account name
  String get accountName => account?.name ?? '';

  /// Get project ID
  String get projectId => project?.id ?? '';

  /// Get project name
  String get projectName => project?.name ?? '';

  /// Get formatted amount with currency symbol
  String get formattedAmount {
    if (expenseAmount == null) return '₹0.00';
    return '₹${expenseAmount!.toStringAsFixed(2)}';
  }

  /// Get display name
  String get displayName => name ?? 'EXP-${id.substring(0, 6)}';

  /// Get expense date formatted for display
  String get formattedDate {
    if (expenseDate == null || expenseDate!.isEmpty) return 'N/A';
    try {
      final parts = expenseDate!.split('-');
      if (parts.length == 3) {
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        return '${parts[2]} ${months[int.parse(parts[1]) - 1]} ${parts[0]}';
      }
      return expenseDate!;
    } catch (e) {
      return expenseDate!;
    }
  }

  /// Get created date formatted for display
  String get formattedCreatedDate {
    if (createdDate == null || createdDate!.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(createdDate!).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${date.day.toString().padLeft(2, '0')} '
          '${months[date.month - 1]}, ${date.year}';
    } catch (e) {
      return createdDate!;
    }
  }

  /// Get expense type with emoji icon
  String get expenseTypeWithIcon {
    switch (expenseType?.toLowerCase()) {
      case 'travel':
        return '✈️ Travel';
      case 'food':
        return '🍽️ Food';
      case 'accommodation':
        return '🏨 Accommodation';
      case 'miscellaneous':
        return '📦 Miscellaneous';
      default:
        return expenseType ?? '📋 Unknown';
    }
  }

  /// Get color for expense type
  int get expenseTypeColor {
    switch (expenseType?.toLowerCase()) {
      case 'travel':
        return 0xFF2196F3; // Blue
      case 'food':
        return 0xFFFF9800; // Orange
      case 'accommodation':
        return 0xFF9C27B0; // Purple
      case 'miscellaneous':
        return 0xFF607D8B; // Blue Grey
      default:
        return 0xFF9E9E9E; // Grey
    }
  }

  int get expenseStatusColor {
    switch (approvalStatus?.toLowerCase()) {
      case 'pending rm approval':
        return 0xFFFF9538; // Orange
      case 'pending finance approval':
        return 0xFFFF9538; // Orange
      case 'approved':
        return 0xFF00CA7C; // Green
      case 'rejected':
        return 0xFFFF3859; // Red
      default:
        return 0xFF5C5C5C; // Grey
    }
  }
}

// ============================================================================
// RELATED OBJECTS
// ============================================================================

/// Employee (Employee__r)
class Employee {
  final String id;
  final String name;
  final Attributes? attributes;

  Employee({
    required this.id,
    required this.name,
    this.attributes,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['Id'] ?? '',
      name: json['Name'] ?? '',
      attributes: json['attributes'] != null
          ? Attributes.fromJson(json['attributes'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'attributes': attributes?.toJson(),
    };
  }
}

/// Project (Project__r)
class Project {
  final String id;
  final String name;
  final Attributes? attributes;

  Project({
    required this.id,
    required this.name,
    this.attributes,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['Id'] ?? '',
      name: json['Name'] ?? '',
      attributes: json['attributes'] != null
          ? Attributes.fromJson(json['attributes'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'attributes': attributes?.toJson(),
    };
  }
}

/// Monthly Expense (Monthly_Expense__r)
class MonthlyExpense {
  final String id;
  final String name;
  final Attributes? attributes;

  MonthlyExpense({
    required this.id,
    required this.name,
    this.attributes,
  });

  factory MonthlyExpense.fromJson(Map<String, dynamic> json) {
    return MonthlyExpense(
      id: json['Id'] ?? '',
      name: json['Name'] ?? '',
      attributes: json['attributes'] != null
          ? Attributes.fromJson(json['attributes'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'attributes': attributes?.toJson(),
    };
  }
}

/// Account (Account__r)
class Account {
  final String id;
  final String name;
  final Attributes? attributes;

  Account({
    required this.id,
    required this.name,
    this.attributes,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['Id'] ?? '',
      name: json['Name'] ?? '',
      attributes: json['attributes'] != null
          ? Attributes.fromJson(json['attributes'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'attributes': attributes?.toJson(),
    };
  }
}

// ============================================================================
// CREATED BY
// ============================================================================

/// User who created the record
class CreatedBy {
  final String id;
  final String name;
  final Attributes? attributes;

  CreatedBy({
    required this.id,
    required this.name,
    this.attributes,
  });

  factory CreatedBy.fromJson(Map<String, dynamic> json) {
    return CreatedBy(
      id: json['Id'] ?? '',
      name: json['Name'] ?? '',
      attributes: json['attributes'] != null
          ? Attributes.fromJson(json['attributes'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'attributes': attributes?.toJson(),
    };
  }
}

// ============================================================================
// ATTRIBUTES
// ============================================================================

/// Salesforce object attributes
class Attributes {
  final String type;
  final String url;

  Attributes({
    required this.type,
    required this.url,
  });

  factory Attributes.fromJson(Map<String, dynamic> json) {
    return Attributes(
      type: json['type'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'url': url,
    };
  }
}

// ============================================================================
// EXPENSE SUMMARY
// ============================================================================

/// Summary statistics for expenses
class ExpenseSummary {
  final int totalCount;
  final double totalAmount;
  final Map<String, double> amountByType;
  final Map<String, int> countByType;
  final double averageAmount;
  final double maxAmount;
  final double minAmount;

  ExpenseSummary({
    required this.totalCount,
    required this.totalAmount,
    required this.amountByType,
    required this.countByType,
    required this.averageAmount,
    required this.maxAmount,
    required this.minAmount,
  });

  factory ExpenseSummary.fromRecords(List<ExpenseRecord> records) {
    final amountByType = <String, double>{};
    final countByType = <String, int>{};

    double total = 0.0;
    double max = 0.0;
    double min = double.infinity;

    for (final record in records) {
      final type = record.expenseType ?? 'Unknown';
      final amount = record.expenseAmount ?? 0.0;

      amountByType[type] = (amountByType[type] ?? 0.0) + amount;
      countByType[type] = (countByType[type] ?? 0) + 1;

      total += amount;
      if (amount > max) max = amount;
      if (amount < min && amount > 0) min = amount;
    }

    return ExpenseSummary(
      totalCount: records.length,
      totalAmount: total,
      amountByType: amountByType,
      countByType: countByType,
      averageAmount: records.isEmpty ? 0.0 : total / records.length,
      maxAmount: records.isEmpty ? 0.0 : max,
      minAmount: records.isEmpty ? 0.0 : (min == double.infinity ? 0.0 : min),
    );
  }
}