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

// Firebase servies  for buyers
class Firebasebuyer extends FirebaseauthServies {
  
  Stream<DocumentSnapshot<Map<String, dynamic>>> fetchbuyersingleProducts(
      String docid) {
    return FirebaseFirestore.instance
        .collection('products')
        .doc(docid)
        .snapshots();
  }

  Stream<QuerySnapshot> fetchbuyerProducts() {
    return FirebaseFirestore.instance.collection('products').snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> fetchautiondetails(
      String docID) {
    return FirebaseFirestore.instance
        .collection('auctions')
        .doc(docID)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchHighestBid(String docID) {
    return FirebaseFirestore.instance
        .collection('auctions')
        .doc(docID)
        .collection('bids')
        .orderBy('bid', descending: true)
        .limit(1)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchbids(String docID) {
    return FirebaseFirestore.instance
        .collection('auctions')
        .doc(docID)
        .collection("bids")
        .orderBy('bid', descending: true)
        .snapshots();
  }

  Future<Map<String, dynamic>?> fetchUserDetails(String docId) async {
    try {
      // Access Firestore and the specific user's document
      final firestore = FirebaseFirestore.instance;
      final docSnapshot = await firestore.collection('User').doc(docId).get();

      if (docSnapshot.exists) {
        // Return the user data as a Map
        return docSnapshot.data();
      } else {
        print('User document not found.');
        return null;
      }
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }
}

// Firebase servies for seller
class Firebaseseller extends FirebaseauthServies {
  // add products
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
      final ref = await FirebaseFirestore.instance.collection("products").add({
        "name": productName,
        "description": productDescription,
        "Cost": Productcost,
        "images": imageUrls,
        "timestamp": FieldValue.serverTimestamp(),
        "UID": getuserID(),
        "sold": true
      });

      final docid = ref.id;
      await FirebaseFirestore.instance
          .collection("products")
          .doc(docid)
          .update({"docID": docid});

      print("Product uploaded successfully!");
      return true;
    } catch (e) {
      print("Error uploading product: $e");
      return false;
    }
  }

  // fetch the seller products
  Stream<QuerySnapshot> fetchsellerProducts() {
    return FirebaseFirestore.instance
        .collection('products')
        .where("UID", isEqualTo: getuserID())
        .snapshots();
  }

  Future<bool> deletesellerAuction(String docId) async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('auctions').doc(docId);

      await docRef.delete();

      return true; // Deletion successful
    } catch (error) {
      return false; // Deletion failed
    }
  }

  Future<bool> deletesellerProducts(String docId) async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('products').doc(docId);

      await docRef.delete();

      return true; // Deletion successful
    } catch (error) {
      return false; // Deletion failed
    }
  }
}
