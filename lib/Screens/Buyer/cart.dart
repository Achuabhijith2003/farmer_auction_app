import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmer_auction_app/Screens/Buyer/odrderplace.dart';
import 'package:farmer_auction_app/Servies/firebase_servies.dart';
import 'package:flutter/material.dart';
import 'package:farmer_auction_app/Screens/Buyer/product_info.dart';
import 'package:google_fonts/google_fonts.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Firebasebuyer buyerservices = Firebasebuyer();

  Future<void> removeFromCart(String cartItemId) async {
    try {
      print('Attempting to remove cart item: $cartItemId'); // Debug log
      await _firestore.collection('cart').doc(cartItemId).delete();
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
    print('Cart page loaded.'); // Debug log
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart',
            style: GoogleFonts.aBeeZee(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 27)),
        backgroundColor: Colors.green[700],
      ),
      body: Column(
        children: [
          Flexible(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore.collection('cart').snapshots(),
              builder: (context, cartSnapshot) {
                if (cartSnapshot.connectionState == ConnectionState.waiting) {
                  print('Fetching cart items...'); // Debug log
                  return const Center(child: CircularProgressIndicator());
                }

                if (!cartSnapshot.hasData || cartSnapshot.data!.docs.isEmpty) {
                  print('No items found in cart.'); // Debug log
                  return const Center(
                    child: Text(
                      'Your cart is empty.',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                final cartItems = cartSnapshot.data!.docs;
                print('Cart items fetched: ${cartItems.length}'); // Debug log

                return ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartItems[index].data();
                    final cartItemId = cartItems[index].id;
                    final cartProductId = cartItem['DocID'];
                    final cartcost = cartItem["Product_cost"];

                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream:
                          buyerservices.fetchbuyercartproduct(cartProductId),
                      builder: (context, productSnapshot) {
                        if (productSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (!productSnapshot.hasData ||
                            productSnapshot.data!.docs.isEmpty) {
                          print(
                              'No product found for cart item: $cartProductId'); // Debug log
                          return const SizedBox
                              .shrink(); // Skip if no product data
                        }

                        final productDoc = productSnapshot.data!.docs.first;
                        final product = productDoc.data();
                        final productName = product['name'] ?? 'No Name';
                        final productCost = cartcost ?? 0.0;
                        final productImages =
                            (product['images'] as List<dynamic>?) ?? [];
                        final productImage =
                            productImages.isNotEmpty ? productImages.first : '';

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          child: ListTile(
                            leading: productImage.isNotEmpty
                                ? Image.network(
                                    productImage,
                                    fit: BoxFit.cover,
                                    width: 50,
                                    height: 50,
                                  )
                                : Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[300],
                                    child:
                                        const Center(child: Text('No Image')),
                                  ),
                            title: Text(
                              productName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('₹$productCost'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                print(
                                    'Removing product from cart: $cartItemId'); // Debug log
                                removeFromCart(cartItemId);
                              },
                            ),
                            onTap: () {
                              print(
                                  'Navigating to ProductInfo for: $cartProductId'); // Debug log
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => ProductInfo(
                              //       productId: cartProductId,
                              //       cost: productCost,
                              //       orginalcost: "",
                              //     ),
                              //   ),
                              // );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.green[700]),
              width: MediaQuery.of(context).size.width * .9,
              height: 55,
              child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const Odrderplace(), // Pass productId
                      ),
                    );
                  },
                  child: Text("Place Order",
                      style: GoogleFonts.aBeeZee(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18))),
            ),
          ),
        ],
      ),
    );
  }
}
