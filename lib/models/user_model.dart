class AppUser {
  final int? id;
  final String username;
  final String email;
  final String passwordHash;
  final String role;

  AppUser({
    this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
    this.role = 'usuario',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'username': username,
        'email': email,
        'passwordHash': passwordHash,
        'role': role,
      };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        id: map['id'] as int?,
        username: map['username'] as String,
        email: map['email'] as String,
        passwordHash: map['passwordHash'] as String,
        role: map['role'] as String? ?? 'usuario',
      );
}