import 'package:animate_do/animate_do.dart';
import 'package:farmer_auction_app/Auth/loginpage.dart';
import 'package:farmer_auction_app/Screens/Componets/components.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController namecontroller = TextEditingController();
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController phonecontroller = TextEditingController();
  final TextEditingController addresscontroller = TextEditingController();
  final TextEditingController pincodecontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  final TextEditingController rePasswordcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: Colors.green),
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    FadeInUp(
                      duration: const Duration(milliseconds: 1000),
                      child: const Text(
                        "Create Account",
                        style: TextStyle(color: Colors.white, fontSize: 40),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 0),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 20),
                          FadeInUp(
                            duration: const Duration(milliseconds: 1400),
                            child: Column(
                              children: [
                                buildTextField(
                                    "Name", namecontroller, TextInputType.name),
                                buildTextField("Email", emailcontroller,
                                    TextInputType.emailAddress),
                                buildTextField("Phone no", phonecontroller,
                                    TextInputType.phone),
                                buildTextField("Address", addresscontroller,
                                    TextInputType.streetAddress),
                                buildTextField("Pincode", pincodecontroller,
                                    TextInputType.number),
                                buildTextField("Password", passwordcontroller,
                                    TextInputType.text,
                                    obscureText: true),
                                buildTextField("Re-enter Password",
                                    rePasswordcontroller, TextInputType.text,
                                    obscureText: true),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          MaterialButton(
                            onPressed: () {
                              accountcreate(
                                namecontroller,
                                emailcontroller,
                                phonecontroller,
                                addresscontroller,
                                pincodecontroller,
                                passwordcontroller,
                                rePasswordcontroller,
                              );
                            },
                            height: 50,
                            color: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Center(
                              child: Text(
                                "Signup",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          FadeInUp(
                            duration: const Duration(milliseconds: 1700),
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Loginpage()),
                                );
                              },
                              child: const Text(
                                "Already have an account? Login",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                        ],
                      ),
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

  void accountcreate(
    final TextEditingController namecontroller,
    final TextEditingController emailcontroller,
    final TextEditingController phonecontroller,
    final TextEditingController addresscontroller,
    final TextEditingController pincodecontroller,
    final TextEditingController passwordcontroller,
    final TextEditingController rePasswordcontroller,
  ) async {
    String email = emailcontroller.text.trim();
    String password = passwordcontroller.text.trim();
    String repasword = rePasswordcontroller.text.trim();
    String name = namecontroller.text.trim();
    String address = addresscontroller.text.trim();
    String pincode = pincodecontroller.text.trim();
    String phoneNo = phonecontroller.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        repasword.isEmpty ||
        address.isEmpty ||
        pincode.isEmpty ||
        phoneNo.isEmpty) {
      errormessage("All fields are required.");
      return;
    }
    if (password != repasword) {
      errormessage("Passwords do not match.");
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;
        createdatabase(uid, email, name, address, pincode, phoneNo);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const Loginpage()));
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "invalid-email":
          errormessage("Invalid Email Address");
          break;
        case "weak-password":
          errormessage("Weak Password");
          break;
        case "email-already-in-use":
          errormessage("Email is already in use.");
          break;
        default:
          errormessage("An error occurred.");
      }
    }
  }

  void createdatabase(String uid, String email, String name, String address,
      String pincode, String phoneNo) async {
    Map<String, dynamic> newuserdata = {
      "UID": uid,
      "Name": name,
      "Email": email,
      "Address": address,
      "Pincode": pincode,
      "Phone no": phoneNo,
    };
    await FirebaseFirestore.instance
        .collection("User")
        .doc(uid)
        .set(newuserdata);
  }

  void errormessage(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error!'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Okay'),
            ),
          ],
        );
      },
    );
  }
}
