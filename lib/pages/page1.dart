import 'package:flutter/material.dart';

class Page1 extends StatelessWidget {
  final Map<String, dynamic>? selectedHabit;
  final VoidCallback onKeepStreak;

  const Page1({
    super.key,
    required this.selectedHabit,
    required this.onKeepStreak,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedHabit == null) {
      return const Center(
        child: Text(
          'No habit selected',
          style: TextStyle(fontSize: 24),
        ),
      );
    }

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            selectedHabit!['name'] ?? 'Unnamed Habit',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Streak: ${selectedHabit!['streak'] ?? 0}',
            style: const TextStyle(fontSize: 22),
          ),
          const SizedBox(height: 10),
          Text(
            'Time left: ${selectedHabit!['secondsLeft'] ?? 30}',
            style: const TextStyle(fontSize: 22),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onKeepStreak,
            child: const Text('Keep Streak'),
          ),
        ],
    );
  }
}