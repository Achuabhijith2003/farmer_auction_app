import 'package:farmer_auction_app/Auth/loginpage.dart';
import 'package:farmer_auction_app/Screens/Seller/seller_remaster_home.dart';
import 'package:farmer_auction_app/Servies/firebase_servies.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BuyerProfile extends StatefulWidget {
  const BuyerProfile({super.key});

  @override
  State<BuyerProfile> createState() => BuyerProfileState();
}

class BuyerProfileState extends State<BuyerProfile> {
  FirebaseauthServies auth = FirebaseauthServies();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile',
            style: GoogleFonts.aBeeZee(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 27)),
        backgroundColor: Colors.green[700],
      ),
      body: Stack(children: [
        FutureBuilder(
          future: auth.fetch_user_profile(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: Text('Error: ${snapshot.error}')),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.grey,
                ),
              ); // Show loading indicator
            }
            final data = snapshot.data as List<Map<String, dynamic>>;
            final profileData = data[0];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 35),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.grey,
                            maxRadius: 35,
                            backgroundImage: AssetImage("assets/ai logo.jpeg"),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15, left: 25),
                            child: Column(
                              children: [
                                Text(
                                  profileData["Name"],
                                  style: GoogleFonts.aBeeZee(
                                    color: Colors.black,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(profileData["Email"]),
                                Text(profileData["Address"]),
                                Text(profileData["Pincode"]),
                                Text(profileData["Phone no"])
                              ],
                            ),
                          ),
                          // Column(
                          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                          //   children: [

                          //   ],
                          // ),
                        ],
                      ),
                      const VerticalDivider(
                        color: Colors.grey,
                        thickness: 3,
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(
                          left: 50, right: 50, top: 15, bottom: 10),
                      child: Divider(
                        color: Colors.grey,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: ListTile(
                        title: Text(
                          "Swith to Seller",
                          style: GoogleFonts.aBeeZee(color: Colors.green[900]),
                        ),
                        trailing: const Icon(
                          Icons.switch_account_rounded,
                          color: Colors.white,
                        ),
                        onTap: () async {
                          Navigator.pushReplacement(
                              // ignore: use_build_context_synchronously
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SellerRemasterHome(),
                              ));
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: ListTile(
                        title: Text(
                          "Logout",
                          style: GoogleFonts.aBeeZee(color: Colors.green[900]),
                        ),
                        trailing: const Icon(
                          Icons.logout_outlined,
                          color: Colors.white,
                        ),
                        onTap: () async {
                          if (await auth.logout()) {
                            Navigator.pushReplacement(
                                // ignore: use_build_context_synchronously
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Loginpage(),
                                ));
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ]),
    );
  }
}
