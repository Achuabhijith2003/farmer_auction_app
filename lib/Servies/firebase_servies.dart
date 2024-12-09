import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseauthServies {
  Future<bool> logout() async {
    //logout method
    try {
      await FirebaseAuth.instance.signOut();
      return true;
    } catch (e) {
      print("Error in LogOut:$e");
      return false;
    }
  }

  getuserID() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    }
  }

  fetch_user_profile() async {
    // ... your existing fetchData logic ...
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;
    final collection = firestore.collection('User');

    final query =
        collection.where('UID', isEqualTo: user?.uid); // Example condition

    final querySnapshot = await query.get();
    final data = querySnapshot.docs.map((doc) => doc.data()).toList();
    // Access data as a list of Maps
    // print(data);
    //
    return data; // Return the retrieved data list
  }
}

class Firebasebuyer {}

class Firebaseseller extends FirebaseauthServies {
  Future<bool> addproducts(String productName, String productDescription,
      String Productcost, List<XFile> images) async {
    try {
      // Step 1: Validate Inputs
      if (productName.isEmpty || productDescription.isEmpty || images.isEmpty) {
        throw Exception(
            "All fields are required, including at least one image.");
      }

      // Step 2: Upload Images to Firebase Storage
      List<String> imageUrls = [];
      for (int i = 0; i < images.length; i++) {
        File imageFile = File(images[i].path);
        String fileName = "${DateTime.now().millisecondsSinceEpoch}_$i";
        UploadTask uploadTask = FirebaseStorage.instance
            .ref("product_images/$fileName")
            .putFile(imageFile);

        TaskSnapshot snapshot = await uploadTask;
        String imageUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      // Step 3: Upload Product Details to Firestore
      await FirebaseFirestore.instance.collection("products").add({
        "name": productName,
        "description": productDescription,
        "Cost": Productcost,
        "images": imageUrls,
        "timestamp": FieldValue.serverTimestamp(),
        "UID": getuserID(),
        "sold":true
      });

      print("Product uploaded successfully!");
      return true;
    } catch (e) {
      print("Error uploading product: $e");
      return false;
    }
  }
}
