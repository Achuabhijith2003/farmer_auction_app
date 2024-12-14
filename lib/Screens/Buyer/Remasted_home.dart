import 'package:farmer_auction_app/Screens/Buyer/Aution.dart';
import 'package:farmer_auction_app/Screens/Buyer/Profile.dart';
import 'package:farmer_auction_app/Screens/Buyer/cart.dart';
import 'package:farmer_auction_app/Screens/Buyer/offersale.dart';
import 'package:farmer_auction_app/Screens/Buyer/home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RemastedHome extends StatefulWidget {
  const RemastedHome({super.key});

  @override
  State<RemastedHome> createState() => _RemastedHomeState();
}

class _RemastedHomeState extends State<RemastedHome> {
  @override
  void initState() {
    super.initState();
  }

  int _cureentindex = 0;

  List<Widget> body = const [
    Home(),
    Aution(),
    Flasesale(),
    Cart(),
    BuyerProfile()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: body[_cureentindex]),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomNavigationBar(
            selectedFontSize: 20,
            selectedItemColor: Colors.white,
            enableFeedback: true,
            backgroundColor: Colors.green[700],
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            unselectedLabelStyle: GoogleFonts.aBeeZee(
                color: Colors.green[900],
                fontWeight: FontWeight.bold,
                fontSize: 15),
            selectedLabelStyle: GoogleFonts.aBeeZee(
                color: Colors.green[900],
                fontWeight: FontWeight.bold,
                fontSize: 17),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home_outlined,
                    // color: Color(
                    //     int.parse("#f5f3ef".substring(1, 7), radix: 16) +
                    //         0xFF000000),
                  ),
                  label: "Home"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.groups_outlined), label: "Aution"),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.local_offer_outlined,
                    // color: Color(
                    //     int.parse("#f5f3ef".substring(1, 7), radix: 16) +
                    //         0xFF000000),
                  ),
                  label: "offer"),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.shopping_bag_outlined,
                ),
                label: "Cart",
              ),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.person_pin_outlined,
                    // color: Color(
                    //     int.parse("#f5f3ef".substring(1, 7), radix: 16) +
                    //         0xFF000000),
                  ),
                  label: "Profile"),
            ],
            currentIndex: _cureentindex,
            onTap: (value) {
              setState(() {
                _cureentindex = value;
              });
            },
          ),
          // Display banner ad if loaded
        ],
      ),
    );
  }
}
