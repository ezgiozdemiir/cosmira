import '../../domain/entities/stardust_transaction.dart';

class StardustTransactionModel extends StardustTransaction {
  const StardustTransactionModel({
    required super.id,
    required super.userId,
    required super.amount,
    required super.type,
    required super.source,
    required super.description,
    required super.createdAt,
  });

  factory StardustTransactionModel.fromJson(Map<String, dynamic> json) {
    return StardustTransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      amount: json['amount'] as int,
      type: json['type'] as String,
      source: json['source'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
