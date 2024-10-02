import 'package:application_dart/view_models/localization.dart';
import 'package:application_dart/views/Login/first.dart';
import 'package:application_dart/views/navigation/background.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(
      // Wrap the app with MultiProvider to include your LocationViewModel
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocationViewModel()), // Add LocationViewModel provider here
        ],
        child: MyApp(),
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
      // Define your routes
      initialRoute: '/',
      routes: {
        '/': (context) => const FirstScreen(),
        '/home': (context) => const BackgroundScreen(),
      },
    );
  }
}
