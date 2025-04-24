import 'package:flutter/material.dart';
import '../constants/k_colors.dart';

class KRadioGroup extends StatefulWidget {
  final List<String> options;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  const KRadioGroup({
    super.key,
    required this.options,
    this.onChanged,
    this.validator,
  });

  @override
  _KRadioGroupState createState() => _KRadioGroupState();
}

class _KRadioGroupState extends State<KRadioGroup> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: widget.validator,
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10, // Space between radio buttons
              children: widget.options.map((String option) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedOption = option;
                    });
                    if (widget.onChanged != null) {
                      widget.onChanged!(option);
                    }
                    state.didChange(option); //  Update state
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Prevents taking full width
                    children: [
                      Radio<String>(
                        value: option,
                        groupValue: selectedOption,
                        activeColor: Colors.blue,
                        visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedOption = newValue;
                          });
                          if (widget.onChanged != null) {
                            widget.onChanged!(newValue!);
                          }
                          state.didChange(newValue); //  Update state
                        },
                      ),
                      Text(
                        option,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: selectedOption == option ? Colors.blue : Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            if (state.hasError) //  Show validation error
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 10),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}
