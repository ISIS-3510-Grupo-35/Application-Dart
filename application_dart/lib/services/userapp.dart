// ignore_for_file: depend_on_referenced_packages

import 'package:application_dart/models/userapp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class UserAppService {

  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> fetchUserApp(String uuid) async {
    var user = await _firestore.collection('users_android').doc(uuid).get();
    return user.data();
  }

  Future<http.Response> fetchUserAppById(int id) async {
    return await http.get(Uri.parse('apiUrl/$id'));
  }

  Future<void> createUserApp(UserApp user, String uuid) async {
    await _firestore.collection('users_android').doc(uuid).set(user.toJson());
  }

  Future<http.Response> updateUserApp(int id, Map<String, dynamic> UserApp) async {
    return await http.put(
      Uri.parse('apiUrl/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: UserApp,
    );
  }

  Future<http.Response> deleteUserApp(int id) async {
    return await http.delete(Uri.parse('apiUrl/$id'));
  }
}