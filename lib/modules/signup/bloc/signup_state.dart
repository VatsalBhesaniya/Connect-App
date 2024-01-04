part of 'signup_bloc.dart';

@freezed
class SignupState with _$SignupState {
  const factory SignupState({
    required ConnectUser user,
    required bool isFormValid,
    required ResultState<dynamic> status,
  }) = _SignupState;

  factory SignupState.initial() {
    return SignupState(
      user: ConnectUser(
        id: '',
        username: '',
        firstName: '',
        lastName: '',
        birthDate: '',
        email: '',
        gender: Gender.male.title,
        createdAt: DateTime.now().toUtc().microsecondsSinceEpoch,
      ),
      isFormValid: false,
      status: const ResultState<void>.initial(),
    );
  }
}
