import 'package:application_dart/views/Login/first.dart';
import 'package:application_dart/views/navigation/background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
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
