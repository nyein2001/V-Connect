import 'package:flutter/material.dart';

class EarnPointScreen extends StatefulWidget {
  const EarnPointScreen({super.key});

  @override
  State<EarnPointScreen> createState() => EarnPointScreenState();
}

class EarnPointScreenState extends State<EarnPointScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Earn Point Screen'),
      ),
    );
  }
}
