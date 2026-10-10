import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../providers/transaction_provider.dart';

class MonthSelector extends StatelessWidget {
  const MonthSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return Container(
          decoration: BoxDecoration(
            color: c.surface,
            border: Border.all(color: c.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: provider.previousMonth,
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.chevron_left, color: c.ink),
              ),
              Text(
                provider.selectedMonthLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: c.ink,
                ),
              ),
              IconButton(
                onPressed: provider.nextMonth,
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.chevron_right, color: c.ink),
              ),
            ],
          ),
        );
      },
    );
  }
}
