import 'package:flutter/material.dart';

class Page1 extends StatelessWidget {
  final Map<String, dynamic>? selectedHabit;
  final VoidCallback onKeepStreak;
  final VoidCallback onIncreaseFrequencyCounter;

  const Page1({
    super.key,
    required this.selectedHabit,
    required this.onKeepStreak,
    required this.onIncreaseFrequencyCounter,
  });

  String formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

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

    final int habitFrequency =
        int.tryParse((selectedHabit!['habitFrequency'] ?? 1).toString()) ?? 1;

    final int frequencyCounter =
        int.tryParse((selectedHabit!['frequencyCounter'] ?? 0).toString()) ?? 0;

    final int secondsLeft =
        int.tryParse((selectedHabit!['secondsLeft'] ?? 0).toString()) ?? 0;

    final bool isSafe = frequencyCounter >= habitFrequency;

    if (isSafe) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
              'Streak is saved until tomorrow',
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 20),
            
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
          const SizedBox(height: 20),
          Text(
            'Progress: $frequencyCounter / $habitFrequency',
            style: const TextStyle(fontSize: 22),
          ),
          const SizedBox(height: 30),
          Text(
            formatTime(secondsLeft),
            style: const TextStyle(fontSize: 22),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: onIncreaseFrequencyCounter,
            child: const Text('Done Once'),
          ),
        ],
      ),
    );
  }
}