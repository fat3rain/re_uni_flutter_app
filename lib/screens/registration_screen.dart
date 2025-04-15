import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:re_uni/widgets/custom_text_field.dart';
import '../services/auth_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      if (password == confirmPassword) {
        final user = await _authService.register(email, password);
        if (user != null) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Вы успешно зарегистрировались!'),
              duration:
                  Duration(seconds: 2), // Длительность отображения уведомления
            ),
          ); // Возвращаемся на экран входа
        } else {
          _showError('Ошибка регистрации. Проверьте данные.');
        }
      } else {
        _showError('Пароли не совпадают.');
      }
    } else {
      _showError('Введите все данные.');
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
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          title: Text(
            'Регистрация',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.20,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextField(
                controller: _emailController,
                name: 'Email',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                name: 'Пароль',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _confirmPasswordController,
                name: 'Пароль еще раз',
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: const ButtonStyle(
                  overlayColor: WidgetStatePropertyAll<Color>(Colors.black),
                  shadowColor: WidgetStatePropertyAll<Color>(Colors.black),
                  backgroundColor:
                      WidgetStatePropertyAll<Color>(Colors.transparent),
                ),
                onPressed: _register,
                child: Text(
                  'Зарегистрироваться',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.20,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Уже есть аккаунт',
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
