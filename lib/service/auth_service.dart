// lib/service/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print("Password reset email sent.");
    } catch (e) {
      print("Error sending reset email: $e");
    }
  }

  Future<void> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      print("User registered successfully.");
    } catch (e) {
      throw "Error registering user: $e";
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      print("User logged out successfully.");
    } catch (e) {
      print("Error logging out: $e");
    }
  }
}
