import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmer_auction_app/Servies/firebase_servies.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BiddingPlatform extends StatefulWidget {
  final String docID;

  const BiddingPlatform({super.key, required this.docID});

  @override
  State<BiddingPlatform> createState() => _BiddingPlatformState();
}

class _BiddingPlatformState extends State<BiddingPlatform> {
  Firebasebuyer buyyerservies = Firebasebuyer();
  final TextEditingController bidController = TextEditingController();
  double highestBidAmount = 0.0;

  void placeBid(String auctionId, double currentPrice) async {
    double bidAmount = double.tryParse(bidController.text) ?? 0.0;

    if (bidAmount <= currentPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bid must be higher than the current price.'),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('auctions')
          .doc(auctionId)
          .update({
        'currentPrice': bidAmount,
      });

      await FirebaseFirestore.instance
          .collection('auctions')
          .doc(auctionId)
          .collection('bids')
          .add({
        'bid': bidAmount,
        'UID': buyyerservies.getuserID(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bid placed successfully!')),
      );
      bidController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place bid: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Bidding Platform',
          style: GoogleFonts.dmSerifDisplay(fontSize: 24),
        ),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Auction details
          StreamBuilder<DocumentSnapshot>(
            stream: buyyerservies.fetchautiondetails(widget.docID),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(
                  child: Text(
                    'Auction not found.',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                );
              }

              final auction = snapshot.data!;
              final productName = auction['productName'];
              final currentPrice = auction['currentPrice'];
              final startingPrice = auction['startingPrice'];
              final endTime = (auction['endTime'] as Timestamp).toDate();
              final imageUrls = List<String>.from(auction['images'] ?? []);

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display the product image
                      if (imageUrls.isNotEmpty)
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: imageUrls.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.network(
                                  imageUrls[index],
                                  fit: BoxFit.cover,
                                  height: 200,
                                  width: 200,
                                ),
                              );
                            },
                          ),
                        )
                      else
                        const Text('No images available'),
                      const SizedBox(height: 10),
                      Text(
                        productName,
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                          'Starting Price: \$${startingPrice.toStringAsFixed(2)}'),
                      Text(
                          'Current Price: \$${currentPrice.toStringAsFixed(2)}'),
                      Text('End Time: ${endTime.toLocal()}'),
                      const SizedBox(height: 10),
                      TextField(
                        controller: bidController,
                        decoration: const InputDecoration(
                          labelText: 'Enter your bid',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => placeBid(widget.docID, currentPrice),
                        child: const Text('Place Bid'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Highest bid
          StreamBuilder<QuerySnapshot>(
            stream: buyyerservies.fetchHighestBid(widget.docID),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No bids available.',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                );
              }

              final highestBidDoc = snapshot.data!.docs.first;
              final uid = highestBidDoc['UID'];
              final bidAmount = highestBidDoc['bid'];

              return FutureBuilder<Map<String, dynamic>?>(
                future: buyyerservies.fetchUserDetails(uid),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!userSnapshot.hasData || userSnapshot.data == null) {
                    return const Center(
                      child: Text(
                        'User details not found.',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    );
                  }

                  final user = userSnapshot.data!;
                  final name = user['Name'] ?? 'N/A';

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    shape: Border.all(color: Colors.greenAccent),
                    child: ListTile(
                      title: Text('Highest Bidder: $name'),
                      subtitle: Text('Bid Amount: \$${bidAmount.toStringAsFixed(2)}'),
                    ),
                  );
                },
              );
            },
          ),

          // All bids
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: buyyerservies.fetchbids(widget.docID),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No bids found.',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  );
                }

                final bids = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: bids.length,
                  itemBuilder: (context, index) {
                    final bid = bids[index];
                    final uid = bid['UID'];
                    final bidAmount = bid['bid'];

                    return FutureBuilder<Map<String, dynamic>?>(
                      future: buyyerservies.fetchUserDetails(uid),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (!userSnapshot.hasData ||
                            userSnapshot.data == null) {
                          return const Center(
                            child: Text(
                              'User details not found.',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                            ),
                          );
                        }

                        final user = userSnapshot.data!;
                        final name = user['Name'] ?? 'N/A';

                        return Card(
                          child: ListTile(
                            title: Text('Bidder: $name'),
                            subtitle:
                                Text('Bid Amount: \$${bidAmount.toString()}'),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
