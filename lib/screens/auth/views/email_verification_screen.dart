import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_shop_app/constants.dart';
import 'package:flutter_shop_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_shop_app/route/route_constants.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  String _email = '';
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    print('🔍 EmailVerificationScreen.initState: Called');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('🔍 EmailVerificationScreen.didChangeDependencies: Called');
    _authBloc = context.read<AuthBloc>();
    print(
        '🔍 EmailVerificationScreen.didChangeDependencies: Got AuthBloc from context');
    print(
        '🔍 EmailVerificationScreen.didChangeDependencies: Current BLoC state: ${_authBloc.state.runtimeType}');
    print(
        '🔍 EmailVerificationScreen.didChangeDependencies: BLoC state details: ${_authBloc.state}');

    final currentState = _authBloc.state;
    if (currentState is EmailSetForVerification && _email.isEmpty) {
      setState(() {
        _email = currentState.email;
      });
      print(
          '🔍 EmailVerificationScreen.didChangeDependencies: Email set from BLoC state: $_email');

      // Automatically request verification code when email is set
      print(
          '🔍 EmailVerificationScreen.didChangeDependencies: Automatically requesting verification code for: ${currentState.email}');
      _authBloc.add(
        RequestEmailVerificationCodeRequested(email: currentState.email),
      );
    } else {
      print(
          '🔍 EmailVerificationScreen.didChangeDependencies: Current state is not EmailSetForVerification or email already set');
      print(
          '🔍 EmailVerificationScreen.didChangeDependencies: Current state type: ${currentState.runtimeType}');
      print(
          '🔍 EmailVerificationScreen.didChangeDependencies: Email isEmpty: ${_email.isEmpty}');
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🔍 EmailVerificationScreen.build: Called');
    print('🔍 EmailVerificationScreen.build: Current _email: "$_email"');
    print('🔍 EmailVerificationScreen.build: Email isEmpty: ${_email.isEmpty}');
    print('🔍 EmailVerificationScreen.build: Email length: ${_email.length}');
    print(
        '🔍 EmailVerificationScreen.build: Current BLoC state: ${_authBloc.state.runtimeType}');
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print(
            '🔍 EmailVerificationScreen: BLoC state changed: ${state.runtimeType}');
        print('🔍 EmailVerificationScreen: Current state details: $state');

        if (state is EmailSetForVerification) {
          print(
              '🔍 EmailVerificationScreen.listener: EmailSetForVerification state received');
          print(
              '🔍 EmailVerificationScreen.listener: Email from state: ${state.email}');
          setState(() {
            _email = state.email;
          });
          print(
              '🔍 EmailVerificationScreen.listener: Email set from state: $_email');

          // Automatically request verification code when email is set
          print(
              '🔍 EmailVerificationScreen.listener: Automatically requesting verification code for: ${state.email}');
          _authBloc.add(
            RequestEmailVerificationCodeRequested(email: state.email),
          );
        } else if (state is EmailVerificationSuccess) {
          print(
              '✅ EmailVerificationScreen: Email verification successful, navigating to login');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email verified successfully! You can now log in.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pushReplacementNamed(context, logInScreenRoute);
        } else if (state is AuthFailure) {
          print(
              '❌ EmailVerificationScreen: Auth failure - ${state.failure.message}');
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
                      'Verify Your Email',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    Text('We sent a 6-digit verification code to $_email'),
                    const SizedBox(height: defaultPadding),
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Enter verification code';
                          if (v.length != 6) return 'Enter a 6-digit code';
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter 6-digit code',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: defaultPadding * 0.75),
                            child: SvgPicture.asset(
                              "assets/icons/Doublecheck.svg",
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
                      bloc: _authBloc,
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: state is AuthLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    if (_email.isNotEmpty) {
                                      print(
                                          '🔍 EmailVerificationScreen: Submitting verification code');
                                      print(
                                          '🔍 EmailVerificationScreen: Email: $_email');
                                      print(
                                          '🔍 EmailVerificationScreen: Code: ${_codeController.text}');
                                      _authBloc.add(
                                        VerifyEmailCodeRequested(
                                          email: _email,
                                          code: _codeController.text,
                                        ),
                                      );
                                    } else {
                                      print(
                                          '❌ EmailVerificationScreen: Email is empty, cannot verify');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Email is required, please go back and try again'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                          child: state is AuthLoading
                              ? const CircularProgressIndicator()
                              : const Text('Verify Email'),
                        );
                      },
                    ),
                    const SizedBox(height: defaultPadding),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          print(
                              '🔍 EmailVerificationScreen: Resend code requested');
                          if (_email.isNotEmpty) {
                            _authBloc.add(
                              RequestEmailVerificationCodeRequested(
                                email: _email,
                              ),
                            );
                          } else {
                            print(
                                '❌ EmailVerificationScreen: Email is empty, cannot resend');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Email is required, please go back and try again'),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: const Text('Resend Code'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
