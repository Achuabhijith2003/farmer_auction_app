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
    return SafeArea(
      child: Scaffold(
        body: Stack(children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 36, left: 5, right: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Profile",
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
                child: Stack(children: [
                  FutureBuilder(
                    future: auth.fetch_user_profile(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              Center(child: Text('Error: ${snapshot.error}')),
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      maxRadius: 35,
                                      backgroundImage:
                                          AssetImage("assets/ai logo.jpeg"),
                                    ),
                                    Column(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15),
                                          child: Column(
                                            children: [
                                              Text(
                                                profileData["Name"],
                                                style: GoogleFonts.ptSerif(
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
                                      ],
                                    ),
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
                                padding:
                                    const EdgeInsets.only(left: 15, right: 15),
                                child: Card(
                                    color: Colors.grey.shade400,
                                    child: ListTile(
                                      title: const Text(
                                        "Swith to Seller",
                                        style: TextStyle(color: Colors.white),
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
                                    )),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, right: 15),
                                child: Card(
                                    color: Colors.grey.shade400,
                                    child: ListTile(
                                      title: const Text(
                                        "Logout",
                                        style: TextStyle(color: Colors.white),
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
                                                builder: (context) =>
                                                    const Loginpage(),
                                              ));
                                        }
                                      },
                                    )),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ]),
              ))
        ]),
      ),
    );
  }
}
