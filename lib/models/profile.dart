class Profile {
  final String id;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String role;
  final DateTime? createdAt;

  const Profile({
    required this.id,
    this.email,
    this.firstName,
    this.lastName,
    required this.role,
    this.createdAt,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    // The role name lives in `roles`; profiles only hold `role_id`.
    final roles = map['roles'];
    final roleName = roles is Map
        ? roles['role']?.toString()
        : (roles is List && roles.isNotEmpty && roles.first is Map)
            ? (roles.first as Map)['role']?.toString()
            : null;

    return Profile(
      id: map['id'].toString(),
      email: map['email'] as String?,
      firstName: map['firstname'] as String?,
      lastName: map['lastname'] as String?,
      role: roleName ?? 'customer',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
    );
  }

  String get fullName {
    final name = [
      firstName?.trim() ?? '',
      lastName?.trim() ?? '',
    ].where((part) => part.isNotEmpty).join(' ');

    return name.isEmpty ? 'User' : name;
  }

  bool get isAdmin => role == 'admin';

  bool get isCustomer => role == 'customer';
}
