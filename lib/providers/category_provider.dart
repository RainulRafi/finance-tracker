import 'package:flutter/material.dart';

import '../data/models/category_model.dart';
import '../data/repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repository = CategoryRepository();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    _categories = await _repository.getAllCategories();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCategory(CategoryModel category) async {
    await _repository.insertCategory(category);
    await loadCategories();
  }
}
