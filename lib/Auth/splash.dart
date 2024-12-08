import 'package:farmer_auction_app/Auth/loginpage.dart';
import 'package:farmer_auction_app/Screens/Buyer/Remasted_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';

// import 'package:learnxt/Services/Gadsmob.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    // admob ads = admob();
    // Appopenadd
    // ads.AppOpenAdload();
    return Scaffold(
      body: Center(
        child: FlutterSplashScreen.gif(
          backgroundColor: Color(
              int.parse("#f5f3ef".substring(1, 7), radix: 16) + 0xFF000000),
          gifPath: 'assets/XT.gif',
          gifWidth: 269,
          gifHeight: 474,
          nextScreen: (FirebaseAuth.instance.currentUser != null)
              ? const RemastedHome()
              : const Loginpage(),
          duration: const Duration(milliseconds: 3515),
          onInit: () async {
            debugPrint("onInit");
          },
          onEnd: () async {
            debugPrint("onEnd 1");
          },
        ),
      ),
    );
  }
}
