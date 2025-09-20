import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_shop_app/core/di/injection.dart';
import 'package:flutter_shop_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_shop_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_shop_app/route/route_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    print('🚀 SplashScreen: Initializing...');
    _authBloc = AuthBloc(authRepository: getIt<AuthRepository>());
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    print('🔍 SplashScreen: Checking login status...');
    try {
      final isLoggedIn = await _authBloc.authRepository.isLoggedIn();
      print('🔍 SplashScreen: Login status: $isLoggedIn');

      if (isLoggedIn) {
        print('✅ SplashScreen: User is logged in, navigating to home');
        if (mounted) {
          Navigator.pushReplacementNamed(context, entryPointScreenRoute);
        }
      } else {
        print(
            '❌ SplashScreen: User is not logged in, navigating to onboarding');
        if (mounted) {
          Navigator.pushReplacementNamed(context, onbordingScreenRoute);
        }
      }
    } catch (e) {
      print('❌ SplashScreen: Error checking login status: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, onbordingScreenRoute);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Loading...',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
