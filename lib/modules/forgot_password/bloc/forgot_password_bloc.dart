import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connect/models/api_handler/api_result.dart';
import 'package:connect/models/api_handler/network_exceptions.dart';
import 'package:connect/repository/authentication_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'forgot_password_state.dart';
part 'forgot_password_event.dart';
part 'forgot_password_bloc.freezed.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc({
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(const ForgotPasswordState.initial()) {
    on<_EmailChanged>(_onEmailChanged);
    on<_ResendEmailSubmitted>(_onResendEmailSubmitted);
  }

  final AuthenticationRepository _authenticationRepository;

  FutureOr<void> _onEmailChanged(
      _EmailChanged event, Emitter<ForgotPasswordState> emit) {
    emit(ForgotPasswordState.emailValidationSuccess(
        isEmailValid: event.email.isNotEmpty));
  }

  Future<FutureOr<void>> _onResendEmailSubmitted(
      _ResendEmailSubmitted event, Emitter<ForgotPasswordState> emit) async {
    emit(const ForgotPasswordState.loadInProgress());
    final ApiResult<String?> result =
        await _authenticationRepository.sendResetPasswordEmail(event.email);
    result.when(
      success: (String? data) {
        emit(const ForgotPasswordState.resendEmailSuccess());
      },
      failure: (NetworkExceptions exception) {
        emit(ForgotPasswordState.resendEmailFailure(exception: exception));
      },
    );
  }
}
