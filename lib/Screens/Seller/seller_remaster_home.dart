import 'package:farmer_auction_app/Screens/Seller/Seller_home.dart';
import 'package:farmer_auction_app/Screens/Seller/Seller_profile.dart';
import 'package:farmer_auction_app/Screens/Seller/add_products.dart';
import 'package:flutter/material.dart';

class SellerRemasterHome extends StatefulWidget {
  const SellerRemasterHome({super.key});

  @override
  State<SellerRemasterHome> createState() => _SellerRemasterHomeState();
}

class _SellerRemasterHomeState extends State<SellerRemasterHome> {
  void initState() {
    super.initState();
  }

  int _cureentindex = 0;
  List<Widget> body = const [SellerHome(), Addproducts(), SellerProfile()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: body[_cureentindex]),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomNavigationBar(
            selectedFontSize: 20,
            selectedItemColor: Colors.black,
            enableFeedback: true,
            backgroundColor: Color(
                int.parse("#f5f3ef".substring(1, 7), radix: 16) + 0xFF000000),
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
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
                  label: "Add Products"),
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
