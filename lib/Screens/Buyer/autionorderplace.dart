import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmer_auction_app/Screens/Buyer/Remasted_home.dart';
import 'package:farmer_auction_app/Servies/firebase_servies.dart';
import 'package:farmer_auction_app/Servies/payment.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class Autionorderplace extends StatefulWidget {
  String autionID;

  Autionorderplace({super.key, required this.autionID});

  @override
  State<Autionorderplace> createState() => _AutionorderplaceState();
}

class _AutionorderplaceState extends State<Autionorderplace> {
  String? selectedPaymentMethod;
  String userLocation = "Location not selected";
  bool isLoadingLocation = false;
  late final Placemark place ;

  double finalamount = 0.0;
  String productid = "";
  String productName = "";
  double productCost = 0.0;

  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Firebasebuyer buyerservices = Firebasebuyer();

  // Get the current location and convert to a human-readable address
  Future<void> getCurrentLocation() async {
    setState(() {
      isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'Location permissions are permanently denied. Enable them in settings.');
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
         place = placemarks.first;
        setState(() {
          userLocation =
              "${place.locality}, ${place.administrativeArea}, ${place.country}";
        });
      } else {
        setState(() {
          userLocation = "Unable to determine location name.";
        });
      }
    } catch (e) {
      print('Error fetching location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Your Aution Order'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: isLoadingLocation ? null : getCurrentLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: isLoadingLocation
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Get Location'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    userLocation,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RadioListTile<String>(
              title: const Text('Cash on Delivery'),
              value: 'Cash on Delivery',
              groupValue: selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('UPI Payment'),
              value: 'UPI Payment',
              groupValue: selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Cart Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            StreamBuilder<DocumentSnapshot>(
              stream: buyerservices.fetchautiondetails(widget.autionID),
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
                finalamount = currentPrice;

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
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (confirmOrder()) {
                    if (selectedPaymentMethod == "UPI Payment") {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Order Details',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text('Location: $userLocation'),
                                Text('Payment Method: $selectedPaymentMethod '),
                                Text("Total Amount: $finalamount"),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Payments(
                                            amount: finalamount,
                                          ),
                                        ));
                                  },
                                  child: const Text('Pay Now'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    } else {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Order Details',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text('Location: $userLocation'),
                                Text('Payment Method: $selectedPaymentMethod '),
                                Text("Total Amount: $finalamount"),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () async {
                                    bool isoderedcom =
                                        await buyerservices.addorderedproduct(
                                            productid,
                                            productName,
                                            "$productCost",
                                            "${place.locality}, ${place.administrativeArea}, ${place.country}",selectedPaymentMethod!);
                                    if (isoderedcom) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Order is conformed'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const RemastedHome()));
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Order is not conformed'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('Order Now'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 24.0),
                ),
                child: const Text(
                  'Confirm Order',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool confirmOrder() {
    if (userLocation == "Location not selected") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your location.'),
          backgroundColor: Colors.red,
        ),
      );
      return false; // Return null explicitly in case of errors
    } else if (selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method.'),
          backgroundColor: Colors.red,
        ),
      );
      return false; // Return null explicitly in case of errors
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       'Order placed successfully! Location: $userLocation, Payment: $selectedPaymentMethod',
      //     ),
      //     backgroundColor: Colors.green,
      //   ),
      // );

      // Return the bottom sheet controller
      return true;
    }
  }
}
