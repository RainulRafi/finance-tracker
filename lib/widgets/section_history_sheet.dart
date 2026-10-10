import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../data/models/category_model.dart';
import '../data/models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import 'budget_warning.dart';
import 'form_helpers.dart';

String _formatMoney(int poisha) {
  final taka = poisha / 100;
  return taka
      .toStringAsFixed(0)
      .replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]},',
      );
}

void showSectionHistorySheet(BuildContext context, CategoryModel category) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Consumer<TransactionProvider>(
            builder: (context, transactionProvider, child) {
              final c = context.colors;
              final budget = category.monthlyBudget ?? 0;
              final spent = transactionProvider.spentForCategory(category.id!);
              final remaining = budget - spent;
              final entries = transactionProvider.transactionsForCategory(
                category.id!,
              );

              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: c.ink,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: c.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Remaining', style: TextStyle(color: c.muted)),
                          Text(
                            '৳ ${_formatMoney(remaining)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: remaining >= 0 ? c.accentFg : c.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'HISTORY  ·  ${transactionProvider.selectedMonthLabel.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: c.faint,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: entries.isEmpty
                          ? Center(
                              child: Text(
                                'No expenses this month',
                                style: TextStyle(color: c.subtle),
                              ),
                            )
                          : ListView.separated(
                              controller: scrollController,
                              itemCount: entries.length,
                              separatorBuilder: (_, _) =>
                                  Divider(height: 1, color: c.border),
                              itemBuilder: (context, index) {
                                final entry = entries[index];
                                final date = DateTime.parse(entry.date);

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              entry.note?.isNotEmpty == true
                                                  ? entry.note!
                                                  : category.name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: c.ink,
                                              ),
                                            ),
                                            Text(
                                              '${date.day}/${date.month}/${date.year}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: c.subtle,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '- ৳ ${_formatMoney(entry.amount)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: c.danger,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () => _showEditExpenseSheet(
                                          context,
                                          category,
                                          entry,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Icon(
                                            Icons.edit_outlined,
                                            size: 18,
                                            color: c.muted,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          context
                                              .read<TransactionProvider>()
                                              .deleteTransaction(entry.id!);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Icon(
                                            Icons.delete_outline,
                                            size: 18,
                                            color: c.danger,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}

void _showEditExpenseSheet(
  BuildContext context,
  CategoryModel category,
  TransactionModel entry,
) {
  final parentContext = context;

  final amountController = TextEditingController(
    text: (entry.amount / 100).toStringAsFixed(0),
  );
  final noteController = TextEditingController(text: entry.note ?? '');
  final formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.parse(entry.date);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          final c = context.colors;

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit ${category.name}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: c.ink,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const FieldLabel('Amount'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: appInputDecoration(context, prefix: '৳ '),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Invalid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const FieldLabel('Date'),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );

                      if (picked != null) {
                        setSheetState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: c.border),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            style: TextStyle(color: c.ink),
                          ),
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: c.faint,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const FieldLabel('Note'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: noteController,
                    decoration: appInputDecoration(context),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        final transactionProvider = context
                            .read<TransactionProvider>();
                        final newAmount =
                            (double.parse(amountController.text) * 100).round();

                        final oldDate = DateTime.parse(entry.date);
                        final sameMonth =
                            oldDate.year == selectedDate.year &&
                            oldDate.month == selectedDate.month;

                        final spentBefore = transactionProvider
                            .spentForCategoryInMonth(
                              category.id!,
                              selectedDate,
                            );
                        final spentAfter =
                            spentBefore -
                            (sameMonth ? entry.amount : 0) +
                            newAmount;

                        final updated = TransactionModel(
                          id: entry.id,
                          type: 'expense',
                          amount: newAmount,
                          categoryId: category.id!,
                          date: selectedDate.toIso8601String(),
                          note: noteController.text.isEmpty
                              ? null
                              : noteController.text,
                        );

                        await transactionProvider.updateTransaction(updated);

                        if (context.mounted) Navigator.pop(context);

                        if (parentContext.mounted) {
                          await showBudgetWarningIfNeeded(
                            context: parentContext,
                            category: category,
                            spentBefore: spentBefore,
                            spentAfter: spentAfter,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Update',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
