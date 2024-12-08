import 'dart:io';

import 'package:farmer_auction_app/Screens/Componets/components.dart';
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
  final List<File> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();

  // Function to pick an image
  Future<void> _pickImage() async {
    if (_selectedImages.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only select up to 4 images.')),
      );
      return;
    }

    final XFile? pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  // Function to remove an image
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
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
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: _selectedImages
                                .asMap()
                                .entries
                                .map((entry) => Stack(
                                      children: [
                                        Image.file(
                                          entry.value,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: IconButton(
                                            onPressed: () =>
                                                _removeImage(entry.key),
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 10),
                          // Add Image Button
                          MaterialButton(
                            onPressed: _pickImage,
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
                            onPressed: () {
                              // Ensure at least 2 images are selected
                              if (_selectedImages.length < 2) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Please select at least 2 images for the product.')),
                                );
                                return;
                              }

                              // Handle form submission
                              print(
                                  "Product Name: ${productnamecontroller.text}");
                              print(
                                  "Description: ${productdescriptioncontroller.text}");
                              print("Images Count: ${_selectedImages.length}");
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
