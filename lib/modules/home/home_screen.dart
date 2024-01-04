import 'package:connect/models/api_handler/network_exceptions.dart';
import 'package:connect/models/connect_user.dart';
import 'package:connect/modules/chat/bloc/chat_list_bloc.dart';
import 'package:connect/modules/chat/chat_list_screen.dart';
import 'package:connect/modules/explore/bloc/explore_bloc.dart';
import 'package:connect/modules/explore/explore_screen.dart';
import 'package:connect/modules/home/bloc/home_bloc.dart';
import 'package:connect/modules/profile/profile_screen.dart';
import 'package:connect/repository/chat_repository.dart';
import 'package:connect/repository/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static MaterialPage<void> page() =>
      const MaterialPage<void>(child: HomeScreen());

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  static final List<Widget> _widgetOptions = <Widget>[
    BlocProvider<ExploreBloc>(
      create: (BuildContext context) => ExploreBloc(
        chatRepository: ChatRepository(),
      ),
      child: const ExploreScreen(),
    ),
    BlocProvider<ChatListBloc>(
      create: (BuildContext context) => ChatListBloc(
        userId: context.read<ConnectUser>().id,
        userRepository: UserRepository(),
        chatRepository: ChatRepository(),
      ),
      child: const ChatListScreen(),
    ),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (BuildContext context) => HomeBloc(
        userRepository: RepositoryProvider.of<UserRepository>(context),
        selectedTab: 1,
      )..add(HomeEvent.fetchUser(
          email: context.read<auth.User>().email!,
        )),
      child: Scaffold(
        body: BlocConsumer<HomeBloc, HomeState>(
          listener: (BuildContext context, HomeState state) {
            state.maybeWhen(
              loadInProgress: () => EasyLoading.show(),
              fetchUserSuccess: (ConnectUser user, int selectedTab) =>
                  EasyLoading.dismiss(),
              fetchUserFailure: (NetworkExceptions error) {
                EasyLoading.dismiss();
                _showAlert(context);
              },
              orElse: () => null,
            );
          },
          buildWhen: (HomeState previous, HomeState current) {
            return current.maybeWhen(
              fetchUserSuccess: (ConnectUser user, int selectedTab) => true,
              orElse: () => false,
            );
          },
          builder: (BuildContext context, HomeState state) {
            return state.maybeWhen(
              fetchUserSuccess: (ConnectUser user, int selectedTab) {
                return Provider<ConnectUser>.value(
                  value: user,
                  child: HomeScreen._widgetOptions.elementAt(selectedTab),
                );
              },
              orElse: () => const SizedBox(),
            );
          },
        ),
        bottomNavigationBar: BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (HomeState previous, HomeState current) {
            return current.maybeWhen(
              fetchUserSuccess: (ConnectUser user, int selectedTab) => true,
              orElse: () => false,
            );
          },
          builder: (BuildContext context, HomeState state) {
            return state.maybeWhen(
              fetchUserSuccess: (ConnectUser user, int selectedTab) {
                return BottomNavigationBar(
                  type: BottomNavigationBarType.shifting,
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.location_on_outlined,
                        size: selectedTab == 0 ? 32 : 24,
                      ),
                      label: 'Explore',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.chat_rounded,
                        size: selectedTab == 1 ? 32 : 24,
                      ),
                      label: 'Chat',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.account_circle_rounded,
                        size: selectedTab == 2 ? 32 : 24,
                      ),
                      label: 'Profile',
                    ),
                  ],
                  currentIndex: selectedTab,
                  selectedItemColor: Colors.grey[800],
                  unselectedItemColor: Colors.grey[500],
                  onTap: (int index) {
                    context.read<HomeBloc>().add(
                        HomeEvent.tabChanged(user: user, selectedTab: index));
                  },
                );
              },
              orElse: () => const SizedBox(),
            );
          },
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
