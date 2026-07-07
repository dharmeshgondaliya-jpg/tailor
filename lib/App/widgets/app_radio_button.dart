import 'package:tailor/App/core/constants/color_constants.dart';
import 'package:flutter/material.dart';

class AppRadioButton<T> extends StatelessWidget {
  const AppRadioButton({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });
  final T? value;
  final T? groupValue;
  final void Function(T? value) onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioGroup(
      groupValue: groupValue,
      onChanged: (value) {
        onChanged.call(value);
      },
      child: Radio(
        value: value,
        activeColor: AppColors.primaryColor,
        hoverColor: AppColors.primaryColor,
      ),
    );
  }
}
