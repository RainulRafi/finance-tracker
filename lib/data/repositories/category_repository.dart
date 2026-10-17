import '../database/database_helper.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<List<CategoryModel>> getAllCategories() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  Future<void> insertCategory(CategoryModel category) async {
    final db = await dbHelper.database;
    await db.insert('categories', category.toMap());
  }

  Future<void> updateCategory(CategoryModel category) async {
    final db = await dbHelper.database;
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> deleteCategory(int id) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete(
        'transactions',
        where: 'categoryId = ?',
        whereArgs: [id],
      );
      await txn.delete('categories', where: 'id = ?', whereArgs: [id]);
    });
  }
}
