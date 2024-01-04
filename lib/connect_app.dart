import 'package:connect/modules/authentication/bloc/authentication_bloc.dart';
import 'package:connect/modules/home/home_screen.dart';
import 'package:connect/modules/login/login_screen.dart';
import 'package:connect/repository/authentication_repository.dart';
import 'package:connect/repository/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

class ConnectApp extends StatelessWidget {
  const ConnectApp({
    Key? key,
    required this.authenticationRepository,
    required this.userRepository,
  }) : super(key: key);

  final AuthenticationRepository authenticationRepository;
  final UserRepository userRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthenticationRepository>.value(
      value: authenticationRepository,
      child: BlocProvider<AuthenticationBloc>(
        create: (BuildContext context) => AuthenticationBloc(
          authenticationRepository: authenticationRepository,
        ),
        child: AppView(
          userRepository: userRepository,
        ),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({
    Key? key,
    required this.userRepository,
  }) : super(key: key);

  final UserRepository userRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (BuildContext context, AuthenticationState state) {
          switch (state.status) {
            case AuthenticationStatus.authenticated:
              return MultiProvider(
                providers: <SingleChildWidget>[
                  RepositoryProvider<UserRepository>.value(
                    value: userRepository,
                  ),
                  Provider<auth.User>.value(
                    value: state.user!,
                  ),
                ],
                child: const HomeScreen(),
              );
            case AuthenticationStatus.unauthenticated:
              return const LoginScreen();
            case AuthenticationStatus.unknown:
              return const LoginScreen();
          }
        },
      ),
      builder: EasyLoading.init(),
    );
  }
}
