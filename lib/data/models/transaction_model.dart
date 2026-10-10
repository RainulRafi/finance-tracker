class TransactionModel {
  final int? id;
  final String type;
  final int amount;
  final int categoryId;
  final String date;
  final String? note;

  TransactionModel({
    this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.note,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      type: map['type'],
      amount: map['amount'],
      categoryId: map['categoryId'],
      date: map['date'],
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'categoryId': categoryId,
      'date': date,
      'note': note,
    };
  }
}
