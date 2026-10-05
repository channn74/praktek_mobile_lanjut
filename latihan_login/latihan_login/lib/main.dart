import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
import 'core/data/database/database_helper.dart';
import 'core/presentation/screens/home_screen.dart';
import 'core/presentation/screens/login_screen.dart';
import 'core/themes/app_theme.dart';
import 'core/utils/app_snack_bar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Siapkan database saat aplikasi start (membuat file & tabel bila perlu).
  await DatabaseHelper.database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthGate(),
    );
  }
}

/// Mengatur perpindahan halaman antara login dan home.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Map<String, Object?>? _currentUser;

  void _handleLoginSuccess(Map<String, Object?> user) {
    setState(() => _currentUser = user);
  }

  void _handleLogout() {
    if (!mounted) return;
    setState(() => _currentUser = null);
    AppSnackBar.info(context, AppConstants.msgLogoutSuccess);
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;
    if (user != null) {
      return HomeScreen(user: user, onLogout: _handleLogout);
    }
    return LoginScreen(onLoginSuccess: _handleLoginSuccess);
  }
}
