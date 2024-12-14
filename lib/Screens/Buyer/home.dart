import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmer_auction_app/Screens/Buyer/product_info.dart';
import 'package:farmer_auction_app/Servies/firebase_servies.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Firebasebuyer buyerservies = Firebasebuyer();
  Operations _operations = Operations();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: buyerservies.fetchbuyerProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No products available.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final products = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two products per row
                childAspectRatio: 2 / 3, // Adjust for image + text layout
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final name = product['name'] ?? 'No Name';
                final cost = product['Cost'] ?? 0.0;
                final imageUrl =
                    (product['images'] as List<dynamic>?)?.first ?? '';
                final offercosts = product["Offers_cost"];

                if (snapshot.hasData) {
                  for (var doc in snapshot.data!.docs) {
                    // print(doc.data()); // Print each product's data
                    final productexpire = doc["Expire date"];
                    int number = int.parse(cost);
                    if (_operations.isTomorrow(productexpire)) {
                      final offercost = number * (1 - (20 / 100));
                      print(
                          "Expire date product: $productexpire\nOffer cost:$offercost");
                      FirebaseFirestore.instance
                          .collection("products")
                          .doc(doc.id)
                          .update({
                        "flase_sale": true,
                        "Offers_cost": "$offercost"
                      });
                    } else {}
                  }
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductInfo(
                          productId: product.id,
                          cost: offercosts,
                        ), // Pass productId
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Image
                        Expanded(
                          child: imageUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                )
                              : Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Text('No Image'),
                                  ),
                                ),
                        ),

                        // Product Name and Cost
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${cost.toString()}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
