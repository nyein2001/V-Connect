import 'package:flutter/material.dart';

class RedeemScreen extends StatefulWidget {
  const RedeemScreen({super.key});

  @override
  State<RedeemScreen> createState() => RedeemScreenState();
}

class RedeemScreenState extends State<RedeemScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Redeem Screen'),
      ),
    );
  }
}
