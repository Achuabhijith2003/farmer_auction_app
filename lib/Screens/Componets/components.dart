import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

Widget buildTextField(
  String hint,
  TextEditingController controller,
  TextInputType inputType, {
  bool obscureText = false,
}) {
  return FadeInUp(
      duration: const Duration(milliseconds: 1400),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                  color: Color.fromRGBO(225, 95, 27, .3),
                  blurRadius: 20,
                  offset: Offset(0, 10))
            ]),
        child: Container(
          margin: const EdgeInsets.only(bottom: 5.0),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: inputType,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              border: InputBorder.none,
            ),
          ),
        ),
      ));
}