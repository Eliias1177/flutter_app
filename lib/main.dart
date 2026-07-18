import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/auth_screen.dart';
import 'services/notification_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    // Esperamos a que Flutter dibuje el primer fotograma de la pantalla
    // antes de lanzar la alerta de permisos de notificación.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.init();
    });
  }

  void _toggleTheme() {
    setState(() => _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_test_app',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: AuthScreen(themeMode: _themeMode, onToggleTheme: _toggleTheme),
    );
  }
}