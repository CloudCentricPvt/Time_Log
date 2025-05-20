
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

enum DropdownIconType {
  arrowDown,
  chevronDown,
}

class KDropdownField<T> extends StatefulWidget {
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
}

class _KDropdownFieldState<T> extends State<KDropdownField<T>> {
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
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
        selectedItem != null ? widget.getLabel(selectedItem) : widget.hint ?? '',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: widget.fontWeight ?? FontWeight.w400,
          fontSize: widget.fontSize ?? 14.0,
          color: selectedItem != null ? Colors.black : Colors.grey,
        ),
      ),
    );


    /*DropdownButtonFormField<T>(
      decoration: InputDecoration(
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
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
      hint: widget.hint != null
          ? Text(
        widget.hint!,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: widget.fontWeight ?? FontWeight.w400,
          fontSize: widget.fontSize ?? 14.0,
          color: Colors.grey,
        ),
      )
          : null,
      value: widget.value,
      items: widget.leaveTypes.map((T item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            widget.getLabel(item),  // Use label extractor
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: widget.fontWeight ?? FontWeight.w400,
              fontSize: widget.fontSize ?? 14.0,
            ),
          ),
        );
      }).toList(),
      onChanged: widget.onChanged,
      validator: widget.validator ??
          (widget.isRequired
              ? (value) => value == null ? "This field is required" : null
              : null),
      icon: widget.dropdownIconType == DropdownIconType.arrowDown
          ? const Icon(Icons.arrow_drop_down, color: Colors.black)
          : const Icon(Icons.expand_more, color: Colors.black),
    );*/
  }
}
