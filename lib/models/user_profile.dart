class UserProfile {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    this.role,
    this.site,
  });

  final String id;
  final String fullName;
  final String email;
  final String? role;
  final String? site;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['name']?.toString() ?? json['id']?.toString() ?? '',
      fullName:
          json['full_name']?.toString() ??
          json['fullName']?.toString() ??
          json['name']?.toString() ??
          'Sanskruti User',
      email: json['email']?.toString() ?? json['user']?.toString() ?? '',
      role: _roleFromJson(json),
      site: json['site']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': id,
      'full_name': fullName,
      'email': email,
      'role': role,
      'site': site,
    };
  }
}

String? _roleFromJson(Map<String, dynamic> json) {
  final directRole = json['role']?.toString().trim();
  if (directRole != null && directRole.isNotEmpty) return directRole;

  final roles = json['roles'];
  if (roles is List) {
    final labels = roles
        .whereType<Map>()
        .map((role) => role['role']?.toString().trim() ?? '')
        .where((role) => role.isNotEmpty)
        .toSet()
        .toList();
    if (labels.isNotEmpty) return labels.join(', ');
  }

  final userType = json['user_type']?.toString().trim();
  return userType == null || userType.isEmpty ? null : userType;
}
