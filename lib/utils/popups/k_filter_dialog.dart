import 'package:flutter/material.dart';

import '../../models/wfh_history_res.dart';
import '../constants/k_colors.dart';
import '../constants/k_date_dialog.dart';

class FilterDialog {
  static Future<WfhFilters?> showTimeLogFilterDialog(BuildContext context,
      List<String> projectItems,
      String? selectedProject,
      String? selectedTask,
      List<String> taskItems,
      Function(String?) onProjectChanged,
      Function(String?) onTaskChanged,) {
    WfhFilters filters = WfhFilters();
    return showDialog<WfhFilters>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(21.0),
              child: Dialog(
                backgroundColor: KColors.appColorWhite,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
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
                            'Time Log Filters',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Text(
                                'X',
                                style: TextStyle(
                                    fontSize: 21, color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                      _divider(),
                      SizedBox(height: 10,),
                      _sectionTitle('Quick Filters'),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (var q in [
                            'This Week',
                            'Last Week',
                            'This Month',
                            'Last Month',
                            'This Year'
                          ])
                              customDialogFilterChip(
                                label: q,
                                selected: filters.quickFilter == q,
                                onSelected: (_) {
                                  setState(() {
                                    filters.quickFilter = q;
                                  });
                                },
                                color: KColors.appPrimary,
                              )

                        ],
                      ),
                      _divider(),
                      _sectionTitle('Status Filters'),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (var s in ['Pending', 'Approved', 'Rejected'])
                            customDialogFilterChip(
                              label: s,
                              selected: filters.statusFilter == s,
                              onSelected: (_) {
                                setState(() {
                                  filters.statusFilter = s;
                                });
                              },
                              color: KColors.appPrimary,
                            ),
                        ],
                      ),
                      _divider(),
                      _sectionTitle('Date Range Filters'),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setState(() {
                                    filters.fromDate = picked;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  filters.fromDate == null
                                      ? "Select From Date"
                                      : "${filters.fromDate!.day} ${_monthName(
                                      filters.fromDate!.month)} ${filters
                                      .fromDate!.year}",
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setState(() {
                                    filters.toDate = picked;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  filters.toDate == null
                                      ? "Select To Date"
                                      : "${filters.toDate!.day} ${_monthName(
                                      filters.toDate!.month)} ${filters.toDate!
                                      .year}",
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      _divider(),
                      _applyFiltersButton(context, filters),
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

  static String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
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
          color: selected ? Colors.white : color,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: selected,
      onSelected: onSelected,
      selectedColor: color,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color, width: 1.5),
      ),
    );
  }





  static Widget _divider() => Divider(color: Color(0x1A5C5C5C), thickness: 1);

  static Widget _sectionTitle(String text) => Text(
    text,
    style: TextStyle(
      color: Colors.black,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w500,
    ),
  );


  static Widget _dateColumn(String title, String subtitle) => GestureDetector(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, color: Colors.black)),
        Text(subtitle, style: TextStyle(color: Colors.blue, fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
      ],
    ),
    onTap: (){

    },
  );

  static Widget _dayCountCard(String text) => DecoratedBox(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        text,
        style: TextStyle(color: Colors.red, fontFamily: 'Poppins', fontWeight: FontWeight.w500),
      ),
    ),
  );


  static Widget _applyFiltersButton(BuildContext context, WfhFilters filters) => Row(
    children: [
      _roundedRectangularBox(text: "Pending", textColor: Colors.blue, borderColor: Colors.blue),
      Spacer(),
      SizedBox(
        width: 140,
        height: 30,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context,filters);
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: KColors.appPrimary,
          ),
          child: Text(
            'Apply All Filters',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: 11,
            ),
          ),
        ),
      ),
    ],
  );




  static Widget _roundedRectangularBox({
    required String text,
    required Color textColor,
    required Color borderColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SizedBox(
        width: 79,
        height: 30,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  color: textColor,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
