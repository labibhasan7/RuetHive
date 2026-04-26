import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

class UserService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<AppUser?> getCurrentUser() async {
  final uid = _auth.currentUser?.uid;
  if (uid == null) return null;

  final doc = await _db.collection('users').doc(uid).get();
  if (!doc.exists) return null;

  return AppUser.fromMap(doc.data()!, doc.id);
}
}