import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/config/env_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (optional)
  // await Firebase.initializeApp();

  // Initialize Supabase
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );

  // Load theme preference
  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('theme_mode');

  runApp(MyApp(initialThemeMode: savedTheme));
}

class MyApp extends StatefulWidget {
  final String? initialThemeMode;

  const MyApp({super.key, this.initialThemeMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode == 'dark'
        ? ThemeMode.dark
        : widget.initialThemeMode == 'light'
            ? ThemeMode.light
            : ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = mode;
    });
    await prefs.setString('theme_mode', mode == ThemeMode.dark ? 'dark' : 'light');
  }

  void toggleTheme() {
    final newMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setThemeMode(newMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'E-Ticketing Helpdesk',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      routerConfig: appRouter,
    );
  }
}
