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
}
