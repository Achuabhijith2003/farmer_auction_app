import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmer_auction_app/Servies/firebase_servies.dart';
import 'package:flutter/material.dart';
// import 'package:farmer_auction_app/Servies/firebase_servies.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductInfo extends StatefulWidget {
  final String productId;
  final String cost;
  final String orginalcost;
  const ProductInfo(
      {super.key,
      required this.productId,
      required this.cost,
      required this.orginalcost});

  @override
  State<ProductInfo> createState() => _ProductInfoState();
}

class _ProductInfoState extends State<ProductInfo> {
  final Firebasebuyer buyerServices = Firebasebuyer();
  final TextEditingController _feedbackController = TextEditingController();

  void addToCart(String productId, String sellerid, String name) async {
    print('Adding product to cart: $productId'); // Debug log
    bool isoffer = true;
    if (widget.cost == "") {
      isoffer = false;
    }

    // Implementation for adding the product to the cart
    final iscarted = await buyerServices.addtocarts(widget.productId,
        widget.cost, widget.orginalcost, isoffer, sellerid, name);
    if (iscarted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added to cart!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product  added to cart is failed!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void submitFeedback() async {
    final feedback = _feedbackController.text.trim();
    if (feedback.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feedback cannot be empty!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('ProductFeedback').add({
        'productId': widget.productId,
        'feedback': feedback,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _feedbackController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your feedback!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error submitting feedback: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit feedback: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('ProductInfo page loaded for productId: ${widget.productId}');

    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details',
            style: GoogleFonts.aBeeZee(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 27)),
        backgroundColor: Colors.green[700],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        // stream: buyerServices.fetchbuyersingleProducts(widget.productId),
        stream: FirebaseFirestore.instance
            .collection(
                'products') // Replace 'products' with your actual collection name
            .doc(widget.productId)
            .snapshots(),
        builder: (context, snapshot) {
          print('StreamBuilder state: ${snapshot.connectionState}');

          if (snapshot.connectionState == ConnectionState.waiting) {
            print('Fetching product data...');
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            print('Product not found for productId: ${widget.productId}');
            return const Center(
              child: Text(
                'Product not found.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final product = snapshot.data!.data();
          print('Fetched product data: $product');

          final name = product?['name'] ?? 'No Name';
          // final cost = product?['Cost'] ?? 0.0;
          final description =
              product?['description'] ?? 'No description available.';
          final images = (product?['images'] as List<dynamic>?) ?? [];
          final sellerid = product?['UID'];

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
                  child: (widget.cost == "")
                      ? Text(
                          '₹${widget.orginalcost}',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.green,
                          ),
                        )
                      : Text(
                          '₹${widget.cost}',
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
                const SizedBox(height: 16),
                // Add to Cart Button
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.green[700]),
                      width: MediaQuery.of(context).size.width * .9,
                      height: 55,
                      child: TextButton(
                          onPressed: () {
                            addToCart(widget.productId, sellerid, name);
                          },
                          child: Text("Add to Cart",
                              style: GoogleFonts.aBeeZee(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18))),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Feedback Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Feedback:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _feedbackController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Write your feedback here...',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.green[700]),
                            width: MediaQuery.of(context).size.width * .9,
                            height: 55,
                            child: TextButton(
                                onPressed: submitFeedback,
                                child: Text("Submit Feedback",
                                    style: GoogleFonts.aBeeZee(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18))),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'All Feedback:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('ProductFeedback')
                            .where('productId', isEqualTo: widget.productId)
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder: (context, feedbackSnapshot) {
                          if (feedbackSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(), 
                            );
                          }

                          if (feedbackSnapshot.hasError) {
                            print(
                                'Error fetching feedback: ${feedbackSnapshot.error}');
                            return Center(
                              child: Text(
                                  'An error occurred while fetching feedback: ${feedbackSnapshot.error}'),
                            );
                          }

                          if (!feedbackSnapshot.hasData ||
                              feedbackSnapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text('No feedback available.'),
                            );
                          }

                          final feedbackDocs = feedbackSnapshot.data!.docs;

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: feedbackDocs.length,
                            itemBuilder: (context, index) {
                              final feedbackData = feedbackDocs[index].data();
                              final feedbackText = feedbackData['feedback'] ??
                                  'No feedback text';
                              final timestamp =
                                  feedbackData['timestamp'] as Timestamp?;
                              final dateTime = timestamp?.toDate();
                              final formattedDate = dateTime != null
                                  ? '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}'
                                  : 'Unknown date';

                              print(
                                  'Feedback $index: $feedbackText (Date: $formattedDate)');

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                elevation: 2,
                                child: ListTile(
                                  title: Text(
                                    feedbackText,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  subtitle: Text(
                                    formattedDate,
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
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
