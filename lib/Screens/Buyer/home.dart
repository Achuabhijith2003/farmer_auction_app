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
  String searchName = "";

  @override
  void initState() {
    super.initState();
    _updateExpiredProducts();
  }

  void _updateExpiredProducts() async {
    final snapshot = await buyerservies.fetchbuyerProducts().first;
    for (var doc in snapshot.docs) {
      final Timestamp productExpire = doc["Expire date"];
      final cost = doc["Cost"] ?? 0.0;
      int number = int.parse(cost);

      if (_operations.isTomorrow(productExpire)) {
        final offerCost = number * 0.8; // 20% discount
        await FirebaseFirestore.instance
            .collection("products")
            .doc(doc.id)
            .update({"flase_sale": true, "Offers_cost": offerCost});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search...',
                prefixIcon: Icon(
                  Icons.search_outlined,
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  searchName = val.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: buyerservies.fetchbuyerProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No products available.',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                final products = snapshot.data!.docs.where((product) {
                  final name = product['name']?.toString().toLowerCase() ?? '';
                  return name.contains(searchName);
                }).toList();

                if (products.isEmpty) {
                  return const Center(
                    child: Text(
                      'This product is not available.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2 / 3,
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
                      final offerCost = product["Offers_cost"] ?? cost;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductInfo(
                                productId: product.id,
                                cost: "$offerCost",
                              ),
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
                                      '\$$cost',
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
          ),
        ],
      ),
    );
  }
}
