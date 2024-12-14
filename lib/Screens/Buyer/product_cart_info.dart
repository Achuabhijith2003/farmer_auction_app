import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:farmer_auction_app/Servies/firebase_servies.dart';

class ProductCartInfo extends StatefulWidget {
    final String productId;
 
  const ProductCartInfo({super.key, required this.productId});

  @override
  State<ProductCartInfo> createState() => _ProductCartInfoState();
}

class _ProductCartInfoState extends State<ProductCartInfo> {
 final Firebasebuyer buyerServices = Firebasebuyer();
  final TextEditingController productqantiycontroller = TextEditingController();

   Future<void> removeFromCart(String cartItemId) async {
    try {
      print('Attempting to remove cart item: $cartItemId'); // Debug log
      await FirebaseFirestore.instance.collection('cart').doc(cartItemId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item removed from cart!'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print('Error removing item from cart: $e'); // Debug log
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to remove item from cart.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
        'ProductInfo page loaded for productId: ${widget.productId}'); // Debug log

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: buyerServices.fetchbuyersingleProducts(widget.productId),
        builder: (context, snapshot) {
          print(
              'StreamBuilder state: ${snapshot.connectionState}'); // Debug log

          if (snapshot.connectionState == ConnectionState.waiting) {
            print('Fetching product data...'); // Debug log
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            print(
                'Product not found for productId: ${widget.productId}'); // Debug log
            return const Center(
              child: Text(
                'Product not found.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final product = snapshot.data!.data();
          print('Fetched product data: $product'); // Debug log

          final name = product?['name'] ?? 'No Name';
          final cost = product?['Cost'] ?? 0.0;
          final description =
              product?['description'] ?? 'No description available.';
          
          final images = (product?['images'] as List<dynamic>?) ?? [];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Images Carousel
                images.isNotEmpty
                    ? SizedBox(
                        height: 250,
                        child: PageView.builder(
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            final imageUrl = images[index];
                            return Image.network(
                              imageUrl,
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      )
                    : Container(
                        height: 250,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Text('No Images'),
                        ),
                      ),
                const SizedBox(height: 16),

                // Product Name and Cost
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '\$$cost',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Description:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    description,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Quality:")
                ),
                const SizedBox(height: 16),

                // Add to Cart Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        print(
                            'Add to Cart button pressed for productId: ${widget.productId}'); // Debug log
                        removeFromCart(widget.productId);
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('remove from Cart'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
