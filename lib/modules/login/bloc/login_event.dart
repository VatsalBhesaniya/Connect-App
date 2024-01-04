part of 'login_bloc.dart';

@freezed
class LoginEvent with _$LoginEvent {
  const factory LoginEvent.usernameChanged({
    required String email,
  }) = _UsernameChanged;
  const factory LoginEvent.passwordChanged({
    required String password,
  }) = _PasswordChanged;
  const factory LoginEvent.loginSubmitted({
    required String email,
    required String password,
  }) = _LoginSubmitted;
  const factory LoginEvent.sendVerificationEmail() = _SendVerificationEmail;
}
