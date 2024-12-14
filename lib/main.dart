import 'package:farmer_auction_app/Auth/splash.dart';
import 'package:farmer_auction_app/Onboading/onboarding_view.dart';
import 'package:farmer_auction_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final onboarding = prefs.getBool("onboarding") ?? false;

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

  runApp(MyApp(onboarding: onboarding));
}

class MyApp extends StatelessWidget {
  final bool onboarding;
  const MyApp({super.key, this.onboarding = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      home: onboarding ? const Splash() : const OnboardingView(),
      // home: const OnboardingView(),
    );
  }
}
