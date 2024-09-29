import 'package:application_dart/models/parking_lot.dart';
import 'package:application_dart/repositories/parking_lot.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ParkingLotViewModel extends ChangeNotifier {
  final ParkingLotRepository _repository = GetIt.instance<ParkingLotRepository>();
  
  List<ParkingLot> _parkingLots = [];
  bool fetchingData = false;
  List<ParkingLot> get parkingLots => _parkingLots;

  Future<void> fetchParkingLots() async {
    fetchingData = true;
    try {
      _parkingLots = await _repository.getParkingLots();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load ParkingLots: $e');
    }
    fetchingData = false;
  }
}