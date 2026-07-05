import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class InsufficientStardustFailure extends Failure {
  final int required;
  final int available;
  const InsufficientStardustFailure({
    required this.required,
    required this.available,
  }) : super('Insufficient Stardust');

  @override
  List<Object?> get props => [message, required, available];
}

class SubscriptionRequiredFailure extends Failure {
  const SubscriptionRequiredFailure([super.message = 'Premium subscription required']);
}

class EditLimitReachedFailure extends Failure {
  final int used;
  final int limit;
  const EditLimitReachedFailure({
    required this.used,
    required this.limit,
  }) : super('Birth data edit limit reached');

  @override
  List<Object?> get props => [message, used, limit];
}
