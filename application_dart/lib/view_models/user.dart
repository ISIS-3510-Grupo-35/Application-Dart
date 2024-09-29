import 'package:application_dart/models/user.dart';
import 'package:application_dart/repositories/user.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class UsersViewModel extends ChangeNotifier {
  final UserRepository _repository = GetIt.instance<UserRepository>();
  
  List<User> _users = [];
  bool fetchingData = false;
  List<User> get users => _users;

  Future<void> fetchUsers() async {
    fetchingData = true;
    try {
      _users = await _repository.getUsers();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load Userss: $e');
    }
    fetchingData = false;
  }
}