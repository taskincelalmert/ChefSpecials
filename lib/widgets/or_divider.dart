import 'package:flutter/material.dart';
import '../config/theme.dart';

class OrDivider extends StatelessWidget {
  final String label;

  const OrDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final lineColor = AppTheme.textSecondaryOf(context).withValues(alpha: 0.3);
    return Row(
      children: [
        Expanded(child: Divider(color: lineColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: TextStyle(
              color: AppTheme.textSecondaryOf(context),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(child: Divider(color: lineColor)),
      ],
    );
  }
}
