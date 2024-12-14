import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmer_auction_app/Servies/firebase_servies.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Autiondetials extends StatefulWidget {
  final String docID;

  const Autiondetials({super.key, required this.docID});

  @override
  State<Autiondetials> createState() => _AutiondetialsState();
}

class _AutiondetialsState extends State<Autiondetials> {
  Firebasebuyer buyyerservies = Firebasebuyer();

  double highestBidAmount = 0.0;
  bool isstatus = true;

  void chagestatus(String auctionId, String status, bool statuss) async {
    try {
      await FirebaseFirestore.instance
          .collection('auctions')
          .doc(auctionId)
          .update({"status": status});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('change  successfully!')),
      );
      setState(() {
        isstatus = !statuss;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to change: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Bidding Details',
            style: GoogleFonts.aBeeZee(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 27)),
        backgroundColor: Colors.red[600],
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
              final status = auction["Highest bidder uid"];
              if (status == "end") {
                isstatus = false;
              }

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
                      if (isstatus)
                        ElevatedButton(
                          onPressed: () =>
                              chagestatus(widget.docID, "end", isstatus),
                          child: const Text('change to end'),
                        )
                      else
                        ElevatedButton(
                          onPressed: () =>
                              chagestatus(widget.docID, "ongoing", isstatus),
                          child: const Text('change to ongoing'),
                        )
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
                      subtitle:
                          Text('Bid Amount: \$${bidAmount.toStringAsFixed(2)}'),
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
