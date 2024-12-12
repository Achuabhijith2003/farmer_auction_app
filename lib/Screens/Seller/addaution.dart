import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmer_auction_app/Servies/firebase_servies.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddAuction extends StatefulWidget {
  const AddAuction({super.key});

  @override
  State<AddAuction> createState() => _AddAuctionState();
}

class _AddAuctionState extends State<AddAuction> {
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController startingPriceController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final List<File> selectedImages = [];
  final picker = ImagePicker();
  Firebaseseller sellerbase = Firebaseseller();

  Future<void> pickImage() async {
    if (selectedImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only upload up to 3 images.')),
      );
      return;
    }
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImages.add(File(pickedFile.path));
      });
    }
  }

  Future<List<String>> uploadImages(String docId) async {
    List<String> imageUrls = [];
    for (var i = 0; i < selectedImages.length; i++) {
      final file = selectedImages[i];
      final ref = FirebaseStorage.instance
          .ref()
          .child('auctions/$docId/image_$i.jpg');
      await ref.putFile(file);
      final imageUrl = await ref.getDownloadURL();
      imageUrls.add(imageUrl);
    }
    return imageUrls;
  }

  void createAuction() async {
    String productName = productNameController.text.trim();
    double startingPrice = double.tryParse(startingPriceController.text) ?? 0.0;
    DateTime endTime =
        DateTime.tryParse(endTimeController.text) ?? DateTime.now();

    if (productName.isEmpty ||
        startingPrice <= 0 ||
        endTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly.')),
      );
      return;
    }

    if (selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload at least one image.')),
      );
      return;
    }

    try {
      final ref = await FirebaseFirestore.instance.collection('auctions').add({
        'productName': productName,
        'startingPrice': startingPrice,
        'currentPrice': startingPrice,
        'Highest bidder uid':"",
        'endTime': endTime,
        'sellerId': sellerbase.getuserID(), // Replace with actual seller ID
        'createdAt': DateTime.now(),
        'status': "ongoing"
      });

      final docId = ref.id;

      // Upload images
      final imageUrls = await uploadImages(docId);

      // Update Firestore with image URLs
      await FirebaseFirestore.instance.collection('auctions').doc(docId).update({
        'docID': docId,
        'images': imageUrls,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Auction created successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create auction: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 36, left: 5, right: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 10),
                  Text(
                    "Add Auction",
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
                topRight: Radius.circular(40),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: productNameController,
                      decoration:
                          const InputDecoration(labelText: 'Product Name'),
                    ),
                    TextField(
                      controller: startingPriceController,
                      decoration:
                          const InputDecoration(labelText: 'Starting Price'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: endTimeController,
                      decoration: const InputDecoration(
                          labelText: 'End Time (yyyy-MM-dd HH:mm:ss)'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: pickImage,
                      child: const Text('Upload Images'),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: selectedImages
                          .map((image) => Image.file(
                                image,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: createAuction,
                      child: const Text('Create Auction'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
