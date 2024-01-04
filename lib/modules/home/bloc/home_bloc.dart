import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connect/models/api_handler/api_result.dart';
import 'package:connect/models/api_handler/network_exceptions.dart';
import 'package:connect/models/connect_user.dart';
import 'package:connect/repository/user_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_state.dart';
part 'home_event.dart';
part 'home_bloc.freezed.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required UserRepository userRepository,
    required int selectedTab,
  })  : _userRepository = userRepository,
        _slectedTab = selectedTab,
        super(const HomeState.initial()) {
    on<_TabChanged>(_onTabChanged);
    on<_FetchUser>(_onFetchUser);
  }

  final UserRepository _userRepository;
  final int _slectedTab;

  FutureOr<void> _onTabChanged(_TabChanged event, Emitter<HomeState> emit) {
    emit(
      HomeState.fetchUserSuccess(
        user: event.user,
        selectedTab: event.selectedTab,
      ),
    );
  }

  FutureOr<void> _onFetchUser(_FetchUser event, Emitter<HomeState> emit) async {
    final ApiResult<ConnectUser?> result = await _userRepository.fetchUser(
      email: event.email,
    );
    result.when(
      success: (ConnectUser? user) {
        if (user == null) {
          emit(
            const HomeState.fetchUserFailure(
                error: NetworkExceptions.defaultError(
                    error: 'Something went wrong.')),
          );
        } else {
          emit(
            HomeState.fetchUserSuccess(user: user, selectedTab: _slectedTab),
          );
        }
      },
      failure: (NetworkExceptions error) {
        HomeState.fetchUserFailure(error: error);
      },
    );
  }
}
