part of 'edit_profile_bloc.dart';

@freezed
class EditProfileEvent with _$EditProfileEvent {
  const factory EditProfileEvent.editProfile({
    required ConnectUser user,
    File? image,
  }) = _EditProfile;
  const factory EditProfileEvent.updateProfile({
    required ConnectUser user,
    File? image,
  }) = _UpdateProfile;
}
