import 'package:flutter/material.dart';
import 'package:flutter_shop_app/route/route_constants.dart';
import 'package:flutter_shop_app/route/router.dart' as router;
import 'package:flutter_shop_app/theme/app_theme.dart';
import 'package:flutter_shop_app/screens/splash/splash_screen.dart';
import 'core/di/injection.dart';

void main() async {
  print('🚀 Starting Flutter app...');
  WidgetsFlutterBinding.ensureInitialized();
  print('🔧 Configuring dependencies...');
  await configureDependencies();
  print('✅ Dependencies configured successfully');
  print('🏃 Running app...');
  runApp(const MyApp());
}

// Thanks for using our template. You are using the free version of the template.
// 🔗 Full template: https://theflutterway.gumroad.com/l/fluttershop

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shop Template by The Flutter Way',
      theme: AppTheme.lightTheme(context),
      // Dark theme is inclided in the Full template
      themeMode: ThemeMode.light,
      onGenerateRoute: router.generateRoute,
      initialRoute: splashScreenRoute,
    );
  }
}
