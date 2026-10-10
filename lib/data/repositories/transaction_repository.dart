import '../database/database_helper.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<void> insertTransaction(TransactionModel transaction) async {
    final db = await dbHelper.database;
    await db.insert('transactions', transaction.toMap());
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final db = await dbHelper.database;
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> deleteTransaction(int id) async {
    final db = await dbHelper.database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}
