import 'package:farmer_auction_app/Auth/loginpage.dart';
import 'package:farmer_auction_app/Servies/firebase_servies.dart';
import 'package:flutter/material.dart';

class BuyerProfile extends StatefulWidget {
  const BuyerProfile({super.key});

  @override
  State<BuyerProfile> createState() => BuyerProfileState();
}

class BuyerProfileState extends State<BuyerProfile> {
  FirebaseServies auth = FirebaseServies();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          
          CircleAvatar(
            backgroundImage: AssetImage("assets/ai logo.jpeg"),
          )
        ],
      ),
    );
  }
}
