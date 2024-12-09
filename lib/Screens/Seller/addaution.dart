import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Addaution extends StatefulWidget {
  const Addaution({super.key});

  @override
  State<Addaution> createState() => _AddautionState();
}

class _AddautionState extends State<Addaution> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 36, left: 5, right: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 10),
                Text(
                  "Add aution",
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
                  topLeft: Radius.circular(40), topRight: Radius.circular(40)),
            ),
          ))
    ]);
  }
}