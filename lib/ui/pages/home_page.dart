import 'package:flutter/material.dart';
import '../../functions/dateTime.dart';

class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> habits;
  final VoidCallback onAddHabit;
  final Future<void> Function(Map<String, dynamic>) onHabitPressed;
  final Function(int) onDeleteHabit;

  const HomePage({
    super.key,
    required this.habits,
    required this.onAddHabit,
    required this.onHabitPressed,
    required this.onDeleteHabit,
  });

  @override
  Widget build(BuildContext context) {
    final dateTime = getFormattedDateTime();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            '${dateTime['date']}\n${dateTime['time']}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton.icon(
              onPressed: onAddHabit,
              icon: const Icon(Icons.add, size: 28),
              label: const Text(
                "Add Habit",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: habits.isEmpty
                ? const Center(
                    child: Text(
                      'No habits added yet',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      final name = habit['name'] ?? 'Unnamed Habit';

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () => onHabitPressed(habit),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              if (habit['id'] != null) {
                                onDeleteHabit(habit['id']);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}