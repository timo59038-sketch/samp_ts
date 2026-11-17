enum UserRole { student, advisor }

class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });
  final String id;
  final String name;
  final String email;
  final UserRole role;
  factory User.fromMap(String id, Map<String, dynamic> data) => User(
    id: id,
    name: data['name'] as String,
    email: data['email'] as String,
    role: UserRole.values.byName(data['role'] as String),
  );
  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'role': role.name,
  };
}
