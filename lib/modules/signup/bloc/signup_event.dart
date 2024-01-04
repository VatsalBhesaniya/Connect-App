part of 'signup_bloc.dart';

@freezed
class SignupEvent with _$SignupEvent {
  const factory SignupEvent.updateUser({
    required ConnectUser user,
  }) = _UpdateUser;
  const factory SignupEvent.signupSubmitted({
    required ConnectUser user,
  }) = _SignupSubmitted;
}
