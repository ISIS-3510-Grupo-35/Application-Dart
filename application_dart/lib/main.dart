import 'package:application_dart/services/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:application_dart/locator.dart'; // Import service locator
import 'package:application_dart/view_models/parking_lot.dart';
import 'package:application_dart/view_models/localization.dart';
import 'package:application_dart/views/Login/first.dart';
import 'package:application_dart/views/navigation/background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure widgets binding is initialized
    // Initialize Firebase
  await Firebase.initializeApp();
  // Initialize GetIt service locator
  setupLocator();

  // Set preferred device orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Run the app wrapped with the necessary providers
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationViewModel()), // Register LocationViewModel
        ChangeNotifierProvider(create: (_) => ParkingLotViewModel()), // Register ParkingLotViewModel
         Provider<ConnectivityService>(create: (_) => ConnectivityService(), dispose: (_, service) => service.dispose(),),
      ],
      child: const MyApp(), // Use MyApp as the root widget
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const FirstScreen(),
        '/home': (context) => const BackgroundScreen(),
      },
    );
  }
}
