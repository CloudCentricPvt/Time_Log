import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/k_colors.dart';

/*
class KTextInputFormField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final String? initValue;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool? obscureText;
  final String? Function(String?)? validator;
  final String? Function(String?)? onChange;
  final bool? readOnly;
  final Icon? prefixIcon;
  final IconButton? suffixIcon;

  // New optional flags
  final bool useMaxLines;
  final int? maxLines;
  final int? minLines;

  final bool useMaxLength;
  final int? maxLength;

  final bool isRequired; // New flag for required fields

  // Newly added font customization
  final double? fontSize;
  final FontWeight? fontWeight;
  final List<TextInputFormatter>? inputFormatters;
  final bool disableBgColor;

  const KTextInputFormField({
    super.key,
    required this.labelText,
    required this.hintText,
    this.initValue,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onChange,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.useMaxLines = false,
    this.maxLines = 1,
    this.minLines = 1,
    this.useMaxLength = false,
    this.maxLength = 1000,
    this.isRequired = false, // Default: false
    this.fontSize, // New optional fontSize
    this.fontWeight, // New optional fontWeight
    this.inputFormatters,
    this.disableBgColor = false, // default false
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(
        fontFamily: "Poppins",
        fontWeight: fontWeight ?? FontWeight.w400,
        fontSize: fontSize ?? 14.0,
        color: Colors.black,
      ),
      initialValue: initValue,
      controller: controller,
      keyboardType: useMaxLines ? TextInputType.multiline : keyboardType,
      textInputAction:
          useMaxLines ? TextInputAction.newline : TextInputAction.done,
      // Show Enter key
      obscureText: (obscureText ?? false) && (maxLines == 1),
      minLines: useMaxLines ? minLines : 1,
      // Enable auto wrap
      maxLines: useMaxLines ? maxLines : 1,
      // Enable auto wrap
      maxLength: useMaxLength ? maxLength : null,
      validator: validator ??
          (isRequired
              ? (value) =>
                  value?.isEmpty ?? true ? "This field is required" : null
              : null),
      onChanged: onChange,
      readOnly: readOnly ?? false,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        alignLabelWithHint: true,
        filled: true,
        fillColor: (readOnly ?? false) && disableBgColor
            ? Colors.grey.shade200
            : Colors.white,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        label: isRequired
            ? RichText(
                text: TextSpan(
                  text: labelText ?? '',
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: fontWeight ?? FontWeight.w400,
                    fontSize: fontSize ?? 14.0,
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
                labelText ?? '',
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: fontWeight ?? FontWeight.w400,
                  fontSize: fontSize ?? 14.0,
                  color: KColors.appSecondaryGrey,
                ),
              ),
        hintText: hintText,
        hintStyle: TextStyle(
          fontFamily: "Poppins",
          fontWeight: fontWeight ?? FontWeight.w400,
          fontSize: fontSize ?? 14.0,
          color: KColors.appSecondaryGrey,
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: Colors.grey,
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
        contentPadding:
            const EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 10),
      ),
    );
  }
}*/

class KTextInputFormField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final String? initValue;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool? obscureText;
  final String? Function(String?)? validator;
  final String? Function(String?)? onChange;
  final bool? readOnly;
  final Icon? prefixIcon;
  final IconButton? suffixIcon;
  final bool useMaxLines;
  final int? maxLines;
  final int? minLines;
  final bool useMaxLength;
  final int? maxLength;
  final bool isRequired;
  final double? fontSize;
  final FontWeight? fontWeight;
  final List<TextInputFormatter>? inputFormatters;
  final bool disableBgColor;

  const KTextInputFormField({
    super.key,
    required this.labelText,
    required this.hintText,
    this.initValue,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onChange,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.useMaxLines = false,
    this.maxLines = 1,
    this.minLines = 1,
    this.useMaxLength = false,
    this.maxLength = 1000,
    this.isRequired = false,
    this.fontSize,
    this.fontWeight,
    this.inputFormatters,
    this.disableBgColor = false,
  });

  // Common text style for consistency
  TextStyle _getTextStyle({Color? color, double? size, FontWeight? weight}) {
    return TextStyle(
      fontFamily: "Poppins",
      fontWeight: weight ?? fontWeight ?? FontWeight.w400,
      fontSize: size ?? fontSize ?? 14.0,
      color: color ?? Colors.black,
    );
  }

  // Common decoration style
  InputBorder _getInputBorder({Color borderColor = Colors.grey}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(
        color: borderColor,
        width: 1.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isReadOnly = readOnly ?? false;
    final isObscure = (obscureText ?? false) && (maxLines == 1);
    final isMultiLine = useMaxLines;
    final bgColor = (isReadOnly && disableBgColor)
        ? Colors.grey.shade200
        : Colors.white;

    return TextFormField(
      // Text Styling
      style: _getTextStyle(color: Colors.black),

      // Controllers & Initial Value
      initialValue: initValue,
      controller: controller,

      // Keyboard Configuration
      keyboardType: isMultiLine ? TextInputType.multiline : keyboardType,
      textInputAction: isMultiLine ? TextInputAction.newline : TextInputAction.done,

      // Visibility & Lines
      obscureText: isObscure,
      // 🔥 FIX: Proper minLines and maxLines for scrolling
      minLines: isMultiLine ? (minLines ?? 4) : 1,
      maxLines: isMultiLine ? (maxLines ?? null) : 1,

      // Max Length
      maxLength: useMaxLength ? maxLength : null,
      buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
        if (!useMaxLength) return null;
        return null; // Hides the counter if you want, or customize it
      },

      // Validators & Callbacks
      validator: validator ?? _buildDefaultValidator(),
      onChanged: onChange,

      // Readonly & Formatters
      readOnly: isReadOnly,
      inputFormatters: inputFormatters,

      // Decoration
      decoration: InputDecoration(
        alignLabelWithHint: true,
        filled: true,
        fillColor: bgColor,
        floatingLabelBehavior: FloatingLabelBehavior.always,

        // Label with required asterisk
        label: _buildLabel(),

        // Hint Text
        hintText: hintText,
        hintStyle: _getTextStyle(color: KColors.appSecondaryGrey),

        // Icons
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,

        // Borders
        border: _getInputBorder(),
        enabledBorder: _getInputBorder(),
        focusedBorder: _getInputBorder(borderColor: Colors.blue),
        errorBorder: _getInputBorder(borderColor: Colors.red),
        focusedErrorBorder: _getInputBorder(borderColor: Colors.red),
        disabledBorder: _getInputBorder(borderColor: Colors.grey.shade300),

        // Padding
        contentPadding: const EdgeInsets.only(
          left: 20,
          top: 10,
          bottom: 10,
          right: 10,
        ),

        // Error style
        errorStyle: _getTextStyle(
          color: Colors.red,
          size: 12.0,
        ),
      ),
    );
  }

  // Default validator for required fields
  String? Function(String?)? _buildDefaultValidator() {
    if (!isRequired) return null;
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return "This field is required";
      }
      return null;
    };
  }

  // Build label with or without required asterisk
  Widget _buildLabel() {
    final labelStyle = _getTextStyle(color: KColors.appSecondaryGrey);

    if (!isRequired) {
      return Text(
        labelText ?? '',
        style: labelStyle,
      );
    }

    return RichText(
      text: TextSpan(
        text: labelText ?? '',
        style: labelStyle,
        children: const [
          TextSpan(
            text: " *",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }
}
