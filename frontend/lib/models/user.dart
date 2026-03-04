class User {
  final String id;
  final String name;
  final String email;
  final String role; // 'guest', 'user', 'admin'
  final String? phone;
  final String? address;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'user',
    this.phone,
    this.address,
  });

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'address': address,
    };
  }

  // JSON deserialization
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['_id'] ?? json['id'] ?? '') as String, // MongoDB vraća _id, ali fallback na id
      name: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      role: (json['role'] ?? 'user') as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? phone,
    String? address,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }

  @override
  String toString() => 'User(id: $id, name: $name, email: $email, role: $role)';
}
