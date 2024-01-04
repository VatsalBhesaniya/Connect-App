import 'package:connect/models/api_handler/network_exceptions.dart';
import 'package:connect/modules/forgot_password/bloc/forgot_password_bloc.dart';
import 'package:connect/repository/authentication_repository.dart';
import 'package:connect/utils/text_styles.dart';
import 'package:connect/widgets/text_widet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({Key? key}) : super(key: key);
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ForgotPasswordBloc>(
      create: (BuildContext context) => ForgotPasswordBloc(
        authenticationRepository: context.read<AuthenticationRepository>(),
      ),
      child: SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildHeader(),
                BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
                  listener: (BuildContext context, ForgotPasswordState state) {
                    state.maybeWhen(
                      loadInProgress: () {
                        EasyLoading.show();
                      },
                      emailValidationSuccess: (bool isEmailValid) {
                        EasyLoading.dismiss();
                      },
                      resendEmailSuccess: () {
                        EasyLoading.dismiss();
                        Navigator.pop(context, true);
                      },
                      resendEmailFailure: (NetworkExceptions exception) {
                        EasyLoading.dismiss();
                        _showAlert(context, _getErrorMessage(exception));
                      },
                      orElse: () => null,
                    );
                  },
                  buildWhen: (ForgotPasswordState previous,
                      ForgotPasswordState current) {
                    return current.maybeWhen(
                      emailValidationSuccess: (bool isEmailValid) => true,
                      orElse: () => false,
                    );
                  },
                  builder: (BuildContext context, ForgotPasswordState state) {
                    return state.maybeWhen(
                      initial: () {
                        context.read<ForgotPasswordBloc>().add(
                            const ForgotPasswordEvent.emailChanged(email: ''));
                        return const SizedBox();
                      },
                      emailValidationSuccess: (bool isEmailValid) {
                        return _buildScreen(
                          context: context,
                          isEmailValid: isEmailValid,
                        );
                      },
                      orElse: () => const SizedBox(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column _buildScreen({
    required BuildContext context,
    required bool isEmailValid,
  }) {
    return Column(
      children: <Widget>[
        _buildTextField(
          controller: _emailController,
          hintText: 'Email',
          onChanged: (String value) {
            context
                .read<ForgotPasswordBloc>()
                .add(ForgotPasswordEvent.emailChanged(email: value));
          },
        ),
        _buildSendButton(context, isEmailValid),
        _buildRememberPassword(context),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: <Widget>[
        TextWidget().varelaRoundTextWidget(
          text: 'Forgot your password?',
          textAlign: TextAlign.center,
          color: const Color(0xff3d414a),
          fontSize: 24.0,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(
          height: 20,
        ),
        TextWidget().latoTextWidget(
          text:
              'Enter your registerd email below to recieve password reset link',
          textAlign: TextAlign.center,
          color: Colors.grey[600],
          fontSize: 16.0,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required Function(String) onChanged,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
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
    );
  }

  Widget _buildRememberPassword(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextWidget().latoTextWidget(
          text: 'Remember password?',
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

  Widget _buildSendButton(BuildContext context, bool isEmailValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: isEmailValid
                ? () async {
                    context.read<ForgotPasswordBloc>().add(
                        ForgotPasswordEvent.resendEmailSubmitted(
                            email: _emailController.text.trim()));
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
              text: 'Send',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getErrorMessage(NetworkExceptions exception) {
    final String error = NetworkExceptions.getErrorMessage(exception);
    late String alertMessage;
    if (error == 'No user found with this email.') {
      alertMessage = 'Invalid email';
    } else {
      alertMessage = 'Something went wrong. Please try again.';
    }
    return alertMessage;
  }

  void _showAlert(BuildContext context, String error) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert'),
          content: Text(error),
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
