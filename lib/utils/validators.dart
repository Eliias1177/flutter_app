class Validators {
  static final RegExp emailRegex =
      RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$");

  static bool isValidEmail(String email) => emailRegex.hasMatch(email.trim());

  static String? emailError(String email) {
    if (email.trim().isEmpty) return 'El correo es obligatorio';
    if (!isValidEmail(email)) return 'Correo inválido';
    return null;
  }

  static String? usernameError(String username) {
    if (username.trim().isEmpty) return 'El usuario es obligatorio';
    if (username.trim().length < 3) return 'Mínimo 3 caracteres';
    return null;
  }

  /// Requisitos recomendados: 8+ caracteres, mayúscula, minúscula, número y símbolo.
  static String? passwordError(String password) {
    if (password.isEmpty) return 'La contraseña es obligatoria';
    if (password.length < 8) return 'Mínimo 8 caracteres';
    if (!RegExp(r'[A-Z]').hasMatch(password)) return 'Incluye al menos una mayúscula';
    if (!RegExp(r'[a-z]').hasMatch(password)) return 'Incluye al menos una minúscula';
    if (!RegExp(r'[0-9]').hasMatch(password)) return 'Incluye al menos un número';
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=]').hasMatch(password)) {
      return 'Incluye al menos un símbolo (!@#\$...)';
    }
    return null;
  }

  static String? confirmPasswordError(String password, String confirm) {
    if (confirm.isEmpty) return 'Confirma tu contraseña';
    if (password != confirm) return 'Las contraseñas no coinciden';
    return null;
  }
}