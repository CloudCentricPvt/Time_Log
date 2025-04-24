import 'package:flutter/material.dart';

import '../constants/k_colors.dart';
import '../constants/k_date_dialog.dart';

class FilterDialog {
  static void showTimeLogFilterDialog(
      BuildContext context,
      List<String> projectItems,
      String? selectedProject,

      String? selectedTask,
      List<String> taskItems,
      Function(String?) onProjectChanged,
      Function(String?) onTaskChanged,
      ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                          style: TextStyle(fontSize: 21, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
                _divider(),
                _sectionTitle('Quick Filters'),
                _quickFilters(),
                _divider(),
                _sectionTitle('Status Filters'),
                _statusFilters(),
                _divider(),
                _sectionTitle('Date Range Filters'),
                _dateRangeFilterCard(),
                _divider(),
                _sectionTitle('Project Filters'),
                _projectSelectCard(
                  selectedProject: selectedProject,
                  projectItems: projectItems,
                  onChanged: onProjectChanged,
                ),
                _divider(),
                _sectionTitle('Task Filters'),
                _selectTaskCard(
                  selectedTask: selectedTask,
                  taskItems: taskItems,
                  onChanged: onProjectChanged,
                ), // you can customize it similarly if needed
                _divider(),
                _applyFiltersButton(context),
              ],
            ),
          ),
        );
      },
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

  static Widget _quickFilters() => Column(
    children: [
      Row(
        children: [
          _roundedRectangularBox(text: "This Week", textColor: Colors.blue, borderColor: Colors.blue),
          SizedBox(width: 10),
          _roundedRectangularBox(text: "Last Week", textColor: Colors.blue, borderColor: Colors.blue),
          SizedBox(width: 10),
          _roundedRectangularBox(text: "This Month", textColor: Colors.blue, borderColor: Colors.blue),
        ],
      ),
      Row(
        children: [
          _roundedRectangularBox(text: "Last Month", textColor: Colors.blue, borderColor: Colors.blue),
          SizedBox(width: 10),
          _roundedRectangularBox(text: "This Year", textColor: Colors.blue, borderColor: Colors.blue),
        ],
      ),
    ],
  );

  static Widget _statusFilters() => Row(
    children: [
      _roundedRectangularBox(text: "Pending", textColor: Colors.orange, borderColor: Colors.orange),
      SizedBox(width: 10),
      _roundedRectangularBox(text: "Approved", textColor: Colors.green, borderColor: Colors.green),
      SizedBox(width: 10),
      _roundedRectangularBox(text: "Rejected", textColor: Colors.red, borderColor: Colors.red),
    ],
  );

  static Widget _dateRangeFilterCard() => Wrap(
    spacing: 10,
    children: [
      SizedBox(
        height: 100,
        width: 500,
        child: Card(
          color: Color(0xFFd8d8d8),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _dateColumn('From Date', 'Select From Date'),
                _dayCountCard('00 Day'),
                _dateColumn('To Date', 'Select To Date'),
              ],
            ),
          ),
        ),
      ),
    ],
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

  static Widget _applyFiltersButton(BuildContext context) => Row(
    children: [
      _roundedRectangularBox(text: "Pending", textColor: Colors.blue, borderColor: Colors.blue),
      Spacer(),
      SizedBox(
        width: 140,
        height: 30,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
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

  static Widget _projectSelectCard({required String? selectedProject, required List<String> projectItems, required Function(String?) onChanged,}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DropdownButtonFormField<String>(
        value: selectedProject,
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          label: RichText(
            text: TextSpan(
              text: 'Project',
              style: TextStyle(color: Colors.black, fontSize: 15),
              children: [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red, fontSize: 17),
                ),
              ],
            ),
          ),
          hintText: "Select Project",
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black26),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black26),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(width: 1, color: Colors.black54),
          ),
        ),
        dropdownColor: Colors.white,
        icon: const Icon(Icons.keyboard_arrow_down),
        items: projectItems.map<DropdownMenuItem<String>>((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
  static Widget _selectTaskCard({required String? selectedTask, required List<String> taskItems, required Function(String?) onChanged,}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DropdownButtonFormField<String>(
        value: selectedTask,
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          label: RichText(
            text: TextSpan(
              text: 'Task',
              style: TextStyle(color: Colors.black, fontSize: 15),
              children: [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red, fontSize: 17),
                ),
              ],
            ),
          ),
          hintText: "Select Task",
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black26),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black26),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(width: 1, color: Colors.black54),
          ),
        ),
        dropdownColor: Colors.white,
        icon: const Icon(Icons.keyboard_arrow_down),
        items: taskItems.map<DropdownMenuItem<String>>((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }



  static Widget _roundedRectangularBox({
    required String text,
    required Color textColor,
    required Color borderColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SizedBox(
        height: 32,
        width: 84,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
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
