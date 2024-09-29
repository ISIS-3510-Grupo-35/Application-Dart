import 'dart:convert';

import 'package:application_dart/models/user.dart';
import 'package:application_dart/services/user.dart';

class UserRepository {
  final UserService _service = UserService();

  Future<List<User>> getUsers() async {
    final response = await _service.fetchUsers();

    if (response.statusCode == 200) {
      return List<User>.from(
          json.decode(response.body).map((x) => User.fromJson(x)));
    } else {
      throw Exception('Failed to load superheroes');
    }
  }
}