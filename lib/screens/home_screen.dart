import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../db/database_helper.dart';
import '../services/notification_service.dart';
import 'notes_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppUser user;
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.user,
    required this.themeMode,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _zoom = 1.0;
  Timer? _reminderTimer;

  @override
  void initState() {
    super.initState();
    // Timer.periodic: revisa cada minuto si hay recordatorios próximos
    // a vencer y dispara una notificación real del sistema.
    _reminderTimer = Timer.periodic(const Duration(minutes: 1), (_) => _checkReminders());
  }

  Future<void> _checkReminders() async {
    final notes = await DatabaseHelper.instance.getNotesWithPendingReminders();
    final now = DateTime.now();
    for (final note in notes) {
      final due = note.reminderAt!;
      if (due.isBefore(now) && due.isAfter(now.subtract(const Duration(minutes: 1)))) {
        await NotificationService.instance.scheduleReminder(
          id: note.id ?? 0,
          title: 'Recordatorio: ${note.title}',
          body: note.content,
          scheduledDate: now.add(const Duration(seconds: 2)),
        );
      }
    }
  }

  @override
  void dispose() {
    _reminderTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hola, ${widget.user.username}')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(widget.user.username),
              accountEmail: Text(widget.user.email),
              currentAccountPicture: const CircleAvatar(child: Icon(Icons.person)),
            ),
            ListTile(
              leading: const Icon(Icons.note_alt_outlined),
              title: const Text('Mis notas (CRUD + API)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotesScreen()));
              },
            ),
            ListTile(
              leading: Icon(widget.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
              title: const Text('Cambiar tema'),
              onTap: widget.onToggleTheme,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Transform.scale(
                scale: _zoom,
                child: Image.network(
                  'https://picsum.photos/seed/${widget.user.username}/500/400',
                  width: 280,
                  height: 220,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : const SizedBox(
                          height: 220, child: Center(child: CircularProgressIndicator())),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Zoom: ${_zoom.toStringAsFixed(1)}x'),
            Slider(
              value: _zoom,
              min: 1.0,
              max: 3.0,
              divisions: 20,
              onChanged: (v) => setState(() => _zoom = v),
            ),
          ],
        ),
      ),
    );
  }
}