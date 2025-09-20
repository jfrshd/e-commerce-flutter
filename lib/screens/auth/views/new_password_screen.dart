import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_shop_app/constants.dart';
import 'package:flutter_shop_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_shop_app/route/route_constants.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({super.key});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String _email = '';
  String _code = '';
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    print('🔍 SetNewPasswordScreen.initState: Called');
    _authBloc = context.read<AuthBloc>();
    print('🔍 SetNewPasswordScreen.initState: Got AuthBloc from context');
    print(
        '🔍 SetNewPasswordScreen.initState: Current BLoC state: ${_authBloc.state.runtimeType}');
    print(
        '🔍 SetNewPasswordScreen.initState: BLoC state details: ${_authBloc.state}');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('🔍 SetNewPasswordScreen.didChangeDependencies: Called');
    print(
        '🔍 SetNewPasswordScreen.didChangeDependencies: Current _email: "$_email"');
    print(
        '🔍 SetNewPasswordScreen.didChangeDependencies: Current _code: "$_code"');
    print(
        '🔍 SetNewPasswordScreen.didChangeDependencies: Current BLoC state: ${_authBloc.state.runtimeType}');
    print(
        '🔍 SetNewPasswordScreen.didChangeDependencies: BLoC state details: ${_authBloc.state}');

    final currentState = _authBloc.state;
    if (currentState is ResetCodeSet) {
      print(
          '🔍 SetNewPasswordScreen.didChangeDependencies: Found ResetCodeSet state');
      print(
          '🔍 SetNewPasswordScreen.didChangeDependencies: Email from state: ${currentState.email}');
      print(
          '🔍 SetNewPasswordScreen.didChangeDependencies: Code from state: ${currentState.code}');
      if (_email.isEmpty || _code.isEmpty) {
        setState(() {
          _email = currentState.email;
          _code = currentState.code;
        });
        print(
            '🔍 SetNewPasswordScreen.didChangeDependencies: Email and code set from BLoC state');
        print('🔍 SetNewPasswordScreen.didChangeDependencies: Email: $_email');
        print('🔍 SetNewPasswordScreen.didChangeDependencies: Code: $_code');
      } else {
        print(
            '🔍 SetNewPasswordScreen.didChangeDependencies: Email and code already set, not updating');
      }
    } else {
      print(
          '🔍 SetNewPasswordScreen.didChangeDependencies: Current state is not ResetCodeSet');
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🔍 SetNewPasswordScreen.build: Called');
    print('🔍 SetNewPasswordScreen.build: Current _email: "$_email"');
    print('🔍 SetNewPasswordScreen.build: Current _code: "$_code"');
    print('🔍 SetNewPasswordScreen.build: Email isEmpty: ${_email.isEmpty}');
    print('🔍 SetNewPasswordScreen.build: Code isEmpty: ${_code.isEmpty}');
    print(
        '🔍 SetNewPasswordScreen.build: Current BLoC state: ${_authBloc.state.runtimeType}');
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print(
            '🔍 SetNewPasswordScreen.listener: BLoC state changed: ${state.runtimeType}');
        print(
            '🔍 SetNewPasswordScreen.listener: Current state details: $state');

        if (state is ResetCodeSet) {
          print(
              '🔍 SetNewPasswordScreen.listener: ResetCodeSet state received');
          print(
              '🔍 SetNewPasswordScreen.listener: Email from state: ${state.email}');
          print(
              '🔍 SetNewPasswordScreen.listener: Code from state: ${state.code}');
          setState(() {
            _email = state.email;
            _code = state.code;
          });
          print(
              '🔍 SetNewPasswordScreen.listener: Email and code set from state');
          print('🔍 SetNewPasswordScreen.listener: Email: $_email');
          print('🔍 SetNewPasswordScreen.listener: Code: $_code');
        } else if (state is ResetPasswordSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password changed successfully. Please log in.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pushNamedAndRemoveUntil(
              context, logInScreenRoute, (r) => false);
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
                      'Set New Password',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    Text('Enter your new password below'),
                    const SizedBox(height: defaultPadding),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Enter password';
                              if (v.length < 6)
                                return 'Password must be at least 6 characters';
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'New Password',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: defaultPadding * 0.75),
                                child: SvgPicture.asset(
                                  "assets/icons/Lock.svg",
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
                          const SizedBox(height: defaultPadding),
                          TextFormField(
                            controller: _confirmController,
                            obscureText: true,
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Confirm password';
                              if (v != _passwordController.text)
                                return 'Passwords do not match';
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Confirm Password',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: defaultPadding * 0.75),
                                child: SvgPicture.asset(
                                  "assets/icons/Lock.svg",
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
                        ],
                      ),
                    ),
                    const SizedBox(height: defaultPadding * 2),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: state is AuthLoading
                              ? null
                              : () {
                                  print(
                                      '🔍 SetNewPasswordScreen: Submit button pressed');
                                  print(
                                      '🔍 SetNewPasswordScreen: Current _email: "$_email"');
                                  print(
                                      '🔍 SetNewPasswordScreen: Current _code: "$_code"');
                                  print(
                                      '🔍 SetNewPasswordScreen: Email isEmpty: ${_email.isEmpty}');
                                  print(
                                      '🔍 SetNewPasswordScreen: Code isEmpty: ${_code.isEmpty}');

                                  if (_formKey.currentState!.validate()) {
                                    print(
                                        '🔍 SetNewPasswordScreen: Form validation passed');
                                    final password = _passwordController.text;
                                    print(
                                        '🔍 SetNewPasswordScreen: Password length: ${password.length}');

                                    if (_email.isEmpty || _code.isEmpty) {
                                      print(
                                          '❌ SetNewPasswordScreen: Email or code is empty, showing error');
                                      print(
                                          '❌ SetNewPasswordScreen: Email empty: ${_email.isEmpty}');
                                      print(
                                          '❌ SetNewPasswordScreen: Code empty: ${_code.isEmpty}');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Email and code are required. Please go back and try again.'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }
                                    print(
                                        '✅ SetNewPasswordScreen: Email and code are valid, proceeding with password reset');
                                    print(
                                        '🔍 SetNewPasswordScreen: Dispatching ResetPasswordRequested event');
                                    print(
                                        '🔍 SetNewPasswordScreen: Code: $_code');
                                    print(
                                        '🔍 SetNewPasswordScreen: Password length: ${password.length}');
                                    _authBloc.add(
                                      ResetPasswordRequested(
                                        code: _code,
                                        password: password,
                                      ),
                                    );
                                    print(
                                        '🔍 SetNewPasswordScreen: Event dispatched successfully');
                                  } else {
                                    print(
                                        '❌ SetNewPasswordScreen: Form validation failed');
                                  }
                                },
                          child: state is AuthLoading
                              ? const CircularProgressIndicator()
                              : const Text('Change Password'),
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
