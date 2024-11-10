import 'package:application_dart/models/parked.dart';
import 'package:application_dart/services/parked.dart';

class ParkedRepository{
  final ParkedService _service = ParkedService();

  Future<Parked?> getParked() async {
    final parked = await _service.fetchParked();
    return parked;
  }
  // Add a new parked record
  Future<bool> addParked(Parked parked) async {
    return await _service.addParked(parked);
  }

  Future<bool> leaveParked() async {
    return await _service.leaveParked();
  }
  
}