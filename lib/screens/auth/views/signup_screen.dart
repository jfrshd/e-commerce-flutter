import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_shop_app/screens/auth/views/components/sign_up_form.dart';
import 'package:flutter_shop_app/route/route_constants.dart';
import 'package:flutter_shop_app/core/di/injection.dart';
import 'package:flutter_shop_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_shop_app/features/auth/presentation/bloc/auth_bloc.dart';

import '../../../constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    print('🚀 SignUpScreen: Initializing AuthBloc...');
    _authBloc = AuthBloc(authRepository: getIt<AuthRepository>());
    print('✅ SignUpScreen: AuthBloc initialized successfully');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          print('🔄 BLoC STATE CHANGED: ${state.runtimeType}');
          if (state is AuthSuccess) {
            print('✅ AuthSuccess - User signed up successfully!');
            print('✅ User: ${state.user.email}');
            print('🔍 Email verified: ${state.user.isEmailVerified}');
            print('📧 Navigating to email verification screen...');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Account created! Please verify your email to continue.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 2),
              ),
            );
            // Set email in BLoC state before navigation
            print('🔍 SignupScreen: Dispatching SetEmailForVerification event');
            print('🔍 SignupScreen: Email to set: ${state.user.email}');
            context
                .read<AuthBloc>()
                .add(SetEmailForVerification(email: state.user.email));
            print(
                '🔍 SignupScreen: Event dispatched, navigating to email verification screen');
            Navigator.pushNamed(
              context,
              emailVerificationScreenRoute,
            );
          } else if (state is AuthLoading) {
            print('⏳ AuthLoading - API call in progress...');
          } else if (state is AuthFailure) {
            print('❌ AuthFailure - ${state.failure.message}');
            print('❌ AuthFailure - Failure type: ${state.failure.runtimeType}');
            String errorMessage = state.failure.message;

            // Make error messages more user-friendly
            if (errorMessage.contains(
                'An account with this email address already exists')) {
              errorMessage =
                  'An account with this email address already exists. Please try logging in instead.';
            } else if (errorMessage.contains('Invalid email')) {
              errorMessage = 'Please enter a valid email address.';
            } else if (errorMessage.contains('Password too weak')) {
              errorMessage =
                  'Password is too weak. Please choose a stronger password.';
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
                  'Signup failed. Please check your information and try again.';
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
                  "assets/images/signUp_dark.png",
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Let's get started!",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: defaultPadding / 2),
                      const Text(
                        "Please enter your valid data in order to create an account.",
                      ),
                      const SizedBox(height: defaultPadding),
                      SignUpForm(
                        formKey: _formKey,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        firstNameController: _firstNameController,
                        lastNameController: _lastNameController,
                        phoneController: _phoneController,
                      ),
                      const SizedBox(height: defaultPadding * 2),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: state is AuthLoading
                                ? null
                                : () {
                                    print('🔥 SIGNUP BUTTON PRESSED');
                                    print('Email: ${_emailController.text}');
                                    print(
                                        'Password: ${_passwordController.text}');
                                    print(
                                        'First Name: ${_firstNameController.text}');
                                    print(
                                        'Last Name: ${_lastNameController.text}');
                                    print('Phone: ${_phoneController.text}');

                                    if (_formKey.currentState!.validate()) {
                                      print('✅ Form validation passed');
                                      print(
                                          '🚀 Dispatching SignupRequested event...');

                                      _authBloc.add(
                                        SignupRequested(
                                          email: _emailController.text.trim(),
                                          password: _passwordController.text,
                                          firstName:
                                              _firstNameController.text.trim(),
                                          lastName:
                                              _lastNameController.text.trim(),
                                          phone: _phoneController.text.trim(),
                                          acceptTerms:
                                              true, // Always true since we removed the checkbox
                                        ),
                                      );

                                      print(
                                          '✅ SignupRequested event dispatched to BLoC');
                                    } else {
                                      print('❌ Form validation failed');
                                    }
                                  },
                            child: state is AuthLoading
                                ? const CircularProgressIndicator()
                                : const Text("Continue"),
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Do you have an account?"),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, logInScreenRoute);
                            },
                            child: const Text("Log in"),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
