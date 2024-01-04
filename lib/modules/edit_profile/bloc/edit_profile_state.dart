part of 'edit_profile_bloc.dart';

@freezed
class EditProfileState with _$EditProfileState {
  const factory EditProfileState.initial() = _Initial;
  const factory EditProfileState.loadInProgress() = _LoadInProgress;
  const factory EditProfileState.editProfileLoadInProgress() =
      _EditProfileLoadInProgress;
  const factory EditProfileState.editProfileSuccess({
    required ConnectUser user,
    File? image,
  }) = _EditProfileSuccess;
  const factory EditProfileState.updateProfileSuceess() = _UpdateProfileSuceess;
  const factory EditProfileState.updateProfileFailure({
    required NetworkExceptions error,
  }) = _UpdateProfileFailure;
}
