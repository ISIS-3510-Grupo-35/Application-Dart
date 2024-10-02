// service_locator.dart
import 'package:application_dart/repositories/parking_lot.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

void setupLocator() {
  getIt.registerSingleton<ParkingLotRepository>(ParkingLotRepository());
}
