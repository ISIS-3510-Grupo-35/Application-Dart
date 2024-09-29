// ignore_for_file: depend_on_referenced_packages

import 'package:http/http.dart' as http;

class UserService {

  Future<http.Response> fetchUsers() async {
    return await http.get(Uri.parse('apiUrl'));
  }

  Future<http.Response> fetchUserById(int id) async {
    return await http.get(Uri.parse('apiUrl/$id'));
  }

  Future<http.Response> createUser(Map<String, dynamic> user) async {
    return await http.post(
      Uri.parse('apiUrl'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: user,
    );
  }

  Future<http.Response> updateUser(int id, Map<String, dynamic> user) async {
    return await http.put(
      Uri.parse('apiUrl/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: user,
    );
  }

  Future<http.Response> deleteUser(int id) async {
    return await http.delete(Uri.parse('apiUrl/$id'));
  }
}