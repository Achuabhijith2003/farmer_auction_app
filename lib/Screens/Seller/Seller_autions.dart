import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmer_auction_app/Screens/Seller/addaution.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SellerAutions extends StatefulWidget {
  const SellerAutions({super.key});

  @override
  State<SellerAutions> createState() => _SellerAutionsState();
}

class _SellerAutionsState extends State<SellerAutions> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 36, left: 5, right: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 10),
                    Text(
                      "Autions",
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
              ),
              child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Addaution()),
                );
              },
              child: const Text("Create New Auction"),
            ),
            const SizedBox(height: 10),
            const Text(
              "Ongoing Auctions:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('auctions')
                    .where('sellerId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
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
                    return const Center(
                      child: Text("You have no ongoing auctions."),
                    );
                  }
                  return ListView.builder(
                    itemCount: auctions.length,
                    itemBuilder: (context, index) {
                      final auction = auctions[index];
                      return Card(
                        child: ListTile(
                          // leading: Image.network(
                          //   auction['imageUrl'],
                          //   width: 60,
                          //   height: 60,
                          //   fit: BoxFit.cover,
                          // ),
                          title: Text(auction['productName']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Current Highest: ₹${auction['startingPrice']}"),
                              // Text("Bids: ${auction['totalBids']}"),
                              // Text(
                              //     "Ends In: ${auction['endtime']} mins"),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              // Delete Auction Logic
                              deleteAuction(context, auction);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        )),
    ))],
    );
  }
  
  void deleteAuction(BuildContext context, QueryDocumentSnapshot<Object?> auction) {}
}