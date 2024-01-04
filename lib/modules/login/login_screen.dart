import 'package:connect/models/api_handler/network_exceptions.dart';
import 'package:connect/modules/forgot_password/forgot_password_screen.dart';
import 'package:connect/modules/login/bloc/login_bloc.dart';
import 'package:connect/modules/signup/sign_up_screen.dart';
import 'package:connect/repository/authentication_repository.dart';
import 'package:connect/utils/text_styles.dart';
import 'package:connect/widgets/text_widet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static MaterialPage<void> page() =>
      const MaterialPage<void>(child: LoginScreen());

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: BlocProvider<LoginBloc>(
        create: (BuildContext context) => LoginBloc(
          authenticationRepository:
              RepositoryProvider.of<AuthenticationRepository>(context),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: BlocConsumer<LoginBloc, LoginState>(
                      listener: (BuildContext context, LoginState state) {
                        state.status.maybeWhen(
                          loading: () {
                            EasyLoading.show();
                          },
                          success: (dynamic data) {
                            EasyLoading.dismiss();
                            if (data == 'Send email verification successful') {
                              showAlert(
                                context: context,
                                title: 'Verify your Email Address',
                                alertMessage:
                                    'A new verification link has been sent to your email address.',
                              );
                            }
                            // if (data == 'Login Successful') {
                            //   Navigator.pushAndRemoveUntil<void>(
                            //     context,
                            //     MaterialPageRoute<void>(
                            //         builder: (BuildContext context) =>
                            //             const HomeScreen()),
                            //     (Route<dynamic> route) => false,
                            //   );
                            // }
                          },
                          exception: (NetworkExceptions exception) {
                            EasyLoading.dismiss();
                            showAlert(
                              context: context,
                              alertMessage: _getErrorMessage(exception),
                            );
                          },
                          orElse: () => null,
                        );
                      },
                      builder: (BuildContext context, LoginState state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const SizedBox(height: 30),
                            _buildHeader(),
                            const SizedBox(height: 30),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  _buildTextField(
                                    controller: _emailController,
                                    hintText: 'Email',
                                    onChanged: (String value) {
                                      context.read<LoginBloc>().add(
                                            LoginEvent.usernameChanged(
                                              email: value,
                                            ),
                                          );
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTextField(
                                    controller: _passwordController,
                                    hintText: 'Password',
                                    onChanged: (String value) {
                                      context.read<LoginBloc>().add(
                                            LoginEvent.passwordChanged(
                                              password: value,
                                            ),
                                          );
                                    },
                                    obscureText: !_isPasswordVisible,
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                        setState(() {});
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
                                  _buildForgotPassword(context),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildSignInButton(context),
                            _buildSignUpText(context),
                            const SizedBox(height: 50),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: TextWidget().varelaRoundTextWidget(
        text: 'Welcome To\nConnect',
        textAlign: TextAlign.left,
        color: const Color(0xff3d414a),
        fontSize: 28.0,
        fontWeight: FontWeight.w600,
      ),
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

  Widget _buildForgotPassword(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () async {
            final bool? result = await Navigator.push(
              context,
              MaterialPageRoute<bool>(
                builder: (BuildContext context) => ForgotPasswordScreen(),
              ),
            );
            if (result != null && result) {
              await showAlert(
                context: context,
                title: 'Reset password',
                alertMessage:
                    'Please check your email and click on the recieved link to reset a password.',
              );
            }
          },
          child: Text(
            'Forgot password?',
            style: TextStyles().latoTextStyle(
              color: Colors.lightBlue,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: _emailController.text.trim().isNotEmpty &&
                    _passwordController.text.trim().isNotEmpty
                ? () async {
                    FocusScope.of(context).unfocus();
                    context.read<LoginBloc>().add(
                          LoginEvent.loginSubmitted(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                          ),
                        );
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
              text: 'Sign In',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpText(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextWidget().latoTextWidget(
          text: "Don't have an account?",
        ),
        const SizedBox(
          width: 4.0,
        ),
        GestureDetector(
          onTap: () async {
            final bool? result = await Navigator.push(
              context,
              MaterialPageRoute<bool>(
                builder: (BuildContext context) => const SignupScreen(),
              ),
            );
            if (result != null && result) {
              await showAlert(
                context: context,
                title: 'Verify your Email Address',
                alertMessage:
                    'A verification link has been sent to your email address. Please verify your email.',
              );
            }
          },
          child:
              TextWidget().latoTextWidget(text: 'Sign up', color: Colors.blue),
        ),
      ],
    );
  }

  String _getErrorMessage(NetworkExceptions exception) {
    final String error = NetworkExceptions.getErrorMessage(exception);
    late String alertMessage;
    if (error == 'Email is not verified') {
      alertMessage =
          '''Please verify your email from verification link sent to your email address. If you didn't receive email click on Resend Link to resend the verification email.''';
    } else if (error == 'user-not-found') {
      alertMessage = 'No user found with this email.';
    } else if (error == 'wrong-password') {
      alertMessage = 'Password is invalid.';
    } else {
      alertMessage = 'Something went wrong. Please try again.';
    }
    return alertMessage;
  }

  Future<void> showAlert({
    required BuildContext context,
    String? title,
    String? alertMessage,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(
          title ?? 'Alert',
          style: TextStyles().varelaRoundTextStyle(),
        ),
        content: alertMessage != null
            ? Text(
                alertMessage,
                style: TextStyles().varelaRoundTextStyle(),
              )
            : null,
        actions: <Widget>[
          alertMessage ==
                  '''Please verify your email from verification link sent to your email address. If you didn't receive email click on Resend Link to resend the verification email.'''
              ? TextButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    context
                        .read<LoginBloc>()
                        .add(const LoginEvent.sendVerificationEmail());
                  },
                  child: Text(
                    'Resend link',
                    style: TextStyles().varelaRoundTextStyle(),
                  ),
                )
              : const SizedBox(),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: Text(
              'OK',
              style: TextStyles().varelaRoundTextStyle(),
            ),
          ),
        ],
      ),
    );
  }
}
