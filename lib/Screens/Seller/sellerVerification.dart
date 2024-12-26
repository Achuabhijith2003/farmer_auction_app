import 'dart:math';

import 'package:farmer_auction_app/key.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

class Sellerverification extends StatefulWidget {
  const Sellerverification({super.key});

  @override
  State<Sellerverification> createState() => _SellerverificationState();
}

class _SellerverificationState extends State<Sellerverification> {
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController aadhaarCardController = TextEditingController();
  final TextEditingController bankAccountNoController = TextEditingController();
  final TextEditingController ifscCodeController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  late int otpNumber;
  bool isLoading = false;

  final TwilioFlutter twilioFlutter = TwilioFlutter(
    accountSid: accountSids,
    authToken: authTokens,
    twilioNumber: '',
  );

  int generateOtp() {
    final random = Random();
    return 100000 + random.nextInt(900000);
  }

  Future<void> sendOtpSms(String phoneNumber) async {
    setState(() {
      isLoading = true;
    });
    otpNumber = generateOtp();

    try {
      await twilioFlutter.sendSMS(
        toNumber: "+91$phoneNumber",
        messageBody:
            'Your Seller Account verification OTP is $otpNumber - Framap',
      );
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send OTP: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void validateAndSendOtp() {
    final fullname = fullnameController.text.trim();
    final phoneNumber = phoneNumberController.text.trim();
    final aadhaar = aadhaarCardController.text.trim();
    final bankAccount = bankAccountNoController.text.trim();
    final ifsc = ifscCodeController.text.trim();

    if (fullname.isEmpty ||
        phoneNumber.isEmpty ||
        aadhaar.isEmpty ||
        bankAccount.isEmpty ||
        ifsc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all the fields!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Basic phone number validation
    if (phoneNumber.length != 10 || int.tryParse(phoneNumber) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit phone number!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    sendOtpSms(phoneNumber);
  }

  bool checkOtp(int enteredOtp) {
    return otpNumber == enteredOtp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Seller Verification',
          style: GoogleFonts.aBeeZee(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 27,
          ),
        ),
        backgroundColor: Colors.red[600],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildTextField("Full Name", fullnameController, TextInputType.name),
            const SizedBox(height: 10),
            buildTextField(
                "Phone Number", phoneNumberController, TextInputType.number),
            const SizedBox(height: 10),
            buildTextField(
                "Aadhaar Card", aadhaarCardController, TextInputType.number),
            const SizedBox(height: 10),
            buildTextField("Bank Account No", bankAccountNoController,
                TextInputType.number),
            const SizedBox(height: 10),
            buildTextField("IFSC Code", ifscCodeController, TextInputType.text),
            const SizedBox(height: 15),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: validateAndSendOtp,
                    child: const Text('Get OTP'),
                  ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String hintText, TextEditingController controller,
      TextInputType keyboardType) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
