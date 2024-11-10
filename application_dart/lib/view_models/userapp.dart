import 'package:application_dart/models/userapp.dart';
import 'package:application_dart/repositories/userapp.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class UserAppViewModel extends ChangeNotifier {
  final UserAppRepository _repository = GetIt.instance<UserAppRepository>();
  
  UserApp? _UserApp;
  bool fetchingData = false;

  Future<UserApp?> fetchUserApp(String uuid) async {
    fetchingData = true;
    try {
      _UserApp = await _repository.getUserApp(uuid);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load UserAppss: $e');
    }
    fetchingData = false;
    return _UserApp;
  }

  Future<UserApp?> createUserApp(UserApp user, String uuid) async {
    try {
      _UserApp = await _repository.createUserApp(user, uuid);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to create UserApp: $e');
    }
    return _UserApp;
  }

  Future<Map<bool, String>> changePassword(String password, String newPassword) async {
    final response = await _repository.changePassword(password, newPassword);
    return response;
  }

  set userApp(UserApp? userApp) {
    _UserApp = userApp;
    notifyListeners();
  }

  void clearUserApp() {
    _UserApp = null;
    notifyListeners();
  }
}