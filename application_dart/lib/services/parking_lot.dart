// ignore_for_file: depend_on_referenced_packages

import 'package:http/http.dart' as http;

class ParkingLotService {

  Future<http.Response> fetchParkingLots() async {
    return await http.get(Uri.parse('apiUrl'));
  }

  Future<http.Response> fetchParkingLotById(int id) async {
    return await http.get(Uri.parse('apiUrl/$id'));
  }

  Future<http.Response> createParkingLot(Map<String, dynamic> parkingLot) async {
    return await http.post(
      Uri.parse('apiUrl'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: parkingLot,
    );
  }

  Future<http.Response> updateParkingLot(int id, Map<String, dynamic> parkingLot) async {
    return await http.put(
      Uri.parse('apiUrl/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: parkingLot,
    );
  }

  Future<http.Response> deleteParkingLot(int id) async {
    return await http.delete(Uri.parse('apiUrl/$id'));
  }
}