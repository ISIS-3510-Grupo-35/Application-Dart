import 'package:get_it/get_it.dart';
import 'package:application_dart/repositories/parking_lot.dart';
import 'package:application_dart/repositories/reservation.dart';
import 'package:application_dart/repositories/review.dart';
import 'package:application_dart/repositories/user.dart';
import 'package:application_dart/view_models/parking_lot.dart';
import 'package:application_dart/view_models/reservation.dart';
import 'package:application_dart/view_models/review.dart';
import 'package:application_dart/view_models/user.dart';

// Export the locator instance
export 'package:get_it/get_it.dart' show GetIt;

final locator = GetIt.instance;

void setupLocator() {
  // Repositories
  locator.registerLazySingleton(() => ParkingLotRepository());
  locator.registerLazySingleton(() => ReservationRepository());
  locator.registerLazySingleton(() => ReviewRepository());
  locator.registerLazySingleton(() => UserRepository());

  // ViewModels
  locator.registerFactory(() => ParkingLotViewModel());
  locator.registerFactory(() => ReservationsViewModel());
  locator.registerFactory(() => ReviewsViewModel());
  locator.registerFactory(() => UsersViewModel());
}