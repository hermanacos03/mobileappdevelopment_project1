import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> habits;
  final VoidCallback onAddHabit;
  final Function(Map<String, dynamic>) onHabitPressed;
  final Function(Map<String, dynamic>) onEditHabit;
  final Function(int) onDeleteHabit;

  const HomePage({
    super.key,
    required this.habits,
    required this.onAddHabit,
    required this.onHabitPressed,
    required this.onEditHabit,
    required this.onDeleteHabit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: onAddHabit,
            child: const Icon(Icons.add, size: 35),
          ),
        ),
        const SizedBox(height: 20),
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
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: habit['doneToday'] == true
                                      ? Colors.green
                                      : null,
                                ),
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
                                onEditHabit(habit);
                              },
                              child: const Icon(Icons.edit),
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