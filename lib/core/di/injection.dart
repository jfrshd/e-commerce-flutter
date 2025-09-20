import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  print('🔧 Initializing dependency injection...');
  await getIt.init();
  print('✅ Dependency injection initialized successfully');
}
