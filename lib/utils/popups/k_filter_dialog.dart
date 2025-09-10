import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/wfh_history_res.dart';
import '../constants/k_colors.dart';
import '../constants/k_date_dialog.dart';

class FilterDialog {
  static Future<WfhFilters?> showTimeLogFilterDialog(
    BuildContext context,
      String? selectedQuickFilter,
      String? selectedStatusFilter,
      DateTime? fromDate,
      DateTime? toDate,
      String? selectedProject,
      String? selectedTask,
  ) {
    String? _quick = selectedQuickFilter;
    String? _status = selectedStatusFilter;
    DateTime? _from = fromDate;
    DateTime? _to = toDate;
    String? _project = selectedProject;
    String? _task = selectedTask;
    WfhFilters filters = WfhFilters();
    return showDialog<WfhFilters>(
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
                    borderRadius: BorderRadius.circular(12)),
                insetPadding: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Request WFH History Filters',
                            style: TextStyle(
                              color: KColors.appBlackColor,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.pop(
                                context,  WfhFilters(
                              quickFilter: _quick,
                              statusFilter: _status,
                              fromDate: _from,
                              toDate: _to,
                              project: _project,
                              task: _task,
                            ),
                            ),
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: KColors.appColorWhite,
                              ),
                              child: const CircleAvatar(
                                backgroundColor: Color(0xFFF6F4FC),
                                radius: 20,
                                child: Icon(Icons.close,
                                    size: 22, color: KColors.appBlackColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                      _divider(),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      _filterSection(
                        title: "Quick Filters",
                        children: [
                          "This Week",
                          "Last Week",
                          "This Month",
                          "Last Month",
                          "this year"
                        ].map((label) {
                          final isSelected = _quick == label;
                          return customSelectableBox(
                            label: label,
                            isSelected: isSelected,
                            borderColor: KColors.appPrimary,
                            selectedColor:KColors.appPrimary,
                            onTap: () => dialogSetState((){
                              _quick = (_quick == label) ? null : label;
                            }),
                          );
                        }).toList(),
                      ),

                      const Divider(color: Color(0x1A5C5C5C)),

                      _filterSection(
                        title: "Status Filters",
                        children: {
                          "Pending": KColors.orangeColor,
                          "Approved": KColors.greenColor,
                          "Rejected": KColors.appPrimaryRed,
                        }.entries.map((entry) {
                          final isSelected = _status == entry.key;
                          return customSelectableBox(
                            label: entry.key,
                            isSelected: isSelected,
                            borderColor: entry.value,
                            selectedColor: entry.value,
                            onTap: () =>
                                dialogSetState((){
                                  _status = (_status == entry.key) ? null : entry.key;
                                }),
                          );
                        }).toList(),
                      ),

                      const Divider(color: Color(0x1A5C5C5C)),

                      _timeLogDateRange(
                        context,
                        dialogSetState,
                        _from,
                        _to,
                            (date) => dialogSetState(() => _from = date),
                            (date) => dialogSetState(() => _to = date),
                      ),

                      const Divider(color: Color(0x1A5C5C5C)),


                      _divider(),
                      // Buttons clear and apply all
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
                              dialogSetState(() {
                                _quick = null;
                                _status = null;
                                _from = null;
                                _to = null;
                                _project = null;
                                _task = null;
                                selectedQuickFilter = null;
                                selectedStatusFilter = null;
                                selectedProject = null;
                                selectedTask = null;
                              });
                            },
                            child: const Text("Clear Filter"),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: KColors.appPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context,
                              WfhFilters(
                                quickFilter: _quick,
                                statusFilter: _status,
                                fromDate: _from,
                                toDate: _to,
                                project: _project,
                                task: _task,
                              ),
                            ),
                            child: const Text("Apply All Filters",
                                style: TextStyle(color: KColors.appColorWhite)),
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


  static Widget _filterSection(
      {required String title, required List<Widget> children}) {
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
    Color selectedColor = KColors.appPrimary,
    Color unselectedColor = KColors.appColorWhite,
    Color borderColor = KColors.appPrimary,
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
            color: isSelected ? KColors.appColorWhite : borderColor,
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
        const Text(
          "Date Range Filter",
          style: TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:Color(0xFFF6F4FC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("From Date",
                        style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
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
                          color:KColors.appPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// Day Counter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: KColors.appColorWhite,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${dayDiff.toString().padLeft(2, "0")} Day",
                  style: const TextStyle(
                      color: KColors.appPrimaryRed, fontWeight: FontWeight.w600),
                ),
              ),

              /// To Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("To Date",
                        style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
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
                          color: KColors.appPrimary,
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


  static Widget customDialogFilterChip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
    required Color color,
  }) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? KColors.appColorWhite : color,
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
      selected: selected,
      showCheckmark: false,
      onSelected: onSelected,
      selectedColor: color,
      backgroundColor: KColors.appColorWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color, width: 1),
      ),
    );
  }

  static Widget _divider() => Divider(color: Color(0x1A5C5C5C), thickness: 1);

}
