import 'package:bloc/bloc.dart';
import 'package:connect/models/api_handler/api_result.dart';
import 'package:connect/models/api_handler/network_exceptions.dart';
import 'package:connect/models/result_state.dart';
import 'package:connect/repository/authentication_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.dart';
part 'login_event.dart';
part 'login_bloc.freezed.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(LoginState.initial()) {
    on<_UsernameChanged>(_onUsernameChanged);
    on<_PasswordChanged>(_onPasswordChanged);
    on<_LoginSubmitted>(_onLoginSubmitted);
    on<_SendVerificationEmail>(_onSendVerificationEmail);
  }

  final AuthenticationRepository _authenticationRepository;

  void _onUsernameChanged(_UsernameChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(
      email: event.email,
      status: const ResultState<void>.initial(),
    ));
  }

  void _onPasswordChanged(_PasswordChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(
      password: event.password,
      status: const ResultState<void>.initial(),
    ));
  }

  Future<void> _onLoginSubmitted(
      _LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: const ResultState<void>.loading()));
    final ApiResult<String> result = await _authenticationRepository.logIn(
      email: state.email,
      password: state.password,
    );
    result.when(
      success: (String data) {
        emit(state.copyWith(status: ResultState<String>.success(data: data)));
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

  Future<void> _onSendVerificationEmail(
      _SendVerificationEmail event, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: const ResultState<void>.loading()));
    final ApiResult<String> result =
        await _authenticationRepository.sendVerificationEmail();
    result.when(
      success: (String data) {
        emit(state.copyWith(status: ResultState<String>.success(data: data)));
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
