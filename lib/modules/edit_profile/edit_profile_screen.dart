import 'dart:io';

import 'package:connect/common/constants.dart';
import 'package:connect/models/api_handler/network_exceptions.dart';
import 'package:connect/models/connect_user.dart';
import 'package:connect/modules/edit_profile/bloc/edit_profile_bloc.dart';
import 'package:connect/utils/text_styles.dart';
import 'package:connect/widgets/radio_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';

class EditProfileScreen extends StatelessWidget {
  EditProfileScreen({Key? key}) : super(key: key);

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  // final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: BlocConsumer<EditProfileBloc, EditProfileState>(
                    listener: (BuildContext context, EditProfileState state) {
                      state.maybeWhen(
                        loadInProgress: () {
                          EasyLoading.show();
                        },
                        editProfileSuccess: (ConnectUser user, File? image) {
                          _userNameController.text = user.username;
                          // _emailController.text = user.email;
                          _birthDateController.text = user.birthDate;
                          EasyLoading.dismiss();
                        },
                        updateProfileSuceess: () {
                          EasyLoading.dismiss();
                          Navigator.pop(context);
                        },
                        updateProfileFailure: (NetworkExceptions error) {
                          EasyLoading.dismiss();
                          _showAlert(context);
                        },
                        orElse: () => null,
                      );
                    },
                    buildWhen:
                        (EditProfileState previous, EditProfileState current) {
                      return current.maybeWhen(
                        editProfileSuccess: (ConnectUser user, File? image) =>
                            true,
                        orElse: () => false,
                      );
                    },
                    builder: (BuildContext context, EditProfileState state) {
                      return state.maybeWhen(
                        editProfileSuccess: (ConnectUser user, File? image) {
                          return _buildScreenContent(context, user, image);
                        },
                        orElse: () => const SizedBox(),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Column _buildScreenContent(
    BuildContext context,
    ConnectUser user,
    File? image,
  ) {
    return Column(
      children: <Widget>[
        Flexible(
          fit: FlexFit.tight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 8.0),
              _buildBackButton(context),
              _buildProfileImage(context, user),
              const SizedBox(height: 20.0),
              _buildTextField(
                controller: _userNameController,
                hintText: 'Username',
                onChanged: (String value) {},
              ),
              // _buildTextField(
              //   controller: _emailController.text.isEmpty
              //       ? (_emailController..text = user.email)
              //       : _emailController,
              //   hintText: 'Email',
              //   onChanged: (String value) {},
              // ),
              _buildGender(user, context),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  _selectBirthDate(context);
                },
                child: _buildTextField(
                  controller: _birthDateController,
                  hintText: 'Date of birth',
                  onChanged: (String value) {},
                  enabled: false,
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
        _buildSaveButton(context, user, image),
        const SizedBox(height: 20.0),
      ],
    );
  }

  Padding _buildGender(ConnectUser user, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GenderRadioGroup(
        groupValue: Gender.values
            .firstWhere((Gender gender) => gender.title == user.gender),
        onChanged: (Gender? value) {
          if (value != null) {
            context.read<EditProfileBloc>().add(
                  EditProfileEvent.editProfile(
                    user: user.copyWith(gender: value.title),
                  ),
                );
          }
        },
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Icon(
            Icons.arrow_back_rounded,
            color: Colors.blueGrey,
          ),
        ),
      ),
    );
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now());
    if (date != null) {
      final String formatedDate = DateFormat.yMMMMd('en_US').format(date);
      _birthDateController.text = formatedDate.toString();
    }
  }

  Widget _buildProfileImage(BuildContext context, ConnectUser user) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: GestureDetector(
          onTap: () async {
            await _showBottomSheet(context, user);
          },
          child: Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100.0),
            ),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: getProfile(context, user),
          ),
        ),
      ),
    );
  }

  Widget getProfile(BuildContext context, ConnectUser user) {
    final String? profileUrl = user.profileUrl;
    if (profileUrl != null) {
      if (Uri.parse(profileUrl).isAbsolute) {
        return SizedBox(
          width: 180.0,
          height: 180.0,
          child: FadeInImage.memoryNetwork(
            placeholder: kTransparentImage,
            image: profileUrl,
            fit: BoxFit.cover,
          ),
        );
      }
      return Image.file(
        File(profileUrl),
        fit: BoxFit.cover,
        width: 180.0,
        height: 180.0,
      );
    }
    return CircleAvatar(
      backgroundColor: Colors.blueGrey[300],
      radius: 80,
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 120,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String? hintText,
    required Function(String) onChanged,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        enabled: enabled,
        style: TextStyles().latoTextStyle(),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyles().latoTextStyle(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.all(16),
          errorStyle: const TextStyle(
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, ConnectUser user, File? image) {
    return MaterialButton(
      onPressed: _userNameController.text.trim().isEmpty &&
              // _emailController.text.trim().isEmpty &&
              _birthDateController.text.trim().isEmpty
          ? null
          : () {
              context.read<EditProfileBloc>().add(
                    EditProfileEvent.updateProfile(
                      user: user.copyWith(
                        username: _userNameController.text.trim(),
                      ),
                      image: image,
                    ),
                  );
            },
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 10.0,
      ),
      color: Colors.blueGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 4.0,
      child: Text(
        'Save',
        style: TextStyles().varelaRoundTextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      ),
    );
  }

  Future<void> _showBottomSheet(BuildContext context, ConnectUser user) async {
    await showModalBottomSheet<Widget>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return Container(
          height: 90.0,
          padding: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildBottomSheetItem(
                icon: Icons.camera_alt,
                itemText: 'Camera',
                onTap: () async {
                  Navigator.pop(ctx);
                  final XFile? image =
                      await ImagePicker().pickImage(source: ImageSource.camera);
                  if (image != null) {
                    context.read<EditProfileBloc>().add(
                          EditProfileEvent.editProfile(
                            user: user.copyWith(profileUrl: image.path),
                            image: File(image.path),
                          ),
                        );
                  }
                },
              ),
              _buildBottomSheetItem(
                icon: Icons.image,
                itemText: 'Gallary',
                onTap: () async {
                  Navigator.pop(ctx);
                  final XFile? image = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    context
                        .read<EditProfileBloc>()
                        .add(EditProfileEvent.editProfile(
                          user: user.copyWith(profileUrl: image.path),
                          image: File(image.path),
                        ));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetItem({
    required IconData icon,
    required String itemText,
    required void Function() onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: <Widget>[
            Icon(
              icon,
              color: Colors.blue,
              size: 28.0,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                itemText,
                style: TextStyles().varelaRoundTextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAlert(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert'),
          content: const Text('Something went wrong. Please try again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
