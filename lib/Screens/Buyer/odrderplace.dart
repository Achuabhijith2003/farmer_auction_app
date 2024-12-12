import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmer_auction_app/Servies/firebase_servies.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class Odrderplace extends StatefulWidget {
  const Odrderplace({super.key});

  @override
  State<Odrderplace> createState() => _OdrderplaceState();
}

class _OdrderplaceState extends State<Odrderplace> {
  String? selectedPaymentMethod;
  String userLocation = "Location not selected";
  bool isLoadingLocation = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
        final Placemark place = placemarks.first;
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

  // Confirm order logic
  void confirmOrder() {
    if (userLocation == "Location not selected") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your location.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Order placed successfully! Location: $userLocation, Payment: $selectedPaymentMethod'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Your Order'),
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
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore
                  .collection('cart')
                  .where("UserID", isEqualTo: buyerservices.getuserID())
                  .snapshots(),
              builder: (context, cartSnapshot) {
                if (cartSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!cartSnapshot.hasData || cartSnapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Your cart is empty.',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                final cartItems = cartSnapshot.data!.docs;

                return Column(
                  children: [
                    // Display each item in the cart
                    ...cartItems.map((item) {
                      final productDocId = item['DocID'];

                      return StreamBuilder<
                          DocumentSnapshot<Map<String, dynamic>>>(
                        stream:
                            buyerservices.fetchbuyerincartproduct(productDocId),
                        builder: (context, productSnapshot) {
                          if (productSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (!productSnapshot.hasData ||
                              !productSnapshot.data!.exists) {
                            return const SizedBox
                                .shrink(); // Skip if product data is missing
                          }

                          final productData = productSnapshot.data!.data()!;
                          final productName = productData['name'] ?? 'No Name';
                          final productCost = double.tryParse(
                                  productData['Cost']?.toString() ?? '0') ??
                              0.0;

                          return ListTile(
                            title: Text(productName),
                            trailing: Text(
                              '₹$productCost',
                              style: const TextStyle(color: Colors.green),
                            ),
                          );
                        },
                      );
                    }).toList(),
                    // Calculate and display the total amount
                    FutureBuilder<double>(
                      future: Future<double>(() async {
                        double total = 0.0;
                        for (var item in cartItems) {
                          final productDoc = await _firestore
                              .collection('products')
                              .doc(item['DocID'])
                              .get();

                          if (productDoc.exists) {
                            final productData = productDoc.data();
                            total += double.tryParse(
                                    productData?['Cost']?.toString() ?? '0') ??
                                0.0;
                          }
                        }
                        return total;
                      }),
                      builder: (context, totalSnapshot) {
                        if (totalSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final totalAmount = totalSnapshot.data ?? 0.0;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '₹$totalAmount',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: confirmOrder,
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
}
