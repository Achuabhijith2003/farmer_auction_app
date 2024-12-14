import 'package:farmer_auction_app/Screens/Seller/Orders.dart';
import 'package:farmer_auction_app/Screens/Seller/Seller_autions.dart';
import 'package:farmer_auction_app/Screens/Seller/Seller_home.dart';
import 'package:farmer_auction_app/Screens/Seller/Seller_profile.dart';
import 'package:farmer_auction_app/Screens/Seller/add_products.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SellerRemasterHome extends StatefulWidget {
  const SellerRemasterHome({super.key});

  @override
  State<SellerRemasterHome> createState() => _SellerRemasterHomeState();
}

class _SellerRemasterHomeState extends State<SellerRemasterHome> {
  @override
  void initState() {
    super.initState();
  }

  int _cureentindex = 0;
  List<Widget> body = const [
    SellerHome(),
    SellerAutions(),
    Addproducts(),
    Orders(),
    SellerProfile()
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
            selectedItemColor: Colors.white70,
            enableFeedback: true,
            backgroundColor: Colors.red,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            unselectedLabelStyle: GoogleFonts.aBeeZee(
                color: Colors.red[600],
                fontWeight: FontWeight.bold,
                fontSize: 15),
            selectedLabelStyle: GoogleFonts.aBeeZee(
                color: Colors.red[600],
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
                  icon: Icon(
                    Icons.groups_rounded,
                    // color: Color(
                    //     int.parse("#f5f3ef".substring(1, 7), radix: 16) +
                    //         0xFF000000),
                  ),
                  label: "Auctions"),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.add_circle_outline,
                    // color: Color(
                    //     int.parse("#f5f3ef".substring(1, 7), radix: 16) +
                    //         0xFF000000),
                  ),
                  label: "Add Products"),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.shopping_cart_checkout_rounded,
                    // color: Color(
                    //     int.parse("#f5f3ef".substring(1, 7), radix: 16) +
                    //         0xFF000000),
                  ),
                  label: "Orders"),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.person_pin,
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
