import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerListLoadingEffect extends StatelessWidget {
  const ShimmerListLoadingEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(
          5,
          (index) => ListTile(
            leading: const CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white,
            ),
            title: Container(
              height: 10,
              width: double.infinity,
              color: Colors.white,
            ),
            subtitle: Container(
              height: 10,
              width: double.infinity,
              color: Colors.white,
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ),
    );
  }
}
