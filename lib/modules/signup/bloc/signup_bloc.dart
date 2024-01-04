import 'package:bloc/bloc.dart';
import 'package:connect/common/constants.dart';
import 'package:connect/models/api_handler/api_result.dart';
import 'package:connect/models/api_handler/network_exceptions.dart';
import 'package:connect/models/connect_user.dart';
import 'package:connect/models/result_state.dart';
import 'package:connect/repository/authentication_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'signup_state.dart';
part 'signup_event.dart';
part 'signup_bloc.freezed.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  SignupBloc({
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(SignupState.initial()) {
    on<_UpdateUser>(_onUpdateUser);
    on<_SignupSubmitted>(_onSignupSubmitted);
  }

  final AuthenticationRepository _authenticationRepository;

  void _onUpdateUser(_UpdateUser event, Emitter<SignupState> emit) {
    final ConnectUser user = event.user;
    final String? password = user.password;
    final bool isFormValid = user.username.isNotEmpty &&
        user.firstName.isNotEmpty &&
        user.lastName.isNotEmpty &&
        user.gender.isNotEmpty &&
        user.birthDate.isNotEmpty &&
        user.email.isNotEmpty &&
        password != null &&
        password.isNotEmpty;
    emit(state.copyWith(
      user: event.user,
      isFormValid: isFormValid,
      status: const ResultState<void>.initial(),
    ));
  }

  Future<void> _onSignupSubmitted(
      _SignupSubmitted event, Emitter<SignupState> emit) async {
    emit(state.copyWith(status: const ResultState<void>.loading()));
    final ApiResult<String> result = await _authenticationRepository.signUp(
      user: state.user,
    );
    result.when(
      success: (String data) {
        emit(state.copyWith(status: const ResultState<void>.success()));
      },
      failure: (NetworkExceptions exception) {
        emit(
          state.copyWith(
            status: ResultState<NetworkExceptions>.exception(
              networkException: exception,
            ),
          ),
        );
      },
    );
  }
}
