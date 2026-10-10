import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../data/models/category_model.dart';
import '../providers/settings_provider.dart';

enum BudgetAlertLevel { none, nearLimit, exceeded }

BudgetAlertLevel _levelFor(int spent, int budget) {
  if (budget <= 0) return BudgetAlertLevel.none;
  if (spent >= budget) return BudgetAlertLevel.exceeded;
  if (spent / budget >= 0.85) return BudgetAlertLevel.nearLimit;
  return BudgetAlertLevel.none;
}

String _formatMoney(int poisha) {
  final taka = poisha / 100;
  return taka
      .toStringAsFixed(0)
      .replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]},',
      );
}

Future<void> showBudgetWarningIfNeeded({
  required BuildContext context,
  required CategoryModel category,
  required int spentBefore,
  required int spentAfter,
}) async {
  if (!context.mounted) return;

  final alertsEnabled = context.read<SettingsProvider>().budgetAlertsEnabled;
  if (!alertsEnabled) return;

  final budget = category.monthlyBudget ?? 0;
  final before = _levelFor(spentBefore, budget);
  final after = _levelFor(spentAfter, budget);

  if (after.index <= before.index) return;

  final String title;
  final String message;

  if (after == BudgetAlertLevel.nearLimit) {
    final remaining = budget - spentAfter;
    title = 'Budget running low';
    message =
        '${category.name} has ৳ ${_formatMoney(remaining)} left '
        'out of ৳ ${_formatMoney(budget)}.';
  } else if (spentAfter == budget) {
    title = 'Budget used up';
    message =
        '${category.name} has no budget left. '
        'You have spent all ৳ ${_formatMoney(budget)}.';
  } else {
    final over = spentAfter - budget;
    title = 'Over budget';
    message = '${category.name} is over budget by ৳ ${_formatMoney(over)}.';
  }

  if (!context.mounted) return;

  await showDialog(
    context: context,
    builder: (dialogContext) {
      final c = dialogContext.colors;

      return AlertDialog(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: c.border),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: after == BudgetAlertLevel.exceeded ? c.danger : c.ink,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 14, color: c.muted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'OK',
              style: TextStyle(color: c.accentFg, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      );
    },
  );
}
