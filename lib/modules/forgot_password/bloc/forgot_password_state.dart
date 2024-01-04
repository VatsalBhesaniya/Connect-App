part of 'forgot_password_bloc.dart';

@freezed
class ForgotPasswordState with _$ForgotPasswordState {
  const factory ForgotPasswordState.initial() = _Initial;
  const factory ForgotPasswordState.loadInProgress() = _LoadInProgress;
  const factory ForgotPasswordState.emailValidationSuccess({
    required bool isEmailValid,
  }) = _EmailValidationSuccess;
  const factory ForgotPasswordState.resendEmailSuccess() = _ResendEmailSuccess;
  const factory ForgotPasswordState.resendEmailFailure({
    required NetworkExceptions exception,
  }) = _ResendEmailFailure;
}
