import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_shop_app/constants.dart';
import 'package:flutter_shop_app/core/di/injection.dart';
import 'package:flutter_shop_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_shop_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_shop_app/screens/auth/views/otp_screen.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(authRepository: getIt<AuthRepository>());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          print(
              '🔍 PasswordRecoveryScreen.listener: BLoC state changed: ${state.runtimeType}');
          print(
              '🔍 PasswordRecoveryScreen.listener: Current state details: $state');

          if (state is RequestPasswordResetCodeSuccess) {
            final email = _emailController.text.trim();
            print(
                '🔍 PasswordRecoveryScreen.listener: RequestPasswordResetCodeSuccess received');
            print(
                '🔍 PasswordRecoveryScreen.listener: Email from controller: $email');
            print(
                '🔍 PasswordRecoveryScreen.listener: Dispatching SetEmailForVerification event');
            context.read<AuthBloc>().add(SetEmailForVerification(email: email));
            print(
                '🔍 PasswordRecoveryScreen.listener: Event dispatched, navigating to OTP screen');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: _authBloc,
                  child: const OtpScreen(),
                ),
              ),
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure.message),
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
                        'Forgot Password',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: defaultPadding / 2),
                      Text(
                          'Enter your email address and we will send you a verification code'),
                      const SizedBox(height: defaultPadding),
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _emailController,
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Enter your email';
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            prefixIcon: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: defaultPadding * 0.75),
                              child: SvgPicture.asset(
                                "assets/icons/Message.svg",
                                height: 24,
                                width: 24,
                                colorFilter: ColorFilter.mode(
                                  Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color!
                                      .withOpacity(0.3),
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: defaultPadding * 2),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: state is AuthLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      final email =
                                          _emailController.text.trim();
                                      context.read<AuthBloc>().add(
                                            RequestPasswordResetCodeRequested(
                                                email: email),
                                          );
                                    }
                                  },
                            child: state is AuthLoading
                                ? const CircularProgressIndicator()
                                : const Text('Send Verification Code'),
                          );
                        },
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
