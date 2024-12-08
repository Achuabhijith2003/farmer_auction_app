import 'package:farmer_auction_app/Auth/splash.dart';
import 'package:farmer_auction_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  print('Before Firebase initialization: ${Firebase.apps}');
  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized successfully.');
    } catch (e) {
      print('Error initializing Firebase: $e');
    }
  } else {
    print('Firebase App already initialized: ${Firebase.apps}');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: true,
      home: Splash(),
    );
  }
}
