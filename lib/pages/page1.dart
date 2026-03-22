import 'package:flutter/material.dart';

class Page1 extends StatelessWidget {
  final String selectedHabit;

  const Page1({
    super.key,
    required this.selectedHabit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          selectedHabit.isEmpty ? 'No habit selected' : selectedHabit,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}