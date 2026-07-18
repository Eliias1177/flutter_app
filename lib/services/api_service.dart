import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note_model.dart';

/// Servicio de acceso a una API REST para operaciones CRUD.
/// Se usa JSONPlaceholder (https://jsonplaceholder.typicode.com) como backend
/// de demostración: las escrituras responden con éxito (200/201) pero no
/// persisten realmente en su servidor. Ese es el comportamiento esperado
/// y documentado de esta API pública gratuita, ideal para proyectos escolares.
class ApiService {
  static const _baseUrl = 'https://jsonplaceholder.typicode.com/posts';

  Future<List<Note>> fetchNotes() async {
    final res = await http.get(Uri.parse('$_baseUrl?_limit=8'));
    if (res.statusCode != 200) throw Exception('Error al obtener notas (${res.statusCode})');
    final List data = jsonDecode(res.body);
    return data.map((e) => Note.fromApiJson(e)).toList();
  }

  Future<Note> createNote(Note note) async {
    final res = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': note.title, 'body': note.content, 'userId': 1}),
    );
    if (res.statusCode != 201) throw Exception('Error al crear nota (${res.statusCode})');
    return Note.fromApiJson(jsonDecode(res.body));
  }

  Future<void> updateNote(int id, Note note) async {
    final res = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': note.title, 'body': note.content, 'userId': 1}),
    );
    if (res.statusCode != 200) throw Exception('Error al actualizar nota (${res.statusCode})');
  }

  Future<void> deleteNote(int id) async {
    final res = await http.delete(Uri.parse('$_baseUrl/$id'));
    if (res.statusCode != 200) throw Exception('Error al eliminar nota (${res.statusCode})');
  }
}