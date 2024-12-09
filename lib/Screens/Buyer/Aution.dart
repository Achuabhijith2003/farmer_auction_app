import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Aution extends StatefulWidget {
  const Aution({super.key});

  @override
  State<Aution> createState() => _AutionState();
}

class _AutionState extends State<Aution> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 36, left: 5, right: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 10),
                  Text(
                    "Aution",
                    style: GoogleFonts.dmSerifDisplay(
                        fontSize: 40, letterSpacing: 4),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
            top: 100,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40)),
              ),child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ongoing Auctions:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('auctions')
                    .where('status', isEqualTo: 'ongoing')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  }
                  final auctions = snapshot.data?.docs ?? [];
                  if (auctions.isEmpty) {
                    return const Center(child: Text("No ongoing auctions."));
                  }
                  return ListView.builder(
                    itemCount: auctions.length,
                    itemBuilder: (context, index) {
                      final auction = auctions[index];
                      return Card(
                        child: ListTile(
                          leading: Image.network(
                            auction['imageUrl'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                          title: Text(auction['productName']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Starting Bid: ₹${auction['startingBid']}"),
                              Text("Current Highest: ₹${auction['highestBid']}"),
                              Text(
                                  "Ends In: ${auction['timeRemaining']} mins"),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              // Bid Placement Logic
                              placeBid(context, auction);
                            },
                            child: const Text("Bid"),
                          ),
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
            ))
      ],
    );
  }
    void placeBid(BuildContext context, DocumentSnapshot auction) {
    // Implement bid placement dialog
  }
}
