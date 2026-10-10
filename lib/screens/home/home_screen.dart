import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/category_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/month_selector.dart';
import '../../widgets/section_history_sheet.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onAddPressed;

  const HomeScreen({super.key, this.onAddPressed});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // FIX: Screen বন্ধ হয়ে গেলে আর context ছোঁয়া হবে না
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
      body: SafeArea(
        child:
            Consumer3<CategoryProvider, TransactionProvider, SettingsProvider>(
              builder:
                  (
                    context,
                    categoryProvider,
                    transactionProvider,
                    settingsProvider,
                    child,
                  ) {
                    if (categoryProvider.isLoading ||
                        transactionProvider.isLoading) {
                      return Center(
                        child: CircularProgressIndicator(color: c.accentFg),
                      );
                    }

                    final categories = categoryProvider.categories;
                    final totalBudget = categories.fold<int>(
                      0,
                      (sum, cat) => sum + (cat.monthlyBudget ?? 0),
                    );
                    final totalSpent = transactionProvider.totalSpent;
                    final totalRemaining = totalBudget - totalSpent;

                    final hour = DateTime.now().hour;
                    String greeting;
                    if (hour < 12) {
                      greeting = 'Good Morning';
                    } else if (hour < 17) {
                      greeting = 'Good Afternoon';
                    } else if (hour < 21) {
                      greeting = 'Good Evening';
                    } else {
                      greeting = 'Good Night';
                    }
                    final displayName = settingsProvider.userName ?? 'Users';

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                      children: [
                        // ---- Header: Greeting + Profile Icon ----
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  greeting.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.5,
                                    color: c.faint,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  displayName,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: c.ink,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SettingsScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: c.surface,
                                  border: Border.all(color: c.border),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.person_outline,
                                  color: c.ink,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        const MonthSelector(),
                        const SizedBox(height: 16),

                        // ---- Remaining Budget Card ----
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: c.accent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'REMAINING',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                  color: Colors.white60,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '৳ ${_formatMoney(totalRemaining)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Container(height: 1, color: Colors.white24),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: _StatInline(
                                      label: 'Budget',
                                      value: _formatMoney(totalBudget),
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 28,
                                    color: Colors.white24,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _StatInline(
                                      label: 'Spent',
                                      value: _formatMoney(totalSpent),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        Text(
                          'SECTIONS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            color: c.faint,
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (categories.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              border: Border.all(color: c.border),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              'No sections yet. Tap + to create one.',
                              style: TextStyle(color: c.muted),
                            ),
                          )
                        else
                          ...categories.map((category) {
                            final budget = category.monthlyBudget ?? 0;
                            final spent = transactionProvider.spentForCategory(
                              category.id!,
                            );
                            final progress = budget == 0
                                ? 0.0
                                : (spent / budget).clamp(0.0, 1.0);
                            final isWarning = progress >= 0.85;

                            return GestureDetector(
                              onTap: () =>
                                  showSectionHistorySheet(context, category),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: c.surface,
                                  border: Border.all(color: c.border),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            category.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              color: c.ink,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '৳ ${_formatMoney(spent)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: c.ink,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 4,
                                        backgroundColor: c.track,
                                        valueColor: AlwaysStoppedAnimation(
                                          isWarning ? c.danger : c.accentFg,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'of ৳ ${_formatMoney(budget)}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: c.subtle,
                                          ),
                                        ),
                                        if (isWarning)
                                          Text(
                                            'Low budget',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: c.danger,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                      ],
                    );
                  },
            ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: c.accent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: widget.onAddPressed,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// সবুজ Card-এর ভিতরে বসে, তাই এর লেখা সবসময় সাদা, Theme বদলালেও
class _StatInline extends StatelessWidget {
  final String label;
  final String value;
  const _StatInline({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white60),
        ),
        const SizedBox(height: 2),
        Text(
          '৳ $value',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
