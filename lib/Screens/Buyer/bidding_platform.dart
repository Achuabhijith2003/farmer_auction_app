import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmer_auction_app/Servies/firebase_servies.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BiddingPlatform extends StatefulWidget {
  final dynamic docID;

  const BiddingPlatform({super.key, required this.docID});

  @override
  State<BiddingPlatform> createState() => _BiddingPlatformState();
}

class _BiddingPlatformState extends State<BiddingPlatform> {
  Firebasebuyer buyyerservies = Firebasebuyer();
  final TextEditingController bidController = TextEditingController();

  void placeBid(String auctionId, double currentPrice) async {
    double bidAmount = double.tryParse(bidController.text) ?? 0.0;

    if (bidAmount <= currentPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Bid must be higher than the current price.')),
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
        body: StreamBuilder<DocumentSnapshot>(
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

            return Card(
              margin: const EdgeInsets.all(8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Starting Price: \$${startingPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Current Price: \$${currentPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      'End Time: ${endTime.toLocal()}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Place Bid'),
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }
}
