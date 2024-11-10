// ignore_for_file: depend_on_referenced_packages

import 'package:application_dart/models/userapp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserAppService {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> fetchUserApp(String uuid) async {
    var user = await _firestore.collection('users').doc(uuid).get();
    return user.data();
  }

  Future<http.Response> fetchUserAppById(int id) async {
    return await http.get(Uri.parse('apiUrl/$id'));
  }

  Future<void> createUserApp(UserApp user, String uuid) async {
    await _firestore.collection('users').doc(uuid).set(user.toJson());
  }

  Future<Map<bool, String>> changePassword(
      String currentPassword, String newPassword) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_uid');
      if (userId == null) {
        return {false: 'User not found'};
      }

      var response = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (!response.exists) {
        return {false: 'User not found in database'};
      }

      UserApp userModel =
          UserApp.fromJson(response.data() as Map<String, dynamic>);

      // Check if the current password is correct
      if (userModel.password != currentPassword) {
        return {false: 'Current password is incorrect'};
      }
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);

        await user.updatePassword(newPassword);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'password': newPassword});

        return {true: 'Password changed successfully'};
      } else {
        return {false: 'User not logged in'};
      }
    } catch (e) {
      return {false: 'Error occurred: ${e.toString()}'};
    }
  }
}
