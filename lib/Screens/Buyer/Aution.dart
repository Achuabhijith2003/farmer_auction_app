import 'package:flutter/material.dart';

class Aution extends StatefulWidget {
  const Aution({super.key});

  @override
  State<Aution> createState() => _AutionState();
}

class _AutionState extends State<Aution> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Autions"),
      ),
    );
  }
}
