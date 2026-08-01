// lib/features/activation/presentation/widgets/activation_footer.dart
import 'package:flutter/material.dart';

class ResendCodeRow extends StatelessWidget {
  final VoidCallback? onResend;

  const ResendCodeRow({super.key, this.onResend});

  static const Color _linkColor = Color(0xFFE0447B);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't receive the code ? ",
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
        GestureDetector(
          onTap: onResend,
          child: const Text(
            'Resend Code',
            style: TextStyle(
              color: _linkColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class ActivationTrustDivider extends StatelessWidget {
  const ActivationTrustDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Icon(
            Icons.verified_user_outlined,
            size: 18,
            color: Color(0xFF1A1A1A),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
      ],
    );
  }
}
