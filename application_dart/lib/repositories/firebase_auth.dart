// firebase_auth_repository.dart

import 'package:application_dart/services/firebase_auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthRepository {
  final FirebaseAuthServices _authServices;

  FirebaseAuthRepository({FirebaseAuthServices? authServices})
      : _authServices = authServices ?? FirebaseAuthServices();

  /// Sign up a user with email and password, returns the [User] if successful.
  Future<User?> signUp(String email, String password) async {
    try {
      return await _authServices.signUpWithEmailAndPassword(email, password);
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in a user with email and password, returns the [User] if successful.
  Future<User?> signIn(String email, String password) async {
    try {
      return await _authServices.signInWithEmailAndPassword(email, password);
    } catch (e) {
      rethrow;
    }
  }

}
