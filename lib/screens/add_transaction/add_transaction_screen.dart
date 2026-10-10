import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/budget_warning.dart';
import '../../widgets/form_helpers.dart';
import '../../widgets/month_selector.dart';
import '../../widgets/section_history_sheet.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<CategoryProvider>().loadCategories();
      context.read<TransactionProvider>().loadTransactions();
    });
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

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Expense',
          style: TextStyle(color: c.ink, fontWeight: FontWeight.w700),
        ),
      ),
      body: Consumer2<CategoryProvider, TransactionProvider>(
        builder: (context, categoryProvider, transactionProvider, child) {
          if (categoryProvider.isLoading) {
            return Center(child: CircularProgressIndicator(color: c.accentFg));
          }

          final categories = categoryProvider.categories;

          final categoriesWithExpenses = categories.where((category) {
            return transactionProvider
                .transactionsForCategory(category.id!)
                .isNotEmpty;
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const MonthSelector(),
              const SizedBox(height: 16),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.95,
                ),
                itemCount: categories.length + 1,
                itemBuilder: (context, index) {
                  // শেষ ঘর: নতুন Section বানানোর বাটন
                  if (index == categories.length) {
                    return GestureDetector(
                      onTap: _showAddSectionSheet,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: c.border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                border: Border.all(color: c.subtle),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.add, size: 18, color: c.muted),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'New',
                              style: TextStyle(fontSize: 11, color: c.muted),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final category = categories[index];

                  return GestureDetector(
                    onTap: () => _showAddExpenseSheet(category),
                    child: Container(
                      decoration: BoxDecoration(
                        color: c.surface,
                        border: Border.all(color: c.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: c.accentFg.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),

                            child: Icon(
                              Icons.circle,
                              color: c.accentFg,
                              size: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: c.ink,
                            ),
                          ),
                          if (category.monthlyBudget != null)
                            Text(
                              '৳${(category.monthlyBudget! / 100).toStringAsFixed(0)}',
                              style: TextStyle(fontSize: 10, color: c.subtle),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              if (categoriesWithExpenses.isNotEmpty) ...[
                const SizedBox(height: 28),
                Text(
                  'ADDED EXPENSES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: c.faint,
                  ),
                ),
                const SizedBox(height: 12),
                ...categoriesWithExpenses.map((category) {
                  final spent = transactionProvider.spentForCategory(
                    category.id!,
                  );
                  final budget = category.monthlyBudget ?? 0;
                  final remaining = budget - spent;

                  return GestureDetector(
                    onTap: () => showSectionHistorySheet(context, category),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: c.surface,
                        border: Border.all(color: c.border),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: c.accentFg.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.circle,
                              color: c.accentFg,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              category.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: c.ink,
                              ),
                            ),
                          ),
                          Text(
                            '৳ ${_formatMoney(remaining)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: remaining >= 0 ? c.ink : c.danger,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.chevron_right, size: 18, color: c.subtle),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ],
          );
        },
      ),
    );
  }

  void _showAddSectionSheet() {
    final nameController = TextEditingController();
    final budgetController = TextEditingController();
    final sectionFormKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        final c = context.colors;

        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: sectionFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Section',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: c.ink,
                  ),
                ),
                const SizedBox(height: 20),
                const FieldLabel('Name'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: nameController,
                  decoration: appInputDecoration(context, hint: 'e.g. Adda'),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                const FieldLabel('Monthly budget'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: budgetController,
                  keyboardType: TextInputType.number,
                  decoration: appInputDecoration(context, prefix: '৳ '),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (double.tryParse(v) == null) return 'Invalid number';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!sectionFormKey.currentState!.validate()) return;
                      final budgetInPoisha =
                          (double.parse(budgetController.text) * 100).round();

                      final newCategory = CategoryModel(
                        name: nameController.text,
                        type: 'expense',
                        iconCode: Icons.circle.codePoint,

                        colorValue: 0xFF1B4332,
                        monthlyBudget: budgetInPoisha,
                        isDefault: false,
                      );

                      await context.read<CategoryProvider>().addCategory(
                        newCategory,
                      );
                      if (context.mounted) Navigator.pop(context);
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
                      'Save',
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
  }

  void _showAddExpenseSheet(CategoryModel category) {
    final screenContext = context;

    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final expenseFormKey = GlobalKey<FormState>();
    DateTime selectedDate = DateTime.now();

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
                key: expenseFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
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
                    const FieldLabel('Note (optional)'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: noteController,
                      decoration: appInputDecoration(
                        context,
                        hint: 'e.g. Coffee with friends',
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!expenseFormKey.currentState!.validate()) return;
                          final amountInPoisha =
                              (double.parse(amountController.text) * 100)
                                  .round();

                          final transactionProvider = context
                              .read<TransactionProvider>();

                          final spentBefore = transactionProvider
                              .spentForCategoryInMonth(
                                category.id!,
                                selectedDate,
                              );

                          final newTransaction = TransactionModel(
                            type: 'expense',
                            amount: amountInPoisha,
                            categoryId: category.id!,
                            date: selectedDate.toIso8601String(),
                            note: noteController.text.isEmpty
                                ? null
                                : noteController.text,
                          );

                          await transactionProvider.addTransaction(
                            newTransaction,
                          );

                          if (context.mounted) Navigator.pop(context);

                          if (screenContext.mounted) {
                            await showBudgetWarningIfNeeded(
                              context: screenContext,
                              category: category,
                              spentBefore: spentBefore,
                              spentAfter: spentBefore + amountInPoisha,
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
                          'Save expense',
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
}
