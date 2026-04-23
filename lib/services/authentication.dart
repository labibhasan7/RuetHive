import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // 🟢 SIGN UP
  Future<User?> signUp(
  String email,
  String password,
  String section,
  String department,
  String rollNumber,
) async {
  final userCredential = await _auth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  final user = userCredential.user;

  if (user != null) {
    await _db.collection('users').doc(user.uid).set({
      'email': email,
      'section': section,
      'department': department,
      'rollNumber': rollNumber,
      'role': 'student', // 🔥 default role
    });
  }

  return user;
}

  // 🟢 LOGIN
  Future<User?> login(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return userCredential.user;
  }

  // 🟢 GET ROLE
  Future<String> getUserRole(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc['role'];
  }

  // 🟢 LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}