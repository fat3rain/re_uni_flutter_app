import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required TextEditingController controller,
    required this.name,
  }) : _emailController = controller;
  final String name;
  final TextEditingController _emailController;

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      controller: _emailController,
      decoration: InputDecoration(
        focusColor: Colors.white,
        labelStyle: const TextStyle(color: Colors.white),
        labelText: name,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
