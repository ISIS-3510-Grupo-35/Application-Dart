import 'package:application_dart/repositories/firebase_auth.dart';
import 'package:application_dart/view_models/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:application_dart/repositories/parking_lot.dart';
import 'package:application_dart/repositories/reservation.dart';
import 'package:application_dart/repositories/review.dart';
import 'package:application_dart/repositories/userapp.dart';
import 'package:application_dart/view_models/parking_lot.dart';
import 'package:application_dart/view_models/reservation.dart';
import 'package:application_dart/view_models/review.dart';
import 'package:application_dart/view_models/userapp.dart';

// Export the locator instance
export 'package:get_it/get_it.dart' show GetIt;

final locator = GetIt.instance;

void setupLocator() {
  // Repositories
  locator.registerLazySingleton(() => ReservationRepository());
  locator.registerLazySingleton(() => ReviewRepository());
  locator.registerLazySingleton(() => UserAppRepository());
  locator.registerLazySingleton(() => FirebaseAuthRepository());
  locator.registerSingleton<ParkingLotRepository>(ParkingLotRepository());

  // ViewModels
  locator.registerFactory(() => ParkingLotViewModel());
  locator.registerFactory(() => ReservationViewModel());
  locator.registerFactory(() => ReviewsViewModel());
  locator.registerFactory(() => FirebaseAuthViewModel());
  locator.registerFactory(() => UserAppViewModel());
}