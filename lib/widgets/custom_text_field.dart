import 'package:flutter/material.dart';
import 'shake_widget.dart';

/// Control personalizado de texto con ícono, texto de error y shake al fallar.
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final ShakeController shakeController;
  final String? errorText;
  final Widget? suffix;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.shakeController,
    this.obscureText = false,
    this.errorText,
    this.suffix,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return ShakeWidget(
      controller: shakeController,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
          suffixIcon: suffix,
          labelText: label,
          errorText: errorText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}