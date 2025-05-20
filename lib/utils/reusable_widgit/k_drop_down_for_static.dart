import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../constants/k_colors.dart';

enum DropdownIconType { arrowDown, chevronDown }

class KDropdownFieldForStatic extends StatefulWidget {
  final String? title;
  final String? hint;
  final List<Map<String, String>> leaveTypes; // Change this to accept a list of maps with icons, labels, and values
  final String? value;
  final Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final bool isRequired;
  final double? fontSize;
  final FontWeight? fontWeight;
  final DropdownIconType dropdownIconType; // New parameter

  const KDropdownFieldForStatic({
    super.key,
    this.title,
    this.hint,
    required this.leaveTypes,
    this.value,
    this.onChanged,
    this.validator,
    this.isRequired = false,
    this.fontSize,
    this.fontWeight,
    this.dropdownIconType = DropdownIconType.arrowDown, // Default icon
  });

  @override
  _KDropdownFieldState createState() => _KDropdownFieldState();
}

class _KDropdownFieldState extends State<KDropdownFieldForStatic> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Text(
            widget.title!,
            style: TextStyle(
              fontSize: widget.fontSize ?? 14,
              fontWeight: widget.fontWeight ?? FontWeight.bold,
            ),
          ),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: widget.value,
          hint: Text(widget.hint ?? 'Select Leave Type'),
          onChanged: widget.onChanged,
          items: widget.leaveTypes.map((leaveType) {
            return DropdownMenuItem<String>(
              value: leaveType['value'],
              child: Row(
                children: [
                  if (leaveType['icon'] != null)
                    SvgPicture.asset(
                      leaveType['icon']!,
                      height: 20,
                      width: 20,
                    ),
                  const SizedBox(width: 8),
                  Text(leaveType['label']!),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}


/// ----
class KDropdownFieldForStaticWithIcon extends StatelessWidget {
  final List<Map<String, String>> leaveTypes;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String title;


  const KDropdownFieldForStaticWithIcon({
    Key? key,
    required this.leaveTypes,
    required this.value,
    required this.onChanged,
    this.title = 'Leave Type',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        label: RichText(
          text: TextSpan(
            text: title ?? '',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 12,
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        contentPadding: const EdgeInsets.only(left: 20,),
      ),

      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: const Text("Select Leave Type"),
          icon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Icon(Icons.keyboard_arrow_down_outlined),
          ), // 👈 Inbuilt Material icon
          items: leaveTypes.map((leaveType) {
            return DropdownMenuItem<String>(
              value: leaveType['value'],
              child: Row(
                children: [
                  if (leaveType['icon'] != null)
                    SvgPicture.asset(leaveType['icon']!, height: 20, width: 20),
                  const SizedBox(width: 8),
                  Text(leaveType['label']!),
                ],
              ),
            );
          }).toList(),
          selectedItemBuilder: (BuildContext context) {
            return leaveTypes.map((e) {
              return Row(
                children: [
                  if (e['icon'] != null)
                    SvgPicture.asset(e['icon']!, height: 20, width: 20),
                  const SizedBox(width: 8),
                  Text(e['label'] ?? ''),
                ],
              );
            }).toList();
          },
          onChanged: onChanged,
        ),

        /* DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: const Text("Select Leave Type"),
          items: leaveTypes.map((leaveType) {
            return DropdownMenuItem<String>(
              value: leaveType['value'],
              child: Row(
                children: [
                  if (leaveType['icon'] != null)
                    SvgPicture.asset(leaveType['icon']!, height: 20, width: 20),
                  const SizedBox(width: 8),
                  Text(leaveType['label']!),
                ],
              ),
            );
          }).toList(),
          selectedItemBuilder: (BuildContext context) {
            return leaveTypes.map((e) {
              return Row(
                children: [
                  if (e['icon'] != null)
                    SvgPicture.asset(e['icon']!, height: 20, width: 20),
                  const SizedBox(width: 8),
                  Text(e['label'] ?? ''),
                ],
              );
            }).toList();
          },
          onChanged: onChanged,
        ),*/
      ),
    );
  }
}
