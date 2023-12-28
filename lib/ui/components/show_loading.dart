import 'package:flutter/material.dart';
import 'custom_card.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: CustomCard(
            padding: EdgeInsets.all(20.0),
            margin: EdgeInsets.all(20),
            child: CircularProgressIndicator()));
  }
}
