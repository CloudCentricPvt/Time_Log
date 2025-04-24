import 'package:flutter/material.dart';

class KTextFormField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final int maxLines;
  final int maxLength;
  final TextEditingController? controller;

  const KTextFormField({
    Key? key,
    this.labelText = "Description",
    this.hintText = "Enter reason of Comp off Request here...",
    this.maxLines = 4,
    this.maxLength = 1000,
    this.controller, required Null Function(dynamic value) onChange
  }) : super(key: key);

  @override
  State<KTextFormField> createState() => _KTextFormFieldState();
}

class _KTextFormFieldState extends State<KTextFormField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        alignLabelWithHint: true,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: widget.labelText,
        hintText: widget.hintText,
        counterText: "", // Hide default counter
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: const BorderSide(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: const BorderSide(
            color: Colors.blue,
            width: 1.0,
          ),
        ),
      ),
      style: const TextStyle(
        fontFamily: "Poppins",
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
    );
  }
}
