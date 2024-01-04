import 'package:connect/modules/home/home_screen.dart';
import 'package:connect/modules/login/login_screen.dart';
import 'package:connect/repository/authentication_repository.dart';
import 'package:flutter/material.dart';

List<MaterialPage<void>> onGenerateAppViewPages(
    AuthenticationStatus state, List<Page<dynamic>> pages) {
  switch (state) {
    case AuthenticationStatus.authenticated:
      return <MaterialPage<void>>[HomeScreen.page()];
    case AuthenticationStatus.unauthenticated:
      return <MaterialPage<void>>[LoginScreen.page()];
    case AuthenticationStatus.unknown:
      return <MaterialPage<void>>[LoginScreen.page()];
  }
}
