import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmer_auction_app/Screens/Seller/Autiondetials.dart';
import 'package:farmer_auction_app/Screens/Seller/addaution.dart';
import 'package:farmer_auction_app/Servies/firebase_servies.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SellerAutions extends StatefulWidget {
  const SellerAutions({super.key});

  @override
  State<SellerAutions> createState() => _SellerAutionsState();
}

class _SellerAutionsState extends State<SellerAutions> {
  Firebaseseller sellerservies = Firebaseseller();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auctions',
            style: GoogleFonts.aBeeZee(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 27)),
        backgroundColor: Colors.red[600],
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.red[700]),
                    width: MediaQuery.of(context).size.width * .9,
                    height: 55,
                    child: TextButton(
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AddAuction()),
                          );
                        },
                        child: Text("Create Auctions",
                            style: GoogleFonts.aBeeZee(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18))),
                  ),
                ),
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
                      .where('sellerId',
                          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
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
                            onTap: () => Navigator.push(
                                // ignore: use_build_context_synchronously
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Autiondetials(
                                        docID: auction["docID"]))),
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
                                Text(
                                    "Current Highest: ₹${auction['currentPrice']}"),
                                // Text("Bids: ${auction['totalBids']}"),
                                // Text(
                                //     "Ends In: ${auction['endtime']} mins"),
                              ],
                            ),
                            // trailing: IconButton(
                            //   icon: const Icon(Icons.delete),
                            //   onPressed: () async {
                            //     // Delete Auction Logic
                            //     final deletesucessfully =
                            //         sellerservies.deletesellerAuction(
                            //             auction["docID"]);
                            //     if (await deletesucessfully) {
                            //       ScaffoldMessenger.of(context)
                            //           .showSnackBar(
                            //         const SnackBar(
                            //             content: Text(
                            //                 'Deleted successfully!')),
                            //       );
                            //     } else {
                            //       ScaffoldMessenger.of(context)
                            //           .showSnackBar(
                            //         const SnackBar(
                            //             content:
                            //                 Text('Deleted failed!')),
                            //       );
                            //     }
                            //   },
                            // ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          )),
    );
  }
}
