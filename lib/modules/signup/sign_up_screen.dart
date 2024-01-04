import 'package:connect/common/constants.dart';
import 'package:connect/models/api_handler/network_exceptions.dart';
import 'package:connect/modules/signup/bloc/signup_bloc.dart';
import 'package:connect/repository/authentication_repository.dart';
import 'package:connect/utils/text_styles.dart';
import 'package:connect/widgets/radio_group.dart';
import 'package:connect/widgets/text_widet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  Gender _selectedGender = Gender.male;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignupBloc>(
      create: (BuildContext context) => SignupBloc(
        authenticationRepository:
            RepositoryProvider.of<AuthenticationRepository>(context),
      ),
      child: Scaffold(
        key: _key,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: BlocConsumer<SignupBloc, SignupState>(
                  listener: (BuildContext context, SignupState state) {
                    state.status.maybeWhen(
                      loading: () => EasyLoading.show(),
                      success: (dynamic data) {
                        EasyLoading.dismiss();
                        Navigator.pop(context, true);
                      },
                      exception: (NetworkExceptions exception) {
                        EasyLoading.dismiss();
                        _showAlert(
                          context: context,
                          alertMessage: _getErrorMessage(exception),
                        );
                      },
                      error: (String error) {
                        EasyLoading.dismiss();
                        _showAlert(
                          context: context,
                          alertMessage:
                              'Something went wrong. Please try again.',
                        );
                      },
                      orElse: () => null,
                    );
                  },
                  builder: (BuildContext context, SignupState state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildHeader(),
                        const SizedBox(height: 30),
                        _buildTextField(
                          controller: _userNameController,
                          hintText: 'Username',
                          onChanged: (String value) {
                            context.read<SignupBloc>().add(
                                SignupEvent.updateUser(
                                    user:
                                        state.user.copyWith(username: value)));
                          },
                        ),
                        _buildTextField(
                          controller: _firstNameController,
                          hintText: 'First Name',
                          onChanged: (String value) {
                            context.read<SignupBloc>().add(
                                SignupEvent.updateUser(
                                    user:
                                        state.user.copyWith(firstName: value)));
                          },
                        ),
                        _buildTextField(
                          controller: _lastNameController,
                          hintText: 'Last Name',
                          onChanged: (String value) {
                            context.read<SignupBloc>().add(
                                SignupEvent.updateUser(
                                    user:
                                        state.user.copyWith(lastName: value)));
                          },
                        ),
                        GenderRadioGroup(
                          groupValue: _selectedGender,
                          onChanged: (Gender? value) {
                            if (value != null) {
                              _selectedGender = value;
                              context.read<SignupBloc>().add(
                                  SignupEvent.updateUser(
                                      user: state.user
                                          .copyWith(gender: value.title)));
                            }
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          onTap: () {
                            _selectBirthDate(context, state);
                          },
                          child: _buildTextField(
                            controller: _birthDateController,
                            hintText: 'Date of birth',
                            onChanged: (String value) {},
                            enabled: false,
                          ),
                        ),
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'Email',
                          onChanged: (String value) {
                            context.read<SignupBloc>().add(
                                SignupEvent.updateUser(
                                    user: state.user.copyWith(email: value)));
                          },
                        ),
                        _buildTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          onChanged: (String value) {
                            context.read<SignupBloc>().add(
                                SignupEvent.updateUser(
                                    user:
                                        state.user.copyWith(password: value)));
                          },
                          obscureText: !_isPasswordVisible,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              color: _isPasswordVisible
                                  ? Colors.blueGrey
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        const Spacer(),
                        _buildSignUpButton(context, state),
                        _sizedBox(height: 20),
                        _buildSignInText(context),
                        _sizedBox(height: 20),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sizedBox({double? height, double? width}) {
    return SizedBox(
      height: height,
      width: width,
    );
  }

  Widget _buildHeader() {
    return TextWidget().varelaRoundTextWidget(
      text: 'Lets Connect',
      textAlign: TextAlign.left,
      color: const Color(0xff3d414a),
      fontSize: 28.0,
      fontWeight: FontWeight.w600,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String? hintText,
    required Function(String) onChanged,
    bool obscureText = false,
    bool enabled = true,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        obscureText: obscureText,
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
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildSignUpButton(BuildContext context, SignupState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: state.isFormValid
              ? () {
                  context.read<SignupBloc>().add(SignupEvent.signupSubmitted(
                      user: state.user.copyWith(
                          createdAt:
                              DateTime.now().toUtc().microsecondsSinceEpoch)));
                }
              : null,
          style: ButtonStyle(
            elevation: MaterialStateProperty.all<double>(4.0),
            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.symmetric(
                horizontal: 30.0,
              ),
            ),
            backgroundColor: MaterialStateProperty.all<Color>(
              Colors.blueGrey,
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
                side: const BorderSide(color: Colors.blueGrey),
              ),
            ),
          ),
          child: TextWidget().varelaRoundTextWidget(
            text: 'Sign Up',
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSignInText(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextWidget().latoTextWidget(
          text: 'Already have an account?',
        ),
        const SizedBox(
          width: 4.0,
        ),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child:
              TextWidget().latoTextWidget(text: 'Sign in', color: Colors.blue),
        ),
      ],
    );
  }

  Future<void> _selectBirthDate(BuildContext context, SignupState state) async {
    final DateTime? date = await showDatePicker(
        context: context,
        initialDate: DateTime(2010, 1, 1),
        firstDate: DateTime(1950, 1, 1),
        lastDate: DateTime.now());
    if (date != null) {
      final String formatedDate = DateFormat.yMMMMd('en_US').format(date);
      _birthDateController.text = formatedDate.toString();
      context.read<SignupBloc>().add(SignupEvent.updateUser(
          user: state.user.copyWith(birthDate: _birthDateController.text)));
    }
  }

  String _getErrorMessage(NetworkExceptions exception) {
    final String error = NetworkExceptions.getErrorMessage(exception);
    late String alertMessage;
    if (error == 'email-already-in-use') {
      alertMessage = 'The email address is already in use by another account.';
    } else if (error == 'invalid-email') {
      alertMessage = 'The email you entered is invalid';
    } else if (error == 'weak-password') {
      alertMessage = 'The password provided is too weak.';
    } else {
      alertMessage = 'Something went wrong. Please try again.';
    }
    return alertMessage;
  }

  void _showAlert({
    required BuildContext context,
    required String alertMessage,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert'),
          content: Text(alertMessage),
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
