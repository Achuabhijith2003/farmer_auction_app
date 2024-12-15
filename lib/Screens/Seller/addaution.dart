import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmer_auction_app/Servies/firebase_servies.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:firebase_storage/firebase_storage.dart';

class AddAuction extends StatefulWidget {
  const AddAuction({super.key});

  @override
  State<AddAuction> createState() => _AddAuctionState();
}

class _AddAuctionState extends State<AddAuction> {
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController startingPriceController = TextEditingController();

  late DateTime dateTime = DateTime.now();
  final List<File> selectedImages = [];
  final Imagepicker = ImagePicker();
  Firebaseseller sellerbase = Firebaseseller();

  Future<void> pickImage() async {
    if (selectedImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only upload up to 3 images.')),
      );
      return;
    }
    final pickedFile = await Imagepicker.pickImage(source: ImageSource.gallery);
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
      final ref =
          FirebaseStorage.instance.ref().child('auctions/$docId/image_$i.jpg');
      await ref.putFile(file);
      final imageUrl = await ref.getDownloadURL();
      imageUrls.add(imageUrl);
    }
    return imageUrls;
  }

  void createAuction() async {
    String productName = productNameController.text.trim();
    double startingPrice = double.tryParse(startingPriceController.text) ?? 0.0;
    DateTime endTime = dateTime;
    // DateTime.tryParse(dates) ?? DateTime.now();

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
        'Highest bidder uid': "",
        'endTime': endTime,
        'sellerId': sellerbase.getuserID(), // Replace with actual seller ID
        'createdAt': DateTime.now(),
        'status': "ongoing"
      });

      final docId = ref.id;

      // Upload images
      final imageUrls = await uploadImages(docId);

      // Update Firestore with image URLs
      await FirebaseFirestore.instance
          .collection('auctions')
          .doc(docId)
          .update({
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
      appBar: AppBar(
        title: Text(
          "Create Auctions",
          style: GoogleFonts.aBeeZee(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 27),
        ),
        backgroundColor: Colors.red[600],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: productNameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: startingPriceController,
                decoration: const InputDecoration(labelText: 'Starting Price'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),
              Text("Expire date and time: $dateTime"),
              const SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(12)),
                child: TextButton(
                    onPressed: () {
                      picker.DatePicker.showDateTimePicker(context,
                          showTitleActions: true,
                          minTime: DateTime(2024, 5, 5, 20, 50),
                          maxTime: DateTime(2030, 6, 7, 05, 09),
                          onChanged: (date) {
                        print('change $date in time zone ' +
                            date.timeZoneOffset.inHours.toString());
                      }, onConfirm: (date) {
                        print('confirm $date');
                        setState(() {
                          dateTime = date;
                        });
                      }, currentTime: DateTime(2024, 12, 31, 23, 12, 34));
                    },
                    child: Text("Select Expire Date and Time",
                        style: GoogleFonts.aBeeZee(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18))),
              ),
              const SizedBox(height: 20),
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
                      onPressed: pickImage,
                      child: Text("Add Images",
                          style: GoogleFonts.aBeeZee(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                    ),
                  ),
                ),
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
                      onPressed: createAuction,
                      child: Text("Create Auctions",
                          style: GoogleFonts.aBeeZee(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
