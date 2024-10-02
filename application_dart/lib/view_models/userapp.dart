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

  set userApp(UserApp? userApp) {
    _UserApp = userApp;
    notifyListeners();
  }

  void clearUserApp() {
    _UserApp = null;
    notifyListeners();
  }
}