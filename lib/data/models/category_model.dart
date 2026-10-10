class CategoryModel {
  final int? id;
  final String name;
  final String type;
  final int iconCode;
  final int colorValue;
  final int? monthlyBudget;
  final bool isDefault;

  CategoryModel({
    this.id,
    required this.name,
    required this.type,
    required this.iconCode,
    required this.colorValue,
    this.monthlyBudget,
    this.isDefault = false,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      iconCode: map['iconCode'],
      colorValue: map['colorValue'],
      monthlyBudget: map['monthlyBudget'],
      isDefault: map['isDefault'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'iconCode': iconCode,
      'colorValue': colorValue,
      'monthlyBudget': monthlyBudget,
      'isDefault': isDefault ? 1 : 0,
    };
  }
}
