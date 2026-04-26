import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruethive/services/user_service.dart';
import '../../models/app_user.dart';

final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  return UserService().getCurrentUser();
});