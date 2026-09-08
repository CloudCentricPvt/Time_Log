import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import '../constants/k_colors.dart';

enum DropdownIconType {
  arrowDown,
  chevronDown,
}

/*class KDropdownField<T> extends StatefulWidget {
  final String? title;
  final String? hint;
  final List<T> leaveTypes;
  final T? value;
  final Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool isRequired;
  final double? fontSize;
  final FontWeight? fontWeight;
  final DropdownIconType dropdownIconType;
  final String Function(T) getLabel;

  const KDropdownField({
    super.key,
    this.title,
    this.hint,
    required this.leaveTypes,
    required this.getLabel,
    this.value,
    this.onChanged,
    this.validator,
    this.isRequired = false,
    this.fontSize,
    this.fontWeight,
    this.dropdownIconType = DropdownIconType.arrowDown,
  });

  @override
  State<KDropdownField<T>> createState() => _KDropdownFieldState<T>();
}*/

/*class _KDropdownFieldState<T> extends State<KDropdownField<T>> {
  @override
  Widget build(BuildContext context) {
    return DropdownSearch<T>(
      items: widget.leaveTypes,
      selectedItem: widget.value,
      onChanged: widget.onChanged,
      validator: widget.validator ??
          (widget.isRequired
              ? (value) => value == null ? "This field is required" : null
              : null),
      itemAsString: (T item) => widget.getLabel(item),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        fit: FlexFit.loose,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: "Search ${widget.title ?? 'Leave Type'}...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
      ),
      dropdownButtonProps: DropdownButtonProps(
        icon: Icon(Icons.keyboard_arrow_down_outlined, color: Colors.black),
      ),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          label: widget.isRequired
              ? RichText(
                  text: TextSpan(
                    text: widget.title ?? "Leave Type",
                    style: TextStyle(
                      fontWeight: widget.fontWeight ?? FontWeight.w500,
                      fontSize: widget.fontSize ?? 16.0,
                      fontFamily: 'Poppins',
                      color: Colors.grey,
                    ),
                    children: const [
                      TextSpan(
                        text: " *",
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
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
                    color: Colors.grey,
                  ),
                ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.blue),
          ),
        ),
      ),
      dropdownBuilder: (context, selectedItem) => Text(
        selectedItem != null
            ? widget.getLabel(selectedItem)
            : widget.hint ?? '',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: widget.fontWeight ?? FontWeight.w400,
          fontSize: widget.fontSize ?? 14.0,
          color: selectedItem != null ? Colors.black : Colors.grey,
        ),
      ),
    );
  }
}*/

class KDropdownField<T> extends StatefulWidget {
  final String? title;
  final String? hint;
  final List<T> items;
  final T? value;
  final Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool isRequired;
  final double? fontSize;
  final FontWeight? fontWeight;
  final DropdownIconType dropdownIconType;
  final String Function(T) getLabel;
  final bool disableBgColor;
  final bool readOnly;

  const KDropdownField({
    super.key,
    this.title,
    this.hint,
    required this.items,
    required this.getLabel,
    this.value,
    this.onChanged,
    this.validator,
    this.isRequired = false,
    this.fontSize,
    this.fontWeight,
    this.dropdownIconType = DropdownIconType.arrowDown,
    this.disableBgColor = false,
    this.readOnly = false,
  });

  @override
  State<KDropdownField<T>> createState() => _KDropdownFieldState<T>();
}

class _KDropdownFieldState<T> extends State<KDropdownField<T>> {
  // Common text style - MATCHING KTextInputFormField
  TextStyle _getTextStyle({
    Color? color,
    double? size,
    FontWeight? weight,
  }) {
    return TextStyle(
      fontFamily: "Poppins",
      fontWeight: weight ?? widget.fontWeight ?? FontWeight.w400,
      fontSize: size ?? widget.fontSize ?? 14.0,
      color: color ?? Colors.black,
    );
  }

  // Common border - MATCHING KTextInputFormField
  InputBorder _getInputBorder({Color borderColor = Colors.grey}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(
        color: borderColor,
        width: 1.0,
      ),
    );
  }

  // Build label with or without required asterisk - MATCHING KTextInputFormField
  Widget _buildLabel() {
    final labelStyle = _getTextStyle(
      color: KColors.appSecondaryGrey, // Using same color as KTextInputFormField
      size: 14.0, // Matching KTextInputFormField default
    );

    if (!widget.isRequired) {
      return Text(
        widget.title ?? '',
        style: labelStyle,
      );
    }

    return RichText(
      text: TextSpan(
        text: widget.title ?? '',
        style: labelStyle,
        children: const [
          TextSpan(
            text: " *",
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 14.0, // Matching KTextInputFormField
            ),
          ),
        ],
      ),
    );
  }

  // Build dropdown icon based on type
  Widget _getDropdownIcon() {
    IconData iconData;
    switch (widget.dropdownIconType) {
      case DropdownIconType.arrowDown:
        iconData = Icons.keyboard_arrow_down_outlined;
        break;
      case DropdownIconType.chevronDown:
        iconData = Icons.expand_more;
        break;
    }
    return Icon(
      iconData,
      color: Colors.black,
      size: 24,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isReadOnly = widget.readOnly;
    final bgColor = (isReadOnly && widget.disableBgColor)
        ? Colors.grey.shade200
        : Colors.white;

    return DropdownSearch<T>(
      // Items & Selection
      items: widget.items,
      selectedItem: widget.value,
      onChanged: isReadOnly ? null : widget.onChanged,

      // Validator
      validator: widget.validator ?? _buildDefaultValidator(),

      // Display
      itemAsString: (T item) => widget.getLabel(item),

      // Dropdown Builder (Selected Item Display) - MATCHING KTextInputFormField
      dropdownBuilder: (context, selectedItem) => Text(
        selectedItem != null ? widget.getLabel(selectedItem) : widget.hint ?? '',
        style: _getTextStyle(
          color: selectedItem != null ? Colors.black : KColors.appSecondaryGrey,
        ),
      ),

      // Popup Props
      popupProps: PopupProps.menu(
        showSearchBox: true,
        fit: FlexFit.loose,
        searchFieldProps: TextFieldProps(
          style: _getTextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: 'Search ${widget.title ?? ''}...',
            hintStyle: _getTextStyle(color: KColors.appSecondaryGrey),
            border: _getInputBorder(),
            focusedBorder: _getInputBorder(borderColor: Colors.blue),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        // Popup menu item styling
        menuProps: MenuProps(
          borderRadius: BorderRadius.circular(10.0),
          elevation: 4,
        ),
        // Custom container builder for better styling
        containerBuilder: (context, popupWidget) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.white,
            ),
            child: popupWidget,
          );
        },
      ),

      // Dropdown Button Props
      dropdownButtonProps: DropdownButtonProps(
        icon: _getDropdownIcon(),
        padding: const EdgeInsets.only(right: 12),
      ),

      // Dropdown Decorator Props (Main Input Field) - MATCHING KTextInputFormField
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          // Label
          label: _buildLabel(),
          floatingLabelBehavior: FloatingLabelBehavior.always,

          // Background
          filled: true,
          fillColor: bgColor,

          // Hint
          hintText: widget.hint,
          hintStyle: _getTextStyle(color: KColors.appSecondaryGrey),

          // Padding - MATCHING KTextInputFormField
          contentPadding: const EdgeInsets.only(
            left: 20,
            top: 10,
            bottom: 10,
            right: 10,
          ),

          // Borders - MATCHING KTextInputFormField
          border: _getInputBorder(),
          enabledBorder: _getInputBorder(),
          focusedBorder: _getInputBorder(borderColor: Colors.blue),
          errorBorder: _getInputBorder(borderColor: Colors.red),
          focusedErrorBorder: _getInputBorder(borderColor: Colors.red),
          disabledBorder: _getInputBorder(borderColor: Colors.grey.shade300),

          // Error Style - MATCHING KTextInputFormField
          errorStyle: _getTextStyle(
            color: Colors.red,
            size: 12.0,
          ),
        ),
      ),
    );
  }

  // Default validator for required fields - MATCHING KTextInputFormField
  String? Function(T?)? _buildDefaultValidator() {
    if (!widget.isRequired) return null;
    return (value) {
      if (value == null) {
        return 'This field is required';
      }
      return null;
    };
  }
}