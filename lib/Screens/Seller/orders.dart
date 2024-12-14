import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  // Fetch orders from Firestore
  Future<List<Map<String, dynamic>>> fetchOrders() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection("Orders").get();

      // Convert documents to a list of maps
      return querySnapshot.docs
          .map((doc) => {"id": doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      print("Error fetching orders: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Orders",
          style: GoogleFonts.aBeeZee(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 27),
        ),
        backgroundColor: Colors.red[600],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchOrders(),
        builder: (context, snapshot) {
          // Check connection state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Check for errors
          if (snapshot.hasError) {
            return const Center(child: Text("Error fetching orders."));
          }

          // Check if data is empty
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text("No orders found."));
          }

          // Build the list of cards
          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Product Name: ${order['Product_name'] ?? 'Unknown'}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text("Buyer Name: ${order['Username'] ?? 'Unknown'}"),
                      const SizedBox(height: 8),
                      Text("Cost: ₹${order['Product_cost'] ?? '0.00'}"),
                      const SizedBox(height: 8),
                      Text(
                          "Payment Method: ${order['Payment_methods'] ?? 'Unknown'}"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
