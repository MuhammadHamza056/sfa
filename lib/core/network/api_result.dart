import 'api_exception.dart';

/// Explicit success/failure outcome of an API call, so feature providers
/// handle both branches instead of relying on try/catch around a future.
sealed class ApiResult<T> {
  const ApiResult();

  R when<R>({
    required R Function(T data) success,
    required R Function(ApiException error) failure,
  }) {
    final self = this;
    if (self is ApiSuccess<T>) return success(self.data);
    if (self is ApiFailure<T>) return failure(self.error);
    throw StateError('Unknown ApiResult subtype');
  }

  bool get isSuccess => this is ApiSuccess<T>;

  T? get dataOrNull => this is ApiSuccess<T> ? (this as ApiSuccess<T>).data : null;

  ApiException? get errorOrNull =>
      this is ApiFailure<T> ? (this as ApiFailure<T>).error : null;
}

class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}

class ApiFailure<T> extends ApiResult<T> {
  final ApiException error;
  const ApiFailure(this.error);
}
