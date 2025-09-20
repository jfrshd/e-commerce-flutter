import 'package:flutter/material.dart';
import 'package:flutter_shop_app/constants.dart';
import 'package:flutter_shop_app/route/route_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_shop_app/core/di/injection.dart';
import 'package:flutter_shop_app/core/error/failures.dart';
import 'package:flutter_shop_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_shop_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_shop_app/screens/auth/views/email_verification_screen.dart';

import 'components/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    print('🚀 LoginScreen: Initializing AuthBloc...');
    _authBloc = AuthBloc(authRepository: getIt<AuthRepository>());
    print('✅ AuthBloc initialized successfully');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return BlocProvider.value(
      value: _authBloc,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          print('🔄 BLoC STATE CHANGED: ${state.runtimeType}');
          if (state is AuthSuccess) {
            print('✅ AuthSuccess - User logged in successfully!');
            print('✅ User: ${state.user.email}');
            print('🔍 Email verified: ${state.user.isEmailVerified}');

            if (!state.user.isEmailVerified) {
              print(
                  '❌ Email not verified - redirecting to verification screen');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please verify your email before logging in.'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ),
              );
              // Set email in BLoC state before navigation
              print(
                  '🔍 LoginScreen: Dispatching SetEmailForVerification event');
              print('🔍 LoginScreen: Email to set: ${state.user.email}');
              context
                  .read<AuthBloc>()
                  .add(SetEmailForVerification(email: state.user.email));
              print(
                  '🔍 LoginScreen: Event dispatched, navigating to email verification screen');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: _authBloc,
                    child: const EmailVerificationScreen(),
                  ),
                ),
              );
            } else {
              print('✅ Email verified - navigating to home screen');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Welcome back! Login successful.'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
              Navigator.pushNamedAndRemoveUntil(context, entryPointScreenRoute,
                  ModalRoute.withName(logInScreenRoute));
            }
          } else if (state is AuthLoading) {
            print('⏳ AuthLoading - API call in progress...');
          } else if (state is AuthFailure) {
            print('❌ AuthFailure - ${state.failure.message}');
            print('❌ AuthFailure - Failure type: ${state.failure.runtimeType}');
            String errorMessage = state.failure.message;

            // Handle email verification required (403 status code)
            print(
                '🔍 LoginScreen: ========== EMAIL VERIFICATION CHECK START ==========');
            print('🔍 LoginScreen: Checking if failure is ServerFailure...');
            print(
                '🔍 LoginScreen: Failure is ServerFailure: ${state.failure is ServerFailure}');
            print('🔍 LoginScreen: Failure type: ${state.failure.runtimeType}');
            print('🔍 LoginScreen: Failure message: ${state.failure.message}');

            if (state.failure is ServerFailure) {
              final serverFailure = state.failure as ServerFailure;
              print('🔍 LoginScreen: ServerFailure detected!');
              print(
                  '🔍 LoginScreen: ServerFailure statusCode: ${serverFailure.statusCode}');
              print(
                  '🔍 LoginScreen: ServerFailure statusCode type: ${serverFailure.statusCode.runtimeType}');
              print(
                  '🔍 LoginScreen: ServerFailure statusCode == 403: ${serverFailure.statusCode == 403}');
              print('🔍 LoginScreen: Checking if statusCode == 403...');

              if (serverFailure.statusCode == 403) {
                print(
                    '🔍 LoginScreen: ✅ EMAIL VERIFICATION REQUIRED (403) - REDIRECTING TO VERIFICATION SCREEN');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Please verify your email before logging in.'),
                    backgroundColor: Colors.orange,
                  ),
                );
                // Extract email from the form and redirect to verification
                final email = _emailController.text.trim();
                if (email.isNotEmpty) {
                  print(
                      '🔍 LoginScreen: Dispatching SetEmailForVerification event for: $email');
                  context
                      .read<AuthBloc>()
                      .add(SetEmailForVerification(email: email));
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: _authBloc,
                        child: const EmailVerificationScreen(),
                      ),
                    ),
                  );
                } else {
                  print(
                      '❌ LoginScreen: No email found in form for verification redirect');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter your email and try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                return; // Exit early to avoid showing error snackbar
              } else {
                print(
                    '❌ LoginScreen: StatusCode is not 403, statusCode: ${serverFailure.statusCode}');
              }
            } else {
              print(
                  '❌ LoginScreen: Failure is not ServerFailure, type: ${state.failure.runtimeType}');
            }
            print(
                '🔍 LoginScreen: ========== EMAIL VERIFICATION CHECK END ==========');

            // Make error messages more user-friendly
            if (errorMessage
                .contains('No account found with this email address')) {
              errorMessage =
                  'No account found with this email address. Please check your email or sign up for a new account.';
            } else if (errorMessage.contains('Incorrect password')) {
              errorMessage =
                  'Incorrect password. Please check your password and try again.';
            } else if (errorMessage.contains('Invalid credentials')) {
              errorMessage =
                  'Invalid email or password. Please check your credentials and try again.';
            } else if (errorMessage.contains('User not found')) {
              errorMessage =
                  'No account found with this email address. Please sign up first.';
            } else if (errorMessage.contains('No internet connection')) {
              errorMessage =
                  'Please check your internet connection and try again.';
            } else if (errorMessage.contains('Request timed out')) {
              errorMessage =
                  'The request is taking too long. Please try again.';
            } else if (errorMessage.contains('Connection refused')) {
              errorMessage =
                  'Unable to connect to the server. Please check your internet connection and try again.';
            } else if (errorMessage.contains('Something went wrong')) {
              errorMessage =
                  'Login failed. Please check your credentials and try again.';
            }

            print('❌ AuthFailure - Final error message: $errorMessage');

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  "assets/images/login_dark.png",
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome back!",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: defaultPadding / 2),
                      const Text(
                        "Log in with your data that you intered during your registration.",
                      ),
                      const SizedBox(height: defaultPadding),
                      LogInForm(
                        formKey: _formKey,
                        emailController: _emailController,
                        passwordController: _passwordController,
                      ),
                      Align(
                        child: TextButton(
                          child: const Text("Forgot password"),
                          onPressed: () {
                            Navigator.pushNamed(
                                context, passwordRecoveryScreenRoute);
                          },
                        ),
                      ),
                      SizedBox(
                        height: size.height > 700
                            ? size.height * 0.1
                            : defaultPadding,
                      ),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: state is AuthLoading
                                ? null
                                : () {
                                    print('🔥 LOGIN BUTTON PRESSED');
                                    print('Email: ${_emailController.text}');
                                    print(
                                        'Password: ${_passwordController.text}');

                                    if (_formKey.currentState!.validate()) {
                                      print('✅ Form validation passed');
                                      print(
                                          '🚀 Dispatching LoginRequested event...');

                                      _authBloc.add(
                                        LoginRequested(
                                          email: _emailController.text.trim(),
                                          password: _passwordController.text,
                                        ),
                                      );

                                      print(
                                          '✅ LoginRequested event dispatched to BLoC');
                                    } else {
                                      print('❌ Form validation failed');
                                    }
                                  },
                            child: state is AuthLoading
                                ? const CircularProgressIndicator()
                                : const Text("Log in"),
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, signUpScreenRoute);
                            },
                            child: const Text("Sign up"),
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
