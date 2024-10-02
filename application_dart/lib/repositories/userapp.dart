import 'package:application_dart/models/userapp.dart';
import 'package:application_dart/services/userapp.dart';

class UserAppRepository {
  final UserAppService _service = UserAppService();

  Future<UserApp> getUserApp(String uuid) async {
    final response = await _service.fetchUserApp(uuid);
    if (response != null) {
      return UserApp.fromJson(response);
    } else {
      throw Exception('Failed to load UserApp');
    }
  }

  Future<UserApp> createUserApp(UserApp user, String uuid) async {
    await _service.createUserApp(user, uuid);
    return user;
  }
}