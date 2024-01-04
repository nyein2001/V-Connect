import 'package:flutter/material.dart';

class ReferenceCodeScreen extends StatefulWidget {
  const ReferenceCodeScreen({super.key});

  @override
  State<ReferenceCodeScreen> createState() => ReferenceCodeScreenState();
}

class ReferenceCodeScreenState extends State<ReferenceCodeScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Reference Code Screen'),
      ),
    );
  }
}
