import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<void> registerGuardian({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user!.uid;
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'phone': phone,
      'user_type': 'guardian',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> loginGuardian(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final doc = await _db.collection('users').doc(cred.user!.uid).get();
    if (doc.data()?['user_type'] != 'guardian') {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'wrong-user-type',
        message: 'هذا الحساب مسجل كفريق إنقاذ، يرجى استخدام صفحة الدخول الصحيحة',
      );
    }
  }

  Future<void> loginRescuer(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final doc = await _db.collection('users').doc(cred.user!.uid).get();
    if (doc.data()?['user_type'] != 'rescuer') {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'wrong-user-type',
        message: 'هذا الحساب مسجل كولي أمر، يرجى استخدام صفحة الدخول الصحيحة',
      );
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}