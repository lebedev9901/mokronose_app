import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';

import 'package:flutter/material.dart';
import 'main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'services/api_service.dart';


class LoginScreen extends StatefulWidget{
  
  final Function(String token) onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
    });

  
  @override
  
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>{

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  final int vkAppId = 54596619;
  final String vkRedirectUri = 'https://mokronos.ru/vk/mobile-callback';

  bool isRegister = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final lastNameController = TextEditingController();
  final firstNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final passwordConfirmController = TextEditingController();

 
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      if (uri.scheme == 'mokronose' && uri.host == 'vk-auth') {
        final token = uri.queryParameters['token'];

        if (token != null) {
          ApiService.token = token;
          widget.onLoginSuccess(token);
        }
      }
    });
  }

  Future<void> loginWithVk() async {
    final vkAuthUrl = Uri.https('oauth.vk.com', '/authorize', {
      'client_id': vkAppId.toString(),
      'redirect_uri': 'https://mokronos.ru/vk/mobile-callback',
      'display': 'mobile',
      'response_type': 'code',
      'v': '5.199',
    });
    error = vkAuthUrl.toString();
    setState(() {});
    final opened = await launchUrl(
      vkAuthUrl,
      mode: LaunchMode.externalApplication,
    );

    if (!opened) {
      setState(() {
        error = 'Не удалось открыть VK';
      });
    }
  }


  Future<void> login() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final success = await ApiService.login(
      email: emailController.text,
      password: passwordController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (!success) {
      setState(() {
        error = 'Неверный email или пароль';
      });

      return;
    }

    widget.onLoginSuccess(ApiService.token!);
  }

  Future<void> register() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final success = await ApiService.register(
      lastName: lastNameController.text,
      firstName: firstNameController.text,
      middleName: middleNameController.text,
      email: emailController.text,
      password: passwordController.text,
      passwordConfirmation: passwordConfirmController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (!success) {
      setState(() {
        error = 'Ошибка регистрации';
      });

      return;
    }

    widget.onLoginSuccess(ApiService.token!);
  }
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(

            children: [
              const Spacer(),

              const Text(
                'Мокронос',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold
                ),
              ),

              const SizedBox(height: 8),
              Text(
                isRegister ? 'Создайте аккаунт' : 'Войдите в аккаунт',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
              ),

              const SizedBox(height: 32),
              
              if (isRegister) ...[
                TextField(
                  controller: lastNameController,
                  decoration: InputDecoration(
                    hintText: 'Фамилия',
                    prefixIcon: const Icon(Icons.person_outline),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                TextField(
                  controller: firstNameController,
                  decoration: InputDecoration(
                    hintText: 'Имя',
                    prefixIcon: const Icon(Icons.person_outline),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                TextField(
                  controller: middleNameController,
                  decoration: InputDecoration(
                    hintText: 'Отчество',
                    prefixIcon: const Icon(Icons.person_outline),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],

              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Пароль',
                  prefixIcon: const Icon(Icons.lock_outline),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none
                  ),
                ),
              ),

              if (isRegister) ...[
                const SizedBox(height: 12),

                TextField(
                  controller: passwordConfirmController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Повторите пароль',
                    prefixIcon: const Icon(Icons.lock_reset_outlined),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],

            const SizedBox(height: 20),

            if (error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                error!,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color.fromARGB(139, 90, 43, 1)
                ),
                onPressed: isLoading
                ? null
                : isRegister
                    ? register
                    : login,
                child: Text(
                  isRegister ? 'Зарегистрироваться' : 'Войти',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                ),
              ),
            

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0077FF),
                ),
                onPressed: isLoading ? null : loginWithVk,
                icon: const Text(
                  '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                label: const Text(
                  'Войти через VK',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () {
                setState(() {
                  isRegister = !isRegister;
                });
              },
              child: Text(
                isRegister
                    ? 'Уже есть аккаунт? Войти'
                    : 'Нет аккаунта? Зарегистрироваться',
                    style: TextStyle(
                      color: Color.fromARGB(139, 90, 43, 1)
                    ),
              ),
            ),

               const Spacer(),
            ],
          ),
        ),
      ),
    );
    
  }
}
