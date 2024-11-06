import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDatePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final String label;
  final Function(DateTime) onDateChanged;
  final bool isStartDate;

  final String? errorText;
  final DateTime? firstDate; // Allows customization of the first selectable date

  const CustomDatePicker({
    Key? key,
    required this.selectedDate,
    required this.label,
    required this.onDateChanged,
    this.isStartDate = true,
    this.errorText,
    this.firstDate, // Initialize firstDate
  }) : super(key: key);

  void _selectDate(BuildContext context) async {
    // Open date picker dialog
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000), // Use firstDate if provided
      lastDate: DateTime(2101),
    );

    // If a date is picked, call the onDateChanged function
    if (pickedDate != null) {
      onDateChanged(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: errorText != null ? Colors.red : Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                      : "Select $label",
                  style: TextStyle(
                    fontSize: 16,
                    color: selectedDate != null ? Colors.black : Colors.black54,
                  ),
                ),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              errorText!,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
