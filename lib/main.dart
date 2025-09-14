import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/config/app_config.dart';
import 'providers/auth_provider_simple.dart' as auth;
import 'providers/pin_provider.dart';
import 'providers/trail_provider.dart';
import 'providers/user_provider.dart';
import 'screens/auth/login_screen.dart';
import 'services/local_storage_service_simple.dart';
// import 'services/local_storage_service.dart';
// import 'test_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageServiceSimple.initializeHive();
  runApp(const PinQuestApp());
}

class PinQuestApp extends StatelessWidget {
  const PinQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => auth.AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PinProvider()),
        ChangeNotifierProvider(create: (_) => TrailProvider()),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const LoginScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
