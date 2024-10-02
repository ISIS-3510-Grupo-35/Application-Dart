// firebase_auth_view_model.dart

import 'package:application_dart/repositories/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

class FirebaseAuthViewModel extends ChangeNotifier {
  final FirebaseAuthRepository _authRepository = GetIt.instance<FirebaseAuthRepository>();

  User? _currentUser;
  User? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Register a new user with email and password.
  Future<void> register(String email, String password) async {
    _setLoading(true);
    try {
      _currentUser = await _authRepository.signUp(email, password);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to register: $e';
    } finally {
      _setLoading(false);
    }
    notifyListeners();
  }

  /// Log in an existing user with email and password.
  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      _currentUser = await _authRepository.signIn(email, password);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to login: $e';
    } finally {
      _setLoading(false);
    }
    notifyListeners();
  }

  /// Set loading state.
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
