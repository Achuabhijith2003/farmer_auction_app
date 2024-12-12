import 'dart:io';

import 'package:farmer_auction_app/Screens/Componets/components.dart';
import 'package:farmer_auction_app/Servies/firebase_servies.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class Addproducts extends StatefulWidget {
  const Addproducts({super.key});

  @override
  State<Addproducts> createState() => AddproductsState();
}

class AddproductsState extends State<Addproducts> {
  final TextEditingController productnamecontroller = TextEditingController();
  final TextEditingController productdescriptioncontroller =
      TextEditingController();
  final TextEditingController productcostcontroller = TextEditingController();
  List<XFile> _images = [];
  final ImagePicker _imagePicker = ImagePicker();

  Firebaseseller fbseller = Firebaseseller();

  // Function to pick an image

  void _pickImages() async {
    final List<XFile> selectedImages = await _imagePicker.pickMultiImage();
    // ignore: unnecessary_null_comparison
    if (selectedImages != null) {
      if (selectedImages.length > 4) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("You can only select up to 4 images."),
        ));
      } else {
        setState(() {
          _images = selectedImages;
        });
      }
    }
  }

  // Function to remove an image
  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Stack(
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
                      "Add Products",
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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: buildTextField("Name of the Product",
                          productnamecontroller, TextInputType.name),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: buildTextField("Description of the Product",
                          productdescriptioncontroller, TextInputType.text),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: buildTextField("cost of the Product",
                          productcostcontroller, TextInputType.number),
                    ),
                    const SizedBox(height: 10),

                    // Image Picker Section
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Add Product Images (Min: 2, Max: 4)",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          // Display selected images
                          Wrap(
                            children: _images.map((image) {
                              return Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Stack(
                                  children: [
                                    // The image
                                    Image.file(
                                      File(image.path),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                    // The delete button
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _images.remove(
                                                image); // Remove the selected image
                                          });
                                        },
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 10),
                          // Add Image Button
                          MaterialButton(
                            onPressed: _pickImages,
                            height: 50,
                            color: Colors.grey[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Center(
                              child: Text(
                                "Add Image",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          MaterialButton(
                            onPressed: () async {
                              // Ensure at least 2 images are selected
                              if (_images.length < 2) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Please select at least 2 images for the product.')),
                                );
                              } else {
                                      const Center(
                          child: CircularProgressIndicator(
                            color: Colors.grey,
                          ),
                        ); 
                                String productName =
                                    productnamecontroller.text.trim();
                                String ProductDIscrption =
                                    productdescriptioncontroller.text.trim();
                                String ProductCost =
                                    productcostcontroller.text.trim();
                                final issucess = fbseller.addproducts(
                                    productName,
                                    ProductDIscrption,
                                    ProductCost,
                                    _images);
                                if (await issucess) {
                                  setState(() {
                                    _images = [];
                                    productcostcontroller.clear();
                                    productdescriptioncontroller.clear();
                                    productnamecontroller.clear();
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Uploaded sucesssfully')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Uploaded falied')),
                                  );
                                }
                              }

                              // Handle form submission
                              print(
                                  "Product Name: ${productnamecontroller.text}");
                              print(
                                  "Description: ${productdescriptioncontroller.text}");
                              print("Images Count: ${_images.length}");
                            },
                            height: 50,
                            color: Colors.grey[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Center(
                              child: Text(
                                "Submit Product",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
