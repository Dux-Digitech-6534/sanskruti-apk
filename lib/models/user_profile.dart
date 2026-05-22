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
      role: json['role']?.toString(),
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
