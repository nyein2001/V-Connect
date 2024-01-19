import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  final String emptyTitle;
  final String emptyMessage;

  const EmptyWidget({
    super.key,
    required this.emptyTitle,
    required this.emptyMessage,
  });
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          child: Icon(
            Icons.not_listed_location,
            size: 80,
            color: Colors.blue,
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        Text(
          emptyTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ).tr(),
        const SizedBox(height: 8),
        Text(
          emptyMessage,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ).tr(),
        const SizedBox(height: 16),
      ],
    ));
  }
}
