import '../core/state/role_provider.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String studentId;
  final String department;
  final String batch;
  final String section;
  final UserRole role;
  final String memberSince;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.studentId,
    required this.department,
    required this.batch,
    required this.section,
    required this.role,
    required this.memberSince,
  });

    /// Short first name for greetings
  String get firstName => name.split(' ').first;

  /// Initials for avatar fallback
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  /// One-line academic summary
  String get academicSummary => '$department • $batch • Section $section';


  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      studentId: map['studentId'] ?? '',
      department: map['department'] ?? '',
      batch: map['batch'] ?? '',
      section: map['section'] ?? '',
      role: _parseRole(map['role']),
      memberSince: map['memberSince'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'studentId': studentId,
      'department': department,
      'batch': batch,
      'section': section,
      'role': role.name,
      'memberSince': memberSince,
    };
  }

  static UserRole _parseRole(String? role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'cr':
        return UserRole.cr;
      default:
        return UserRole.student;
    }
  }
}