import 'package:equatable/equatable.dart';

class StardustTransaction extends Equatable {
  final String id;
  final String userId;
  final int amount;
  final String type;
  final String source;
  final String description;
  final DateTime createdAt;

  const StardustTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.source,
    required this.description,
    required this.createdAt,
  });

  bool get isEarning => type == 'earn';
  bool get isSpending => type == 'spend';

  @override
  List<Object?> get props => [id];
}
