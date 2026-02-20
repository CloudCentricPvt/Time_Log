
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/k_colors.dart';

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
      textInputAction: useMaxLines ? TextInputAction.newline : TextInputAction.done, // Show Enter key
        obscureText: (obscureText ?? false) && (maxLines == 1),
        minLines: useMaxLines ? minLines : 1, // Enable auto wrap
        maxLines: useMaxLines ? maxLines : 1, // Enable auto wrap
        maxLength: useMaxLength ? maxLength : null,
        validator: validator ?? (isRequired ? (value) => value?.isEmpty ?? true ? "This field is required" : null : null),
        onChanged: onChange,
        readOnly: readOnly ?? false,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          alignLabelWithHint: true,
          filled: true,
          fillColor: (readOnly ?? false) && disableBgColor ? Colors.grey.shade200 : Colors.white,
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
          contentPadding: const EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 10),
        ),
      );
  }
}



