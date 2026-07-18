import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/note_model.dart';

/// Servicio para exportar/importar las notas como archivo de texto plano (.txt)
/// usando File.writeAsString / File.readAsString: interacción real con
/// el sistema de archivos local.
class FileService {
  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/notas_exportadas.txt');
  }

  Future<String> exportNotes(List<Note> notes) async {
    final file = await _getFile();
    final buffer = StringBuffer();
    for (final n in notes) {
      buffer.writeln('TITULO: ${n.title}');
      buffer.writeln('CONTENIDO: ${n.content}');
      if (n.reminderAt != null) buffer.writeln('RECORDATORIO: ${n.reminderAt}');
      buffer.writeln('---');
    }
    await file.writeAsString(buffer.toString());
    return file.path;
  }

  Future<String> importNotesRaw() async {
    final file = await _getFile();
    if (!await file.exists()) return '';
    return file.readAsString();
  }
}