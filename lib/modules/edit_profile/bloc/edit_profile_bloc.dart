import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:connect/models/api_handler/api_result.dart';
import 'package:connect/models/api_handler/network_exceptions.dart';
import 'package:connect/models/connect_user.dart';
import 'package:connect/repository/user_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_profile_state.dart';
part 'edit_profile_event.dart';
part 'edit_profile_bloc.freezed.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  EditProfileBloc({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(const EditProfileState.initial()) {
    on<_EditProfile>(_onEditProfile);
    on<_UpdateProfile>(_onUpdateProfile);
  }

  final UserRepository _userRepository;

  Future<void> _onEditProfile(
      _EditProfile event, Emitter<EditProfileState> emit) async {
    emit(const EditProfileState.loadInProgress());
    emit(EditProfileState.editProfileSuccess(
      user: event.user,
      image: event.image,
    ));
  }

  Future<void> _onUpdateProfile(
      _UpdateProfile event, Emitter<EditProfileState> emit) async {
    emit(const EditProfileState.loadInProgress());
    final File? imageFile = event.image;
    if (imageFile == null) {
      final ApiResult<void> updateUserResult =
          await _userRepository.updateUser(user: event.user);
      updateUserResult.when(
        success: (void data) {
          emit(const EditProfileState.updateProfileSuceess());
        },
        failure: (NetworkExceptions error) {
          emit(EditProfileState.updateProfileFailure(error: error));
        },
      );
    } else {
      final ApiResult<String> uploadProfileResult = await _userRepository
          .updateUserProfile(userId: event.user.id, image: imageFile);
      await uploadProfileResult.when(
        success: (String profileUrl) async {
          final ApiResult<void> updateUserResult = await _userRepository
              .updateUser(user: event.user.copyWith(profileUrl: profileUrl));
          updateUserResult.when(
            success: (void data) {
              emit(const EditProfileState.updateProfileSuceess());
            },
            failure: (NetworkExceptions error) {
              emit(EditProfileState.updateProfileFailure(error: error));
            },
          );
        },
        failure: (NetworkExceptions error) {
          emit(EditProfileState.updateProfileFailure(error: error));
        },
      );
    }
  }
}
