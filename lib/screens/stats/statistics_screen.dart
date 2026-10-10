import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/month_selector.dart';

class _SectionShare {
  final CategoryModel category;
  final int spent;
  _SectionShare(this.category, this.spent);
}

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
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

  String _compact(int poisha) {
    final taka = poisha / 100;
    if (taka >= 1000) {
      final k = taka / 1000;
      return k == k.roundToDouble()
          ? '${k.round()}k'
          : '${k.toStringAsFixed(1)}k';
    }
    return taka.round().toString();
  }

  Color _shadeFor(int index, int total, AppColors c) {
    if (total <= 1) return c.accentFg;
    final t = index / (total - 1);
    return Color.lerp(c.accentFg, c.shadeEnd, t)!;
  }

  double _niceMax(double maxTaka) {
    if (maxTaka <= 0) return 100;
    double magnitude = 1;
    while (magnitude * 10 <= maxTaka) {
      magnitude *= 10;
    }
    final n = maxTaka / magnitude;
    final double niceNorm = n <= 1
        ? 1.0
        : (n <= 2 ? 2.0 : (n <= 5 ? 5.0 : 10.0));
    return niceNorm * magnitude;
  }

  Widget _buildWeeklyChart(List<TransactionModel> transactions) {
    final c = context.colors;

    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final monday = DateTime(
      today.year,
      today.month,
      today.day - (today.weekday - 1),
    );
    final weekDays = List.generate(
      7,
      (i) => DateTime(monday.year, monday.month, monday.day + i),
    );

    final dayTotals = List<int>.filled(7, 0);

    for (final t in transactions) {
      final parsed = DateTime.parse(t.date);
      for (var i = 0; i < 7; i++) {
        final d = weekDays[i];
        if (parsed.year == d.year &&
            parsed.month == d.month &&
            parsed.day == d.day) {
          dayTotals[i] += t.amount;
          break;
        }
      }
    }

    final weekTotal = dayTotals.fold<int>(0, (sum, v) => sum + v);
    final maxDay = dayTotals.fold<int>(0, (m, v) => v > m ? v : m);
    final maxY = _niceMax(maxDay / 100);

    final sunday = weekDays[6];
    final rangeText =
        '${monday.day} ${monthNames[monday.month - 1]} - ${sunday.day} ${monthNames[sunday.month - 1]}';

    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'THIS WEEK',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: c.faint,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    rangeText,
                    style: TextStyle(fontSize: 12, color: c.subtle),
                  ),
                ],
              ),
              Text(
                '৳ ${_formatMoney(weekTotal)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: c.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                minY: 0,
                maxY: maxY,
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 2,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: c.border, strokeWidth: 1),
                ),
                barGroups: [
                  for (var i = 0; i < 7; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: dayTotals[i] / 100,
                          width: 18,
                          color: weekDays[i] == today ? c.accentFg : c.shadeEnd,
                          borderRadius: BorderRadius.circular(4),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxY,
                            color: c.track,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        dayNames[i],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: weekDays[i] == today
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: weekDays[i] == today ? c.ink : c.faint,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dayTotals[i] > 0 ? _compact(dayTotals[i]) : '',
                        style: TextStyle(fontSize: 10, color: c.subtle),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
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
          'Statistics',
          style: TextStyle(color: c.ink, fontWeight: FontWeight.w700),
        ),
      ),
      body: Consumer2<CategoryProvider, TransactionProvider>(
        builder: (context, categoryProvider, transactionProvider, child) {
          if (categoryProvider.isLoading || transactionProvider.isLoading) {
            return Center(child: CircularProgressIndicator(color: c.accentFg));
          }

          final shares =
              categoryProvider.categories
                  .map(
                    (cat) => _SectionShare(
                      cat,
                      transactionProvider.spentForCategory(cat.id!),
                    ),
                  )
                  .where((s) => s.spent > 0)
                  .toList()
                ..sort((a, b) => b.spent.compareTo(a.spent));

          final totalSpent = transactionProvider.totalSpent;
          final hasData = shares.isNotEmpty && totalSpent > 0;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              const MonthSelector(),
              const SizedBox(height: 20),

              if (!hasData)
                Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Center(
                    child: Text(
                      'No expenses in this month.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: c.faint, height: 1.5),
                    ),
                  ),
                )
              else ...[
                // ---- Donut Chart ----
                SizedBox(
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 72,
                          startDegreeOffset: -90,
                          sections: [
                            for (var i = 0; i < shares.length; i++)
                              PieChartSectionData(
                                value: shares[i].spent.toDouble(),
                                color: _shadeFor(i, shares.length, c),
                                radius: 26,
                                showTitle: false,
                              ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'TOTAL SPENT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: c.faint,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '৳ ${_formatMoney(totalSpent)}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: c.ink,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _buildWeeklyChart(transactionProvider.transactions),
                const SizedBox(height: 24),

                // ---- Top Section Card ----
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: c.surface,
                    border: Border.all(color: c.border),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOP SECTION',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: c.faint,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            shares.first.category.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: c.ink,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${(shares.first.spent / totalSpent * 100).round()}%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: c.accentFg,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'BREAKDOWN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: c.faint,
                  ),
                ),
                const SizedBox(height: 12),

                for (var i = 0; i < shares.length; i++)
                  Container(
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
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _shadeFor(i, shares.length, c),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            shares[i].category.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: c.ink,
                            ),
                          ),
                        ),
                        Text(
                          '${(shares[i].spent / totalSpent * 100).round()}%',
                          style: TextStyle(fontSize: 12, color: c.faint),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          '৳ ${_formatMoney(shares[i].spent)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: c.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
