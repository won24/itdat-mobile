import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerField extends StatelessWidget {
  final BuildContext context;
  final TextEditingController controller;
  final String label;
  final String fieldName;
  final void Function(String, String) validateField; // 수정된 시그니처
  final Map<String, String?> errors;

  const DatePickerField({
    required this.context,
    required this.controller,
    required this.label,
    required this.fieldName,
    required this.validateField,
    required this.errors,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () async {
              // DatePicker 호출
              DateTime? pickedDate = await showDatePicker(
                context: this.context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );

              if (pickedDate != null) {
                String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                controller.text = formattedDate;
                validateField(fieldName, formattedDate);
              }
            },
            child: AbsorbPointer(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: label,
                  errorText: errors[fieldName],
                ),
                readOnly: true,
              ),
            ),
          ),
          if (errors[fieldName] != null)
            Text(
              errors[fieldName]!,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
        ],
      ),
    );
  }
}
