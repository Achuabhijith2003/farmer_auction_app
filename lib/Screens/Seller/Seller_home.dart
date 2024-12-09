import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmer_auction_app/Servies/firebase_servies.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SellerHome extends StatefulWidget {
  const SellerHome({super.key});

  @override
  State<SellerHome> createState() => _SellerHomeState();
}

class _SellerHomeState extends State<SellerHome> {
  Firebaseseller firebaseseller = Firebaseseller();

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
                    "Dashboard",
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<double>(
                    future: calculateTotalAmount(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      }
                      return Center(
                        child: Card(
                          child: Text(
                            "Total Amount Earned: ₹${snapshot.data}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        "All Products",
                        style: GoogleFonts.dmSerifDisplay(
                            fontSize: 27, letterSpacing: 4),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: firebaseseller.fetchsellerProducts(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        }
                        final products = snapshot.data?.docs ?? [];
                        if (products.isEmpty) {
                          return const Center(
                              child: Text("No products uploaded."));
                        } else {
                          return ListView.builder(
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return Card(
                                child: ListTile(
                                  title: Text(product['name']),
                                  subtitle: Text("Price: ₹${product['Cost']}"),
                                  trailing: Text(
                                    product['sold'] ? "Available" : "sold",
                                    style: TextStyle(
                                      color: product['sold']
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ))
      ]),
    );
  }
}

Future<double> calculateTotalAmount() async {
  double totalAmount = 0.0;

  QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('products').get();

  for (var doc in snapshot.docs) {
    String costString = doc['Cost']; // Assuming this is a string like "123"
    int costInt = int.parse(costString);
    totalAmount += costInt;
  }

  return totalAmount;
}
