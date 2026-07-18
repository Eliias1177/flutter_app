import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/note_model.dart';

/// Acceso centralizado a la base de datos local SQLite.
/// Guarda usuarios (para login/registro) y notas (para el CRUD).
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'flutter_test_app.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            email TEXT UNIQUE NOT NULL,
            passwordHash TEXT NOT NULL,
            role TEXT NOT NULL DEFAULT 'usuario'
          )
        ''');
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            reminderAt TEXT,
            synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  // ----- Usuarios -----
  Future<int> insertUser(AppUser user) async {
    final db = await database;
    return db.insert('users', user.toMap()..remove('id'));
  }

  Future<AppUser?> getUserByUsername(String username) async {
    final db = await database;
    final rows = await db.query('users', where: 'username = ?', whereArgs: [username]);
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<bool> usernameExists(String username) async {
    final user = await getUserByUsername(username);
    return user != null;
  }

  Future<bool> emailExists(String email) async {
    final db = await database;
    final rows = await db.query('users', where: 'email = ?', whereArgs: [email]);
    return rows.isNotEmpty;
  }

  // ----- Notas -----
  Future<int> insertNote(Note note) async {
    final db = await database;
    return db.insert('notes', note.toMap()..remove('id'));
  }

  Future<List<Note>> getNotes() async {
    final db = await database;
    final rows = await db.query('notes', orderBy: 'id DESC');
    return rows.map((r) => Note.fromMap(r)).toList();
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateNoteRow(Note note) async {
    final db = await database;
    return db.update('notes', note.toMap()..remove('id'), where: 'id = ?', whereArgs: [note.id]);
  }

  Future<List<Note>> getNotesWithPendingReminders() async {
    final db = await database;
    final rows = await db.query('notes', where: 'reminderAt IS NOT NULL');
    return rows.map((r) => Note.fromMap(r)).toList();
  }
  Future<void> imprimirUsuarios() async {
    final db = await database;
    final users = await db.query('users');
    print('\n=== USUARIOS EN LA BASE DE DATOS ===');
    for (var u in users) {
      print(u);
    }
    print('====================================\n');
  }
}