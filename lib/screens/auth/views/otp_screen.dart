import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_shop_app/constants.dart';
import 'package:flutter_shop_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_shop_app/screens/auth/views/new_password_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  String _email = '';
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('🔍 OtpScreen.didChangeDependencies: Called');
    _authBloc = context.read<AuthBloc>();
    print('🔍 OtpScreen.didChangeDependencies: Got AuthBloc from context');
    print(
        '🔍 OtpScreen.didChangeDependencies: Current BLoC state: ${_authBloc.state.runtimeType}');
    print(
        '🔍 OtpScreen.didChangeDependencies: BLoC state details: ${_authBloc.state}');

    final currentState = _authBloc.state;
    if (currentState is EmailSetForVerification && _email.isEmpty) {
      setState(() {
        _email = currentState.email;
      });
      print(
          '🔍 OtpScreen.didChangeDependencies: Email set from BLoC state: $_email');
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🔍 OtpScreen.build: Called');
    print('🔍 OtpScreen.build: Current _email: "$_email"');
    print('🔍 OtpScreen.build: Email isEmpty: ${_email.isEmpty}');
    print('🔍 OtpScreen.build: Email length: ${_email.length}');
    print(
        '🔍 OtpScreen.build: Current BLoC state: ${_authBloc.state.runtimeType}');
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print(
            '🔍 OtpScreen.listener: BLoC state changed: ${state.runtimeType}');
        print('🔍 OtpScreen.listener: Current state details: $state');

        if (state is EmailSetForVerification) {
          print(
              '🔍 OtpScreen.listener: EmailSetForVerification state received');
          print('🔍 OtpScreen.listener: Email from state: ${state.email}');
          setState(() {
            _email = state.email;
          });
          print('🔍 OtpScreen.listener: Email set from state: $_email');
        } else if (state is ResetPasswordSuccess) {
          final code = _codeController.text.trim();
          print('🔍 OtpScreen.listener: ResetPasswordSuccess received');
          print('🔍 OtpScreen.listener: Email: $_email');
          print('🔍 OtpScreen.listener: Code: $code');
          print('🔍 OtpScreen.listener: Dispatching SetResetCode event');
          _authBloc.add(SetResetCode(email: _email, code: code));
          print(
              '🔍 OtpScreen.listener: Event dispatched, navigating to new password screen');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: _authBloc,
                child: const SetNewPasswordScreen(),
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
                      'Enter verification code',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    Text('We sent a code to $_email'),
                    const SizedBox(height: defaultPadding),
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _codeController,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter the code';
                          if (v.length < 4) return 'Enter a valid code';
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Verification code',
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
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: state is AuthLoading
                              ? null
                              : () {
                                  print('🔍 OtpScreen: Verify button pressed');
                                  print(
                                      '🔍 OtpScreen: Current _email: "$_email"');
                                  print(
                                      '🔍 OtpScreen: Email isEmpty: ${_email.isEmpty}');
                                  print(
                                      '🔍 OtpScreen: Email length: ${_email.length}');

                                  if (_formKey.currentState!.validate()) {
                                    print(
                                        '🔍 OtpScreen: Form validation passed');
                                    final code = _codeController.text.trim();
                                    print('🔍 OtpScreen: Code: $code');
                                    print(
                                        '🔍 OtpScreen: Code length: ${code.length}');

                                    if (_email.isEmpty) {
                                      print(
                                          '❌ OtpScreen: Email is empty, showing error');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Email is required. Please go back and try again.'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }
                                    print(
                                        '✅ OtpScreen: Email is valid, proceeding with verification');
                                    _authBloc.add(
                                      VerifyPasswordResetCodeRequested(
                                        email: _email,
                                        code: code,
                                      ),
                                    );
                                  }
                                },
                          child: state is AuthLoading
                              ? const CircularProgressIndicator()
                              : const Text('Verify Code'),
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
    );
  }
}
