import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SellerHome extends StatefulWidget {
  const SellerHome({super.key});

  @override
  State<SellerHome> createState() => _SellerHomeState();
}

class _SellerHomeState extends State<SellerHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<double>(
              future: calculateTotalAmount(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }
                return Text(
                  "Total Amount Earned: ₹${snapshot.data}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              "All Products:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: fetchProducts(),
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
                  }
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        child: ListTile(
                          title: Text(product['name']),
                          subtitle: Text("Price: ₹${product['Cost']}"),
                          // trailing: Text(
                          //   product['sold'] ? "Sold" : "Available",
                          //   style: TextStyle(
                          //     color:
                          //         product['sold'] ? Colors.green : Colors.red,
                          //     fontWeight: FontWeight.bold,
                          //   ),
                          // ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
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

Stream<QuerySnapshot> fetchProducts() {
  return FirebaseFirestore.instance.collection('products').snapshots();
}
