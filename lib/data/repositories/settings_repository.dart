import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';

class SettingsRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<String?> getValue(String key) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (result.isEmpty) return null;
    return result.first['value'] as String?;
  }

  Future<void> setValue(String key, String value) async {
    final db = await dbHelper.database;

    await db.insert('settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
