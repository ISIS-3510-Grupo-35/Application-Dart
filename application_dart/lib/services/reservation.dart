// ignore_for_file: depend_on_referenced_packages

import 'package:http/http.dart' as http;

class ReservationService {

  Future<http.Response> fetchReservations() async {
    return await http.get(Uri.parse('apiUrl'));
  }

  Future<http.Response> fetchReservationById(int id) async {
    return await http.get(Uri.parse('apiUrl/$id'));
  }

  Future<http.Response> createReservation(Map<String, dynamic> reservation) async {
    return await http.post(
      Uri.parse('apiUrl'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: reservation,
    );
  }

  Future<http.Response> updateReservation(int id, Map<String, dynamic> reservation) async {
    return await http.put(
      Uri.parse('apiUrl/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: reservation,
    );
  }

  Future<http.Response> deleteReservation(int id) async {
    return await http.delete(Uri.parse('apiUrl/$id'));
  }
}