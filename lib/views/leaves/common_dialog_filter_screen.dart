import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:time_log/utils/constants/k_colors.dart';

class CommonDialogFilter {
  final String? quickFilter;
  final String? statusFilter;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? project;
  final String? task;

  CommonDialogFilter({
    this.quickFilter,
    this.statusFilter,
    this.fromDate,
    this.toDate,
    this.project,
    this.task,
  });
}

class ReusableFilterDialog {
  static Future<CommonDialogFilter?> showFilterDialog({
    required BuildContext context,
    required String title,
    List<String> quickFilters = const [],
    Map<String, Color> statusFilters = const {},
    String? selectedQuickFilter,
    String? selectedStatusFilter,
    DateTime? fromDate,
    DateTime? toDate,
    String? selectedProject,
    String? selectedTask,
    List<String> projectItems = const [],
    List<String> taskItems = const [],
    bool showProject = false,
    bool showTask = false,
  }) {
    String? _quick = selectedQuickFilter;
    String? _status = selectedStatusFilter;
    DateTime? _from = fromDate;
    DateTime? _to = toDate;
    String? _project = selectedProject;
    String? _task = selectedTask;

    return showDialog<CommonDialogFilter>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
              ),
              child: Dialog(
                backgroundColor: KColors.appColorWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                insetPadding: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.black,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.pop(
                              context,
                              CommonDialogFilter(
                                quickFilter: _quick,
                                statusFilter: _status,
                                fromDate: _from,
                                toDate: _to,
                                project: _project,
                                task: _task,
                              ),
                            ),
                            child: const CircleAvatar(
                              backgroundColor: Color(0xFFF6F4FC),
                              radius: 20,
                              child: Icon(Icons.close,
                                  size: 20, color: Colors.black),
                            ),
                          ),
                        ],
                      ),

                      _divider(),

                      // Quick Filters
                      if (quickFilters.isNotEmpty)
                        _filterSection(
                          title: "Quick Filters",
                          children: quickFilters.map((label) {
                            final isSelected = _quick == label;
                            return customSelectableBox(
                              label: label,
                              isSelected: isSelected,
                              borderColor: Colors.blue,
                              selectedColor: Colors.blue,
                              onTap: () =>
                                  dialogSetState(() => _quick = label),
                            );
                          }).toList(),
                        ),

                      if (quickFilters.isNotEmpty) _divider(),

                      // Status Filters
                      if (statusFilters.isNotEmpty)
                        _filterSection(
                          title: "Status Filters",
                          children: statusFilters.entries.map((entry) {
                            final isSelected = _status == entry.key;
                            return customSelectableBox(
                              label: entry.key,
                              isSelected: isSelected,
                              borderColor: entry.value,
                              selectedColor: entry.value,
                              onTap: () =>
                                  dialogSetState(() => _status = entry.key),
                            );
                          }).toList(),
                        ),

                      if (statusFilters.isNotEmpty) _divider(),

                      // Date Range
                      _timeLogDateRange(
                        context,
                        dialogSetState,
                        _from,
                        _to,
                            (date) => dialogSetState(() => _from = date),
                            (date) => dialogSetState(() => _to = date),
                      ),

                      if (showProject) _divider(),

                      if (showProject)
                        _dropdownFilter(
                          title: "Project",
                          value: _project,
                          items: projectItems,
                          onChanged: (val) =>
                              dialogSetState(() => _project = val),
                          isRequired: true,
                        ),

                      if (showTask) _divider(),

                      if (showTask)
                        _dropdownFilter(
                          title: "Task",
                          value: _task,
                          items: taskItems,
                          onChanged: (val) =>
                              dialogSetState(() => _task = val),
                          isRequired: false,
                        ),

                      const SizedBox(height: 12),

                      // Clear & Apply Buttons
                      Row(
                        children: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: KColors.appPrimary),
                              foregroundColor: KColors.appPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 19, vertical: 2),
                            ),
                            onPressed: () {
                              Navigator.pop(
                                context,
                                CommonDialogFilter(
                                  quickFilter: null,
                                  statusFilter: "All", // ✅ reset to All
                                  fromDate: null,
                                  toDate: null,
                                  project: "Select Project",
                                  task: "Select Task",
                                ),
                              );
                            },
                            child: const Text("Clear Filter"),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () => Navigator.pop(
                              context,
                              CommonDialogFilter(
                                quickFilter: _quick,
                                statusFilter: _status,
                                fromDate: _from,
                                toDate: _to,
                                project: _project,
                                task: _task,
                              ),
                            ),
                            child: const Text("Apply All Filters",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- Helpers ---

  static Widget _filterSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
    );
  }

  static Widget customSelectableBox({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color selectedColor = Colors.blue,
    Color unselectedColor = Colors.white,
    Color borderColor = Colors.blue,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : unselectedColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: isSelected ? Colors.white : borderColor,
          ),
        ),
      ),
    );
  }

  static Widget _timeLogDateRange(
      BuildContext context,
      void Function(void Function()) dialogSetState,
      DateTime? from,
      DateTime? to,
      Function(DateTime picked) onFromPicked,
      Function(DateTime picked) onToPicked,
      ) {
    int dayDiff = (from != null && to != null)
        ? to.difference(from).inDays.abs() + 1
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Date Range Filter",
            style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F4FC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // From Date
              Expanded(
                child: Column(
                  children: [
                    const Text("From Date",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: from ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          dialogSetState(() => onFromPicked(picked));
                        }
                      },
                      child: Text(
                        from != null
                            ? DateFormat("dd MMM, yyyy").format(from)
                            : "Select From Date",
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Day Counter
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: KColors.appColorWhite,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${dayDiff.toString().padLeft(2, "0")} Day",
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w600),
                ),
              ),

              // To Date
              Expanded(
                child: Column(
                  children: [
                    const Text("To Date",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: to ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          dialogSetState(() => onToPicked(picked));
                        }
                      },
                      child: Text(
                        to != null
                            ? DateFormat("dd MMM, yyyy").format(to)
                            : "Select To Date",
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _dropdownFilter({
    required String title,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((e) =>
              DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  /// Apply filters on a given list of items
  static List<T> applyFilters<T>({
    required List<T> originalList,
    required CommonDialogFilter filters,
    required DateTime Function(T) getDate, // how to extract date from T
    required String Function(T) getStatus, // how to extract status from T
  }) {
    return originalList.where((item) {
      final itemDate = getDate(item);
      final itemStatus = getStatus(item);

      // 1. Status Filter
      if (filters.statusFilter != null &&
          filters.statusFilter != "All" &&
          itemStatus != filters.statusFilter) {
        return false;
      }

      // 2. Date Range Filter
      if (filters.fromDate != null &&
          filters.toDate != null &&
          (itemDate.isBefore(filters.fromDate!) ||
              itemDate.isAfter(filters.toDate!))) {
        return false;
      }

      return true;
    }).toList();
  }


  static Widget _divider() =>
      const Divider(color: Color(0x1A5C5C5C), thickness: 1);
}


