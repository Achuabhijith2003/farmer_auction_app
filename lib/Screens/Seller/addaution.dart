import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmer_auction_app/Servies/firebase_servies.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Addaution extends StatefulWidget {
  const Addaution({super.key});

  @override
  State<Addaution> createState() => _AddautionState();
}

class _AddautionState extends State<Addaution> {
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController startingPriceController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  Firebaseseller sellerbase = Firebaseseller();
  void createAuction() async {
    String productName = productNameController.text.trim();
    double startingPrice = double.tryParse(startingPriceController.text) ?? 0.0;
    DateTime endTime =
        DateTime.tryParse(endTimeController.text) ?? DateTime.now();

    if (productName.isEmpty ||
        startingPrice <= 0 ||
        endTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields correctly.')),
      );
      return;
    }

    // Add auction details to Firestore
    try {
      await FirebaseFirestore.instance.collection('auctions').add({
        'productName': productName,
        'startingPrice': startingPrice,
        'currentPrice': startingPrice,
        'endTime': endTime,
        'sellerId': sellerbase.getuserID(), // Replace with actual seller ID
        'createdAt': DateTime.now(),
        'status':"ongoing"
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Auction created successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create auction: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 36, left: 5, right: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 10),
                  Text(
                    "Add aution",
                    style: GoogleFonts.dmSerifDisplay(
                        fontSize: 40, letterSpacing: 4),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
            top: 100,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: productNameController,
                      decoration: InputDecoration(labelText: 'Product Name'),
                    ),
                    TextField(
                      controller: startingPriceController,
                      decoration: InputDecoration(labelText: 'Starting Price'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: endTimeController,
                      decoration: InputDecoration(
                          labelText: 'End Time (yyyy-MM-dd HH:mm:ss)'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: createAuction,
                      child: Text('Create Auction'),
                    ),
                  ],
                ),
              ),
            ))
      ]),
    );
  }
}
