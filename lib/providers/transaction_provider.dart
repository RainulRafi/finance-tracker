import 'package:flutter/material.dart';

import '../data/models/transaction_model.dart';
import '../data/repositories/transaction_repository.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _repository = TransactionRepository();

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;

  DateTime get selectedMonth => _selectedMonth;
  String get selectedMonthLabel =>
      '${_monthNames[_selectedMonth.month - 1]} ${_selectedMonth.year}';

  bool _inMonth(TransactionModel t, DateTime month) {
    final d = DateTime.parse(t.date);
    return d.year == month.year && d.month == month.month;
  }

  List<TransactionModel> get monthTransactions =>
      _transactions.where((t) => _inMonth(t, _selectedMonth)).toList();

  int spentForCategoryInMonth(int categoryId, DateTime month) {
    return _transactions
        .where((t) => t.categoryId == categoryId && _inMonth(t, month))
        .fold<int>(0, (sum, t) => sum + t.amount);
  }

  int spentForCategory(int categoryId) =>
      spentForCategoryInMonth(categoryId, _selectedMonth);

  List<TransactionModel> transactionsForCategory(int categoryId) {
    return _transactions
        .where((t) => t.categoryId == categoryId && _inMonth(t, _selectedMonth))
        .toList();
  }

  int get totalSpent =>
      monthTransactions.fold<int>(0, (sum, t) => sum + t.amount);

  void previousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    notifyListeners();
  }

  void nextMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    notifyListeners();
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();
    _transactions = await _repository.getAllTransactions();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _repository.insertTransaction(transaction);
    await loadTransactions();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _repository.updateTransaction(transaction);
    await loadTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await _repository.deleteTransaction(id);
    await loadTransactions();
  }
}
