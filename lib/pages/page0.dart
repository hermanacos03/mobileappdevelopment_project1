import 'package:flutter/material.dart';
import '../functions/dateTime.dart';

class Page0 extends StatelessWidget {
  final List<Map<String, dynamic>> habits;
  final VoidCallback onAddHabit;
  final Function(Map<String, dynamic>) onHabitPressed;
  final Function(int) onDeleteHabit;

  const Page0({
    super.key,
    required this.habits,
    required this.onAddHabit,
    required this.onHabitPressed,
    required this.onDeleteHabit,
  });

  @override
  Widget build(BuildContext context) {
    final dateTime = getFormattedDateTime();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          '${dateTime['date']}\n${dateTime['time']}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: onAddHabit,
            child: const Icon(Icons.add, size: 35),
          ),
        ),
        const SizedBox(height: 15),
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

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 60,
                              child: ElevatedButton(
                                onPressed: () {
                                  onHabitPressed(habit);
                                },
                                child: Text(
                                  habit['name'] ?? 'Unnamed Habit',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: () {
                                onDeleteHabit(habit['id']);
                              },
                              child: const Icon(Icons.delete),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}