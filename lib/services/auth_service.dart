import 'package:flutter/foundation.dart';
import 'package:bcrypt/bcrypt.dart';
import '../db/database_helper.dart';
import '../models/user_model.dart';

/// Funciones top-level: necesarias para poder usarlas con compute() (isolates).
String _hashPasswordIsolate(String password) {
  return BCrypt.hashpw(password, BCrypt.gensalt());
}

bool _checkPasswordIsolate(Map<String, String> args) {
  return BCrypt.checkpw(args['password']!, args['hash']!);
}

class AuthService {
  final _db = DatabaseHelper.instance;

  /// Hashea la contraseña en un isolate separado (compute) para no
  /// bloquear el hilo de UI, ya que bcrypt es una operación costosa en CPU.
  Future<String> hashPassword(String password) => compute(_hashPasswordIsolate, password);

  Future<bool> verifyPassword(String password, String hash) =>
      compute(_checkPasswordIsolate, {'password': password, 'hash': hash});

  Future<String?> register({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    if (await _db.usernameExists(username)) return 'El usuario ya existe';
    if (await _db.emailExists(email)) return 'El correo ya está registrado';

    final hash = await hashPassword(password);
    await _db.insertUser(
      AppUser(username: username, email: email, passwordHash: hash, role: role),
    );
    return null; // null = éxito
  }

  Future<AppUser?> login(String username, String password) async {
    final user = await _db.getUserByUsername(username);
    if (user == null) return null;
    final ok = await verifyPassword(password, user.passwordHash);
    return ok ? user : null;
  }
}