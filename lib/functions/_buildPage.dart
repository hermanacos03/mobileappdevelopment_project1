import 'package:flutter/material.dart';

Widget buildPage({
  required int selectedIndex,
  required String selectedHabit,
  required List<String> habits,
}) {
  switch (selectedIndex) {
    case 0:
      return const Text(
        'Homepage',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      );

    case 1:
      return Text(
        selectedHabit.isEmpty ? 'No habit selected' : selectedHabit,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      );

    case 2:
      if (habits.isEmpty) {
        return const Text(
          'No habits added yet',
          style: TextStyle(fontSize: 24),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        itemCount: habits.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(habits[index]),
          );
        },
      );

    default:
      return const Text(
        'Unknown page',
        style: TextStyle(fontSize: 24),
      );
  }
}