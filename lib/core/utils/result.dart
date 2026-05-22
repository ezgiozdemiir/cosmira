import '../errors/failures.dart';

sealed class Result<T> {
   Result();

  factory Result.success(T data) = Success<T>;
  factory Result.failure(Failure failure) = FailureResult<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  });
}

class Success<T> extends Result<T> {
  final T data;
   Success(this.data);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) => success(data);
}

class FailureResult<T> extends Result<T> {
  final Failure failure;
   FailureResult(this.failure);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) => failure(this.failure);
}
