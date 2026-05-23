import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_shell.dart';
import 'services/api_service.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool isLoading = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();

    ApiService.token = prefs.getString('token');

    if (ApiService.token == null) {
      setState(() {
        isLoggedIn = false;
        isLoading = false;
      });

      return;
    }

    final user = await ApiService.getMe();

    if (user == null) {
      await prefs.remove('is_logged_in');
      await prefs.remove('token');

      setState(() {
        isLoggedIn = false;
        isLoading = false;
      });

      return;
    }

    setState(() {
      isLoggedIn = true;
      isLoading = false;
    });
  }

  Future<void> login(String token) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('is_logged_in', true);
    await prefs.setString('token', token);

    ApiService.token = token;

    setState(() {
      isLoggedIn = true;
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('is_logged_in');
    await prefs.remove('token');

    ApiService.token = null;

    setState(() {
      isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (isLoggedIn) {
      return MainShell(
        onLogout: logout,
      );
    }

    return LoginScreen(
      onLoginSuccess: login,
    );
  }
}