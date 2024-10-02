import 'package:application_dart/locator.dart';
import 'package:application_dart/view_models/parking_lot.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:application_dart/view_models/localization.dart';
import 'package:application_dart/views/Login/first.dart';
import 'package:application_dart/views/navigation/background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Call setupLocator to register dependencies with GetIt
  setupLocator();

  // Restrict the app to portrait orientation only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(
      // Wrap the app with MultiProvider to include your view models
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocationViewModel()), // LocationViewModel provider
          ChangeNotifierProvider(create: (_) => ParkingLotViewModel()), // Add ParkingLotViewModel provider here
          // Add more providers here if needed
        ],
        child: const MyApp(),
      ),
    );
  });
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
