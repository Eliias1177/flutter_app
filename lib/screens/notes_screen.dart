import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/api_service.dart';
import '../services/file_service.dart';
import '../services/notification_service.dart';
import '../db/database_helper.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _api = ApiService();
  final _fileService = FileService();
  final _db = DatabaseHelper.instance;

  late Future<List<Note>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _notesFuture = _loadNotes();
  }

  /// SQLite es la fuente real de lo que se muestra en pantalla.
  /// La primera vez que se abre (sin notas locales) se siembra con datos
  /// de la API pública, solo para no arrancar con la lista vacía.
  Future<List<Note>> _loadNotes() async {
    final local = await _db.getNotes();
    if (local.isNotEmpty) return local;

    try {
      final apiNotes = await _api.fetchNotes();
      for (final n in apiNotes) {
        await _db.insertNote(Note(title: n.title, content: n.content));
      }
    } catch (_) {
      // Sin internet o la API falló: seguimos con lista vacía, no es error fatal.
    }
    return _db.getNotes();
  }

  Future<void> _refresh() async {
    setState(() {
      _notesFuture = _db.getNotes();
    });
  }

  Future<void> _addNote() async {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    DateTime? reminder;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Nueva nota'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título')),
              TextField(controller: bodyCtrl, decoration: const InputDecoration(labelText: 'Contenido')),
              TextButton.icon(
                icon: const Icon(Icons.alarm),
                label: Text(reminder == null ? 'Agregar recordatorio (opcional)' : 'Recordatorio: $reminder'),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date == null) return;
                  final time = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
                  if (time == null) return;
                  setDialogState(() {
                    reminder = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty) return;
                final note =
                    Note(title: titleCtrl.text.trim(), content: bodyCtrl.text.trim(), reminderAt: reminder);

                // Persistencia real: SQLite (esto es lo que hace que se "guarde" de verdad).
                final id = await _db.insertNote(note);

                // Llamada CRUD a la API pública, best-effort: si falla, no tumba el guardado local.
                try {
                  await _api.createNote(note);
                } catch (_) {}

                if (reminder != null) {
                  try {
                    await NotificationService.instance.scheduleReminder(
                      id: id,
                      title: 'Recordatorio: ${note.title}',
                      body: note.content,
                      scheduledDate: reminder!,
                    );
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('Nota guardada, pero el recordatorio falló: $e')));
                    }
                  }
                }
                
                if (ctx.mounted) Navigator.pop(ctx);
                _refresh();
                if (mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Nota guardada')));
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteNote(Note note) async {
    if (note.id == null) return;

    // Borrado real: SQLite.
    await _db.deleteNote(note.id!);
    await NotificationService.instance.cancelReminder(note.id!);

    // Llamada CRUD a la API pública, best-effort.
    try {
      await _api.deleteNote(note.id!);
    } catch (_) {}

    _refresh();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nota eliminada')));
    }
  }

  /// UPDATE del CRUD: edita una nota existente, la guarda en SQLite
  /// y también manda el PUT a la API para cumplir el CRUD completo.
  Future<void> _editNote(Note note) async {
    final titleCtrl = TextEditingController(text: note.title);
    final bodyCtrl = TextEditingController(text: note.content);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar nota'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título')),
            TextField(controller: bodyCtrl, decoration: const InputDecoration(labelText: 'Contenido')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty || note.id == null) return;
              final updated = Note(
                id: note.id,
                title: titleCtrl.text.trim(),
                content: bodyCtrl.text.trim(),
                reminderAt: note.reminderAt,
              );

              // Persistencia real: SQLite.
              await _db.updateNoteRow(updated);

              // Llamada CRUD (PUT) a la API pública, best-effort.
              try {
                await _api.updateNote(note.id!, updated);
              } catch (_) {}

              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Nota ${note.id} actualizada')));
              }
              _refresh();
            },
            child: const Text('Guardar cambios'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToFile() async {
    final notes = await _notesFuture;
    final path = await _fileService.exportNotes(notes);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exportado a: $path')));
  }

  /// Lee de vuelta el .txt local con File.readAsString y lo muestra.
  Future<void> _importFromFile() async {
    final raw = await _fileService.importNotesRaw();
    if (!mounted) return;
    if (raw.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No hay archivo exportado todavía')));
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Contenido de notas_exportadas.txt'),
        content: SingleChildScrollView(child: Text(raw)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas (SQLite + API CRUD)'),
        actions: [
          IconButton(icon: const Icon(Icons.upload_file), onPressed: _importFromFile, tooltip: 'Leer .txt'),
          IconButton(icon: const Icon(Icons.download), onPressed: _exportToFile, tooltip: 'Exportar a .txt'),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _addNote, child: const Icon(Icons.add)),
      // FutureBuilder: construye la lista en base al Future que consulta SQLite.
      body: FutureBuilder<List<Note>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final notes = snapshot.data ?? [];
          if (notes.isEmpty) return const Center(child: Text('Sin notas todavía'));
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, i) {
              final n = notes[i];
              return ListTile(
                title: Text(n.title),
                subtitle: Text(n.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                onTap: () => _editNote(n),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _editNote(n)),
                    IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _deleteNote(n)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}