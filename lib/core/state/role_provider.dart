import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRole { student, cr, admin }

final roleProvider = StateProvider<UserRole?>((ref) => null);