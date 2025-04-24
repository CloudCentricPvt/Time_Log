import 'package:flutter/material.dart';
import '../constants/k_colors.dart';

enum DropdownIconType { arrowDown, chevronDown }

class KDropdownField extends StatefulWidget {
  final String? title;
  final String? hint;
  final List<String> leaveTypes;
  final String? value;
  final Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final bool isRequired;
  final double? fontSize;
  final FontWeight? fontWeight;
  final DropdownIconType dropdownIconType; // New parameter

  const KDropdownField({
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

class _KDropdownFieldState extends State<KDropdownField> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        label: widget.isRequired
            ? RichText(
          text: TextSpan(
            text: widget.title ?? "Leave Type",
            style: TextStyle(
              fontWeight: widget.fontWeight ?? FontWeight.w500,
              fontSize: widget.fontSize ?? 16.0,
              fontFamily: 'Poppins',
              color: KColors.appSecondaryGrey,
            ),
            children: const [
              TextSpan(
                text: " *",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        )
            : Text(
          widget.title ?? "Leave Type",
          style: TextStyle(
            fontWeight: widget.fontWeight ?? FontWeight.w500,
            fontSize: widget.fontSize ?? 16.0,
            fontFamily: 'Poppins',
            color: KColors.appSecondaryGrey,
          ),
        ),
        contentPadding: const EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: KColors.colorGray,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: Colors.blue,
            width: 1.0,
          ),
        ),
      ),
      hint: widget.hint != null
          ? Text(
        widget.hint!,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: widget.fontWeight ?? FontWeight.w400,
          fontSize: widget.fontSize ?? 14.0,
          color: KColors.appSecondaryGrey,
        ),
      )
          : null, // Use hint inside DropdownButtonFormField
      value: widget.value != "" ? widget.value : null, // Ensure null for hint to show
      items: widget.leaveTypes.map((String type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(
            type,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: widget.fontWeight ?? FontWeight.w400,
              fontSize: widget.fontSize ?? 14.0,
            ),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (widget.onChanged != null) {
          widget.onChanged!(newValue);
        }
      },
      validator: widget.validator ??
          (widget.isRequired
              ? (value) => value == null ? "This field is required" : null
              : null),
      icon: widget.dropdownIconType == DropdownIconType.arrowDown
          ? const Icon(Icons.arrow_drop_down, color: Colors.black, size: 24)
          : const Icon(Icons.expand_more, color: Colors.black, size: 24), // Use chevronDown icon
    );
  }
}
