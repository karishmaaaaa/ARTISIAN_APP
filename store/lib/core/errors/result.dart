import 'failures.dart';

/// A functional result type that represents either success or failure.
/// 
/// This pattern eliminates try-catch blocks in business logic and
/// provides type-safe error handling throughout the application.
/// 
/// Usage:
/// ```dart
/// final result = await repository.getUser(id);
/// result.when(
///   success: (user) => print('User: ${user.name}'),
///   failure: (error) => print('Error: ${error.message}'),
/// );
/// ```
sealed class Result<T> {
  const Result();
  
  /// Creates a successful result with data
  factory Result.success(T data) = Success<T>;
  
  /// Creates a failed result with an error
  factory Result.failure(Failure failure) = Failure_<T>;
  
  /// Returns true if this is a successful result
  bool get isSuccess => this is Success<T>;
  
  /// Returns true if this is a failed result
  bool get isFailure => this is Failure_<T>;
  
  /// Gets the data if successful, throws if failure
  T get data {
    if (this is Success<T>) {
      return (this as Success<T>).value;
    }
    throw StateError('Cannot get data from a failure result');
  }
  
  /// Gets the data if successful, or null if failure
  T? get dataOrNull {
    if (this is Success<T>) {
      return (this as Success<T>).value;
    }
    return null;
  }
  
  /// Gets the failure if failed, throws if success
  Failure get failure {
    if (this is Failure_<T>) {
      return (this as Failure_<T>).error;
    }
    throw StateError('Cannot get failure from a success result');
  }
  
  /// Pattern matching on the result
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    if (this is Success<T>) {
      return success((this as Success<T>).value);
    } else {
      return failure((this as Failure_<T>).error);
    }
  }
  
  /// Maps the success value to a new type
  Result<R> map<R>(R Function(T data) mapper) {
    if (this is Success<T>) {
      return Result.success(mapper((this as Success<T>).value));
    } else {
      return Result.failure((this as Failure_<T>).error);
    }
  }
  
  /// Flat maps the success value to a new Result
  Result<R> flatMap<R>(Result<R> Function(T data) mapper) {
    if (this is Success<T>) {
      return mapper((this as Success<T>).value);
    } else {
      return Result.failure((this as Failure_<T>).error);
    }
  }
  
  /// Returns the data or a default value
  T getOrElse(T defaultValue) {
    if (this is Success<T>) {
      return (this as Success<T>).value;
    }
    return defaultValue;
  }
  
  /// Returns the data or computes a default value
  T getOrElseCompute(T Function(Failure failure) compute) {
    if (this is Success<T>) {
      return (this as Success<T>).value;
    }
    return compute((this as Failure_<T>).error);
  }
}

/// Represents a successful result containing data
final class Success<T> extends Result<T> {
  final T value;
  
  const Success(this.value);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Success<T> && other.value == value;
  }
  
  @override
  int get hashCode => value.hashCode;
  
  @override
  String toString() => 'Success($value)';
}

/// Represents a failed result containing an error
final class Failure_<T> extends Result<T> {
  final Failure error;
  
  const Failure_(this.error);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure_<T> && other.error == error;
  }
  
  @override
  int get hashCode => error.hashCode;
  
  @override
  String toString() => 'Failure(${error.message})';
}
