import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:re_uni/screens/home_screen.dart';
import 'package:re_uni/widgets/custom_text_field.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      final user = await _authService.signIn(email, password);
      if (user != null) {
        final userData = await _authService.getUserData(user.uid);
        final isAdmin = userData?['isAdmin'] ?? false;
        FocusScope.of(context).requestFocus(FocusNode());
        // После успешного входа переходим на HomeScreen и передаем isAdmin
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(isAdmin: isAdmin),
          ),
        );
      } else {
        _showError('Ошибка входа. Проверьте данные.');
      }
    } else {
      _showError('Введите email и пароль.');
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ошибка'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ОК'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      SizedBox.expand(
        child: Image.asset(
          'assets/background.png',
          fit: BoxFit.cover,
        ),
      ),
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Center(
            child: Text(
              'Вход',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.20,
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextField(controller: _emailController, name: 'Почта'),
              const SizedBox(height: 16),
              CustomTextField(controller: _passwordController, name: 'Пароль'),
              // TextField(
              //   controller: _passwordController,
              //   decoration: const InputDecoration(
              //     labelText: 'Пароль',
              //     border: OutlineInputBorder(),
              //   ),
              //   obscureText: true,
              // ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: const ButtonStyle(
                  overlayColor: WidgetStatePropertyAll<Color>(Colors.black),
                  shadowColor: WidgetStatePropertyAll<Color>(Colors.black),
                  backgroundColor:
                      WidgetStatePropertyAll<Color>(Colors.transparent),
                ),
                onPressed: _login,
                child: Text(
                  'Войти',
                  style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.20,
                      color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text(
                  'Регистрация',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}
