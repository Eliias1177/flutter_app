class Note {
  final int? id;
  final String title;
  final String content;
  final DateTime? reminderAt;
  final bool synced;

  Note({
    this.id,
    required this.title,
    required this.content,
    this.reminderAt,
    this.synced = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'content': content,
        'reminderAt': reminderAt?.toIso8601String(),
        'synced': synced ? 1 : 0,
      };

  factory Note.fromMap(Map<String, dynamic> map) => Note(
        id: map['id'] as int?,
        title: map['title'] as String,
        content: map['content'] as String,
        reminderAt:
            map['reminderAt'] != null ? DateTime.parse(map['reminderAt'] as String) : null,
        synced: (map['synced'] as int? ?? 0) == 1,
      );

  factory Note.fromApiJson(Map<String, dynamic> json) => Note(
        id: json['id'] as int?,
        title: json['title'] as String? ?? '',
        content: json['body'] as String? ?? '',
      );
}