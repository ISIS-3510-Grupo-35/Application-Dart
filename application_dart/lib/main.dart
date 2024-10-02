import 'package:application_dart/views/Login/first.dart';
import 'package:application_dart/views/navigation/background.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
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
