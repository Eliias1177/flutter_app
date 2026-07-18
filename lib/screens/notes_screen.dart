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
    _notesFuture = _api.fetchNotes(); // Consumido por el FutureBuilder de abajo
  }

  Future<void> _refresh() async {
    setState(() => _notesFuture = _api.fetchNotes());
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
                // async/await: se guarda en SQLite y también se manda a la API remota.
                final note =
                    Note(title: titleCtrl.text.trim(), content: bodyCtrl.text.trim(), reminderAt: reminder);
                final id = await _db.insertNote(note);
                await _api.createNote(note); // demo de creación vía API REST
                if (reminder != null) {
                  await NotificationService.instance.scheduleReminder(
                    id: id,
                    title: 'Recordatorio: ${note.title}',
                    body: note.content,
                    scheduledDate: reminder!,
                  );
                }
                if (ctx.mounted) Navigator.pop(ctx);
                _refresh();
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteNote(Note note) async {
    if (note.id != null) {
      await _api.deleteNote(note.id!);
      await NotificationService.instance.cancelReminder(note.id!);
    }
    _refresh();
  }

  Future<void> _exportToFile() async {
    final notes = await _notesFuture;
    final path = await _fileService.exportNotes(notes);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exportado a: $path')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas (API CRUD)'),
        actions: [
          IconButton(icon: const Icon(Icons.download), onPressed: _exportToFile, tooltip: 'Exportar a .txt'),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _addNote, child: const Icon(Icons.add)),
      // FutureBuilder: construye la lista en base al Future que consulta la API.
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
                trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _deleteNote(n)),
              );
            },
          );
        },
      ),
    );
  }
}