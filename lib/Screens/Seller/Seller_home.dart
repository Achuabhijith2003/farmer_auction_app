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
      appBar: AppBar(
        title: Text(
          "Dashboard",
          style: GoogleFonts.aBeeZee(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 27),
        ),
        backgroundColor: Colors.red[600],
      ),
      body: Column(
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
                  elevation: 10,
                  child: Text(
                    "Total Amount Earned \n   \t\t ₹${snapshot.data}",
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
                style: GoogleFonts.aBeeZee(
                    color: Colors.red[900],
                    fontWeight: FontWeight.bold,
                    fontSize: 27),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firebaseseller.fetchsellerProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }
                final products = snapshot.data?.docs ?? [];
                if (products.isEmpty) {
                  return const Center(child: Text("No products uploaded."));
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
                              color:
                                  product['sold'] ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {},
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
