import 'package:application_dart/models/parked.dart';
import 'package:application_dart/repositories/parked.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParkedViewModel extends ChangeNotifier {
  final ParkedRepository _repository = GetIt.instance<ParkedRepository>();

  Parked? _parked;

  Parked? get parked => _parked;
  bool fetchingData = false;

  Future<void> fetchParkedCar() async {
    try {
      fetchingData = true;
      _parked = await _repository.getParked(); // Fetch the parked car
      fetchingData = false;
      notifyListeners();
    } catch (e) {
      fetchingData = false;
      print('Error fetching parked car: $e');
    }
  }

  Future<void> addParked(String parkingLotId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userUid = prefs.getString('user_uid');

      final newParked = Parked(
        parking: parkingLotId,
        user: userUid ?? '',
        time: DateTime.now(),
        exit: false,
      );

      bool success = await _repository.addParked(newParked);

      if (success) {
        _parked = newParked;
        notifyListeners();
      } else {
        throw Exception('Failed to add parked');
      }
    } catch (e) {
      print('Error adding parked: $e');
      throw Exception('Failed to add parked: $e');
    }
  }

  Future<bool> leaveParked() async {
    try {
      bool success = await _repository.leaveParked();

      if (success) {
        _parked = null;
        notifyListeners();
        return true;
      } else {
        throw Exception('Failed to leave parked');
      }
    } catch (e) {
      print('Error leaving parked: $e');
      throw Exception('Failed to leave parked: $e');
    }
  }
}
