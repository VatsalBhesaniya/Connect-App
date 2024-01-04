import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_exceptions.freezed.dart';

@freezed
abstract class NetworkExceptions with _$NetworkExceptions {
  const factory NetworkExceptions.firebaseError({
    String? message,
    required String code,
  }) = FirebaseError;
  const factory NetworkExceptions.exception({
    required String error,
  }) = Exception;

  const factory NetworkExceptions.requestCancelled() = RequestCancelled;

  const factory NetworkExceptions.unauthorisedRequest() = UnauthorisedRequest;

  const factory NetworkExceptions.badRequest() = BadRequest;

  const factory NetworkExceptions.notFound(String reason) = NotFound;

  const factory NetworkExceptions.methodNotAllowed() = MethodNotAllowed;

  const factory NetworkExceptions.notAcceptable() = NotAcceptable;

  const factory NetworkExceptions.requestTimeout() = RequestTimeout;

  const factory NetworkExceptions.sendTimeout() = SendTimeout;

  const factory NetworkExceptions.conflict() = Conflict;

  const factory NetworkExceptions.internalServerError() = InternalServerError;

  const factory NetworkExceptions.notImplemented() = NotImplemented;

  const factory NetworkExceptions.serviceUnavailable() = ServiceUnavailable;

  const factory NetworkExceptions.noInternetConnection() = NoInternetConnection;

  const factory NetworkExceptions.formatException() = FormatException;

  const factory NetworkExceptions.unableToProcess() = UnableToProcess;

  const factory NetworkExceptions.defaultError({required String error}) =
      DefaultError;

  const factory NetworkExceptions.unexpectedError() = UnexpectedError;

  static String getErrorMessage(NetworkExceptions networkException) {
    String errorMessage = 'Something went wrong. Please try again.';
    networkException.when(
      firebaseError: (String? message, String code) {
        errorMessage = message ?? code;
      },
      exception: (String error) {
        errorMessage = error;
      },
      requestCancelled: () {
        errorMessage = 'Request Cancelled';
      },
      unauthorisedRequest: () {
        errorMessage = 'Unauthorised request';
      },
      badRequest: () {
        errorMessage = 'Bad request';
      },
      notFound: (String reason) {
        errorMessage = reason;
      },
      methodNotAllowed: () {
        errorMessage = 'Method Allowed';
      },
      notAcceptable: () {
        errorMessage = 'Not acceptable';
      },
      requestTimeout: () {
        errorMessage = 'Connection request timeout';
      },
      sendTimeout: () {
        errorMessage = 'Send timeout in connection with API server';
      },
      conflict: () {
        errorMessage = 'Error due to a conflict';
      },
      internalServerError: () {
        errorMessage = 'Internal Server Error';
      },
      notImplemented: () {
        errorMessage = 'Not Implemented';
      },
      serviceUnavailable: () {
        errorMessage = 'Service unavailable';
      },
      noInternetConnection: () {
        errorMessage = 'No internet connection';
      },
      formatException: () {
        errorMessage = 'Unexpected error occurred';
      },
      unableToProcess: () {
        errorMessage = 'Unable to process the data';
      },
      defaultError: (String error) {
        errorMessage = error;
      },
      unexpectedError: () {
        errorMessage = 'Unexpected error occurred';
      },
    );
    return errorMessage;
  }
}
