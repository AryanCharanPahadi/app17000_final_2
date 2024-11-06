import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String labelText;
  final String? selectedValue;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;

  const CustomDropdown({
    Key? key,
    required this.labelText,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
      value: selectedValue,
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }
}
