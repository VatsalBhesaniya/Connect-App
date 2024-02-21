import 'package:connect/models/api_handler/network_exceptions.dart';
import 'package:connect/models/connect_user.dart';
import 'package:connect/modules/edit_profile/bloc/edit_profile_bloc.dart';
import 'package:connect/modules/edit_profile/edit_profile_screen.dart';
import 'package:connect/modules/profile/bloc/profile_bloc.dart';
import 'package:connect/repository/authentication_repository.dart';
import 'package:connect/repository/user_repository.dart';
import 'package:connect/utils/text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:transparent_image/transparent_image.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (BuildContext context) => ProfileBloc(
        userRepository: RepositoryProvider.of<UserRepository>(context),
        authenticationRepository: RepositoryProvider.of<AuthenticationRepository>(context),
      )..add(
          ProfileEvent.fetchUser(
            email: context.read<auth.User>().email!,
          ),
        ),
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SizedBox(
                height: constraints.maxHeight,
                child: BlocConsumer<ProfileBloc, ProfileState>(
                  listener: (BuildContext context, ProfileState state) {
                    state.maybeWhen(
                      loadInProgress: () => EasyLoading.show(),
                      fetchUserSuccess: (ConnectUser user) {
                        EasyLoading.dismiss();
                      },
                      fetchUserFailure: (NetworkExceptions error) {
                        EasyLoading.dismiss();
                        _showAlert(context);
                      },
                      logoutFailure: (NetworkExceptions error) {
                        EasyLoading.dismiss();
                        _showAlert(context);
                      },
                      deleteAccountSuccess: () => Navigator.of(context).pop(),
                      deleteAccountFailure: (NetworkExceptions error) {
                        EasyLoading.dismiss();
                        _showAlert(context);
                      },
                      orElse: () => null,
                    );
                  },
                  buildWhen: (ProfileState previous, ProfileState current) {
                    return current.maybeWhen(
                      fetchUserFailure: (NetworkExceptions error) => false,
                      orElse: () => true,
                    );
                  },
                  builder: (BuildContext context, ProfileState state) {
                    return state.maybeWhen(
                      initial: () {
                        EasyLoading.show();
                        return const SizedBox();
                      },
                      fetchUserSuccess: (ConnectUser user) {
                        return Column(
                          children: <Widget>[
                            Flexible(
                              fit: FlexFit.tight,
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const SizedBox(height: 8.0),
                                    _buildEditProfileButton(context, user),
                                    _buildProfileImage(context, user),
                                    const SizedBox(height: 10.0),
                                    _buildUserName(user.username),
                                    const SizedBox(height: 20.0),
                                    _buildProfileItem(Icons.mail_outline_rounded, user.email),
                                    const SizedBox(height: 10.0),
                                    _buildProfileItem(Icons.person_outline_rounded, user.gender),
                                    const SizedBox(height: 10.0),
                                    _buildProfileItem(Icons.today_rounded, user.birthDate),
                                    const SizedBox(height: 20.0),
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                _buildDeleteAccountButton(context),
                                const SizedBox(width: 20.0),
                                _buildLogoutButton(context),
                              ],
                            ),
                            const SizedBox(height: 20.0),
                          ],
                        );
                      },
                      orElse: () => const SizedBox(),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEditProfileButton(BuildContext context, ConnectUser user) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () async {
          await Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext ctx) {
                return BlocProvider<EditProfileBloc>(
                  create: (_) => EditProfileBloc(
                    userRepository: RepositoryProvider.of<UserRepository>(context),
                  )..add(EditProfileEvent.editProfile(user: user)),
                  child: EditProfileScreen(),
                );
              },
            ),
          );
          context.read<ProfileBloc>().add(
                ProfileEvent.fetchUser(email: context.read<auth.User>().email!),
              );
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Icon(
            Icons.edit_rounded,
            color: Colors.blueGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(BuildContext context, ConnectUser user) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Card(
          elevation: 8.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.0),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: getProfile(context, user),
        ),
      ),
    );
  }

  Widget getProfile(BuildContext context, ConnectUser user) {
    if (user.profileUrl != null) {
      return SizedBox(
        width: 180.0,
        height: 180.0,
        child: FadeInImage.memoryNetwork(
          placeholder: kTransparentImage,
          image: user.profileUrl ?? '',
          fit: BoxFit.cover,
        ),
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

  Widget _buildUserName(String userName) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          userName,
          style: TextStyles().varelaRoundTextStyle(fontSize: 22.0),
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String discription) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Icon(
            icon,
            color: Colors.blueGrey,
          ),
          const SizedBox(width: 10.0),
          Expanded(
            flex: 1,
            child: Text(
              discription,
              style: TextStyles().workSansTextStyle(fontSize: 18.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        context.read<ProfileBloc>().add(const ProfileEvent.logoutSubmitted());
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
        'Logout',
        style: TextStyles().varelaRoundTextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        _showDeleteAccountDialog(context);
      },
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 10.0,
      ),
      color: Colors.redAccent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 4.0,
      child: Text(
        'Delete Account',
        style: TextStyles().varelaRoundTextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            style: TextStyles().latoTextStyle(),
            decoration: InputDecoration(
              hintText: 'Password',
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
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<ProfileBloc>().add(
                      ProfileEvent.deleteAccountSubmitted(
                        user: context.read<ConnectUser>(),
                        password: _passwordController.text.trim(),
                      ),
                    );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
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
