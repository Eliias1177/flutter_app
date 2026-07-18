import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/shake_widget.dart';
import '../utils/validators.dart';
import 'home_screen.dart';

/// IMPORTANTE: esta es UNA sola pantalla. El modo login/registro se controla
/// con el flag _isLogin y los widgets se muestran/ocultan con animaciones
/// (AnimatedSwitcher / AnimatedSize) — no se navega a otra ruta.
class AuthScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  const AuthScreen({super.key, required this.themeMode, required this.onToggleTheme});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _authService = AuthService();

  bool _isLogin = true;
  bool _loading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _acceptTerms = false;
  String _role = 'usuario';

  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  final _usernameShake = ShakeController();
  final _emailShake = ShakeController();
  final _passShake = ShakeController();
  final _confirmShake = ShakeController();
  final _termsShake = ShakeController();

  String? _usernameError;
  String? _emailError;
  String? _passError;
  String? _confirmError;
  String? _loginError;

  void _clearFields() {
    _usernameCtrl.clear();
    _emailCtrl.clear();
    _passCtrl.clear();
    _confirmCtrl.clear();
    _acceptTerms = false;
    _usernameError = null;
    _emailError = null;
    _passError = null;
    _confirmError = null;
    _loginError = null;
  }

  void _switchMode() {
    setState(() {
      _isLogin = !_isLogin;
      _clearFields();
    });
  }

  Future<void> _handleLogin() async {
    setState(() {
      _usernameError = Validators.usernameError(_usernameCtrl.text);
      _passError = _passCtrl.text.isEmpty ? 'La contraseña es obligatoria' : null;
      _loginError = null;
    });
    if (_usernameError != null) _usernameShake.shake();
    if (_passError != null) _passShake.shake();
    if (_usernameError != null || _passError != null) return;

    setState(() => _loading = true);
    final user = await _authService.login(_usernameCtrl.text.trim(), _passCtrl.text);
    setState(() => _loading = false);

    if (user == null) {
      setState(() => _loginError = 'Usuario o contraseña incorrectos');
      _passShake.shake();
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          user: user,
          themeMode: widget.themeMode,
          onToggleTheme: widget.onToggleTheme,
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    setState(() {
      _usernameError = Validators.usernameError(_usernameCtrl.text);
      _emailError = Validators.emailError(_emailCtrl.text);
      _passError = Validators.passwordError(_passCtrl.text);
      _confirmError = Validators.confirmPasswordError(_passCtrl.text, _confirmCtrl.text);
    });

    bool anyError = false;
    if (_usernameError != null) {
      _usernameShake.shake();
      anyError = true;
    }
    if (_emailError != null) {
      _emailShake.shake();
      anyError = true;
    }
    if (_passError != null) {
      _passShake.shake();
      anyError = true;
    }
    if (_confirmError != null) {
      _confirmShake.shake();
      anyError = true;
    }
    if (!_acceptTerms) {
      _termsShake.shake();
      anyError = true;
    }
    if (anyError) return;

    setState(() => _loading = true);
    final error = await _authService.register(
      username: _usernameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      role: _role,
    );
    setState(() => _loading = false);

    if (error != null) {
      setState(() => _emailError = error);
      _emailShake.shake();
      return;
    }

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Registro exitoso'),
        content: const Text('Tu cuenta se creó correctamente. Ahora puedes iniciar sesión.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Aceptar')),
        ],
      ),
    );

    setState(() {
      _isLogin = true;
      _clearFields();
    });
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(widget.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
                  onPressed: widget.onToggleTheme,
                ),
              ),
              const SizedBox(height: 12),
              CircleAvatar(
                radius: 40,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: const Icon(Icons.person, size: 44, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _isLogin ? 'Login SQLite' : 'Register',
                  key: ValueKey(_isLogin),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 28),

              CustomTextField(
                controller: _usernameCtrl,
                label: 'Username',
                icon: Icons.person_outline,
                shakeController: _usernameShake,
                errorText: _usernameError,
              ),
              const SizedBox(height: 16),

              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: !_isLogin
                    ? Column(
                        children: [
                          CustomTextField(
                            controller: _emailCtrl,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            shakeController: _emailShake,
                            errorText: _emailError,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),

              CustomTextField(
                controller: _passCtrl,
                label: 'Password',
                icon: Icons.lock_outline,
                obscureText: _obscurePass,
                shakeController: _passShake,
                errorText: _passError ?? (_isLogin ? _loginError : null),
                suffix: IconButton(
                  icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                ),
              ),

              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: !_isLogin
                    ? Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: CustomTextField(
                          controller: _confirmCtrl,
                          label: 'Confirmar contraseña',
                          icon: Icons.lock_reset_outlined,
                          obscureText: _obscureConfirm,
                          shakeController: _confirmShake,
                          errorText: _confirmError,
                          suffix: IconButton(
                            icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: !_isLogin
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            const Text('Rol: '),
                            Radio<String>(
                              value: 'usuario',
                              groupValue: _role,
                              onChanged: (v) => setState(() => _role = v!),
                            ),
                            const Text('Usuario'),
                            Radio<String>(
                              value: 'administrador',
                              groupValue: _role,
                              onChanged: (v) => setState(() => _role = v!),
                            ),
                            const Text('Admin'),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // Checkbox entre la contraseña y el botón de acción.
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: !_isLogin
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ShakeWidget(
                          controller: _termsShake,
                          child: Row(
                            children: [
                              Checkbox(
                                value: _acceptTerms,
                                onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                              ),
                              const Expanded(
                                child: Text(
                                  'Acepto los términos y condiciones',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 20),
              CustomButton(
                label: _isLogin ? 'Login' : 'Register',
                loading: _loading,
                onPressed: _isLogin ? _handleLogin : _handleRegister,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _switchMode,
                child: Text.rich(
                  TextSpan(
                    text: _isLogin ? '¿No tienes cuenta? ' : '¿Ya tienes cuenta? ',
                    style: TextStyle(color: Colors.grey.shade400),
                    children: [
                      TextSpan(
                        text: _isLogin ? '¡Crea una!' : 'Inicia sesión',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}