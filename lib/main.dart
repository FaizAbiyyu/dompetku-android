import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/main_navigation_screen.dart';
import 'utils/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const DompetKuApp());
}

class DompetKuApp extends StatefulWidget {
  const DompetKuApp({super.key});

  @override
  State<DompetKuApp> createState() => _DompetKuAppState();
}

class _DompetKuAppState extends State<DompetKuApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DompetKu',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          primary: AppColors.primary,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: AppColors.lightBg,
        cardTheme: const CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          primary: AppColors.primary,
          surface: const Color(0xFF1E293B),
        ),
        scaffoldBackgroundColor: AppColors.darkBg,
        cardTheme: const CardThemeData(
          color: Color(0xFF1E293B),
          surfaceTintColor: Colors.transparent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: MainNavigationScreen(
        isDarkMode: _isDarkMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}
