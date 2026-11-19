/// Represents an authenticated JanSamasya user.
///
/// Matches the JSON structures returned by:
/// - POST /api/auth/login & POST /api/auth/signup (`id`, `username`, `email`, `role`, `state`, `area`)
/// - GET /api/user/profile (`id`, `username`, `role`, `state`, `area`)
class User {
  final String id;
  final String username;
  final String? email;
  final String role;
  final String state;
  final String? area;

  const User({
    required this.id,
    required this.username,
    this.email,
    required this.role,
    required this.state,
    this.area,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      email: json['email'] != null && json['email'].toString().isNotEmpty
          ? json['email'].toString()
          : null,
      role: (json['role'] ?? 'user').toString(),
      state: (json['state'] ?? '').toString(),
      area: json['area'] != null && json['area'].toString().trim().isNotEmpty
          ? json['area'].toString().trim()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      if (email != null) 'email': email,
      'role': role,
      'state': state,
      if (area != null) 'area': area,
    };
  }
}
