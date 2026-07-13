// lib/features/auth/presentation/widgets/remember_me_checkbox.dart
import 'package:flutter/material.dart';
import 'package:payroll_soft_token_app/core/constants/app_constants.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';

class RememberMeCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const RememberMeCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: BorderSide(
              color: value ? AppTheme.primaryColor : Colors.grey.shade400,
              width: 2,
            ),
            activeColor: AppTheme.primaryColor,
            checkColor: Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          AppConstants.rememberMe,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
