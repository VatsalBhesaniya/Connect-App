part of 'authentication_bloc.dart';

@freezed
class AuthenticationState with _$AuthenticationState {
  const factory AuthenticationState({
    required AuthenticationStatus status,
    auth.User? user,
  }) = _AuthenticationState;

  factory AuthenticationState.initial() {
    return const AuthenticationState(
      status: AuthenticationStatus.unknown,
    );
  }
}
