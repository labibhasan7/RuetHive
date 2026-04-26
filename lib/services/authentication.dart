import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // SIGN UP

  Future<void> signUp({
    required String email,
    required String password,
    required AppUser user,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _firestore
        .collection('users')
        .doc(cred.user!.uid)
        .set(user.toMap());
  }

  // LOGIN

  Future<User?> login({
  required String email,
  required String password,
}) async {
  try {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return cred.user;
  } on FirebaseAuthException catch (e) {
    throw Exception(e.message);
  }
}

  // GET USER

  Future<AppUser> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return AppUser.fromMap(doc.data()!, uid);
  }

  // LOGOUT

  Future<void> logout() async {
    await _auth.signOut();
  }
}