import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmer_auction_app/Screens/Buyer/bidding_platform.dart';
import 'package:farmer_auction_app/Servies/firebase_servies.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Aution extends StatefulWidget {
  const Aution({super.key});

  @override
  State<Aution> createState() => _AutionState();
}

class _AutionState extends State<Aution> {
  Operations operations = Operations();
  Firebasebuyer buyyersevies = Firebasebuyer();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auctions',
            style: GoogleFonts.aBeeZee(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 27)),
        backgroundColor: Colors.green[700],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ongoing Auctions',
                    style: GoogleFonts.aBeeZee(
                        color: Colors.green[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 27)),
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
                        return Center(
                          child: Text('No Ongoing Auctions',
                              style: GoogleFonts.aBeeZee(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 17)),
                        );
                      }
                      return ListView.builder(
                        itemCount: auctions.length,
                        itemBuilder: (context, index) {
                          final auction = auctions[index];
                          final checktimedate =
                              operations.checkDateandTime(auction["endTime"]);
                          for (var i = 0; i < auctions.length; i++) {
                            final auction = auctions[index];
                            if (checktimedate) {
                              buyyersevies.modifystatusAution(auction["docID"]);
                              print(
                                  "end Time :${auction["endTime"]}:$checktimedate");
                            }
                          }

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
                                  Text(
                                      "Current Highest: ₹${auction['currentPrice']}"),
                                  // Text("Bids: ${auction['totalBids']}"),
                                  // Text(
                                  //     "Ends In: ${auction['endtime']} mins"),
                                ],
                              ),
                              trailing: Text("${auction["status"]}"),
                              onTap: () => Navigator.push(
                                  // ignore: use_build_context_synchronously
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BiddingPlatform(
                                      docID: auction["docID"],
                                    ),
                                  )),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                // Ended aution
                Text('Closed Auctions',
                    style: GoogleFonts.aBeeZee(
                        color: Colors.green[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 27)),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('auctions')
                        .where('status', isEqualTo: 'end')
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
                        return Center(
                          child: Text('No Closed Auctions',
                              style: GoogleFonts.aBeeZee(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 17)),
                        );
                      }
                      return ListView.builder(
                        itemCount: auctions.length,
                        itemBuilder: (context, index) {
                          final auction = auctions[index];
                          final checktimedate =
                              operations.checkDateandTime(auction["endTime"]);
                          for (var i = 0; i < auctions.length; i++) {
                            final auction = auctions[index];
                            if (checktimedate) {
                              buyyersevies.modifystatusAution(auction["docID"]);
                              print(
                                  "end Time :${auction["endTime"]}:$checktimedate");
                            }
                          }

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
                                  Text(
                                      "Current Highest: ₹${auction['currentPrice']}"),
                                  // Text("Bids: ${auction['totalBids']}"),
                                  // Text(
                                  //     "Ends In: ${auction['endtime']} mins"),
                                ],
                              ),
                              trailing: Text("${auction["status"]}"),
                              onTap: () => Navigator.push(
                                  // ignore: use_build_context_synchronously
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BiddingPlatform(
                                      docID: auction["docID"],
                                    ),
                                  )),
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
        ],
      ),
    );
  }
}
