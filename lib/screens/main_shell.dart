import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'add_transaction/add_transaction_screen.dart';
import 'home/home_screen.dart';
import 'stats/statistics_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // 0 = Home, 1 = Expense, 2 = Stats
  int _currentIndex = 0;

  void _goToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(onAddPressed: () => _goToTab(1)),
          const AddTransactionScreen(),
          const StatisticsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: c.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _goToTab,
          backgroundColor: c.surface,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: c.accentFg,
          unselectedItemColor: c.subtle,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Expense',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart_outline),
              activeIcon: Icon(Icons.pie_chart),
              label: 'Stats',
            ),
          ],
        ),
      ),
    );
  }
}
