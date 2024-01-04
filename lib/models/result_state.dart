import 'package:connect/models/api_handler/network_exceptions.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'result_state.freezed.dart';

@freezed
class ResultState<T> with _$ResultState<T> {
  const factory ResultState.noConnection() = _NoConnection<T>;
  const factory ResultState.serverError() = _ServerError<T>;
  const factory ResultState.unknownError() = _UnknownError<T>;
  const factory ResultState.loading() = _Loading<T>;
  const factory ResultState.initial() = _Initial<T>;
  const factory ResultState.success({T? data}) = _Success<T>;
  const factory ResultState.error({required String error}) = _Error<T>;
  const factory ResultState.exception(
      {required NetworkExceptions networkException}) = _Exception<T>;
}
