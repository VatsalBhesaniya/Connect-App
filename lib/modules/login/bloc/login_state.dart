part of 'login_bloc.dart';

@freezed
class LoginState with _$LoginState {
  const factory LoginState({
    required String email,
    required String password,
    required ResultState<dynamic> status,
  }) = _LoginState;

  factory LoginState.initial() {
    return const LoginState(
      email: '',
      password: '',
      status: ResultState<void>.initial(),
    );
  }
}
