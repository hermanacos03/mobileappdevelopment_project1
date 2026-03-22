import 'package:flutter/material.dart';
import '../database_helper.dart';

Future<void> addHabit({
  required BuildContext context,
  required Future<void> Function() onHabitSaved,
}) async {
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController frequencyController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Creating a new habit'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Habit Name",
                      hintText: "Example: Laundry",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a habit name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 25),
                  TextFormField(
                    controller: frequencyController,
                    decoration: const InputDecoration(
                      labelText: "Frequency of habit",
                      hintText: "1(once a day), 2(twice a day)",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a frequency';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please numbers only';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 25),
                  TextFormField(
                    controller: timeController,
                    maxLines: 1,
                    decoration: const InputDecoration(
                      labelText: "When do you want the habit to end",
                      hintText: "@2230 (hrs mins)",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a time';
                      }
                      if (value.length != 4) {
                        return 'Please enter exactly 4 digits';
                      }
                      int firstDigit = int.parse(value[0]);
                      int secondDigit = int.parse(value[1]);
                      int thirdDigit = int.parse(value[2]);
                      int fourthDigit = int.parse(value[3]);
                      if (firstDigit>2) {
                        return 'This is not in range of time(hours area 1)';
                      }
                      if (firstDigit==2 && secondDigit>3) {
                        return 'This is not in range of time(hours area 2)';
                      }
                      if (thirdDigit>6) {
                        return 'This is not in range of time(minutes area 1)';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.cancel, size: 20),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final habitTitle = nameController.text.trim();
                final habitFrequency = frequencyController.text.trim();
                final habitTime = timeController.text.trim();

                await DatabaseHelper.instance.insertHabit({
                  'name': habitTitle,
                  'description': habitFrequency,
                  'repeat_type': 'daily',
                  'day_of_week': null,
                  'day_of_month': null,
                  'month': null,
                  'time_of_day': habitTime,
                  'created_at': DateTime.now().toIso8601String(),
                });

                debugPrint(
                  'Ok that habit worked: $habitTitle at $habitTime (freq: $habitFrequency)',
                );

                await onHabitSaved();

                debugPrint('Habit saved to database');
                debugPrint('Habit title: $habitTitle');
                debugPrint('Habit frequency: $habitFrequency');
                debugPrint('Habit time: $habitTime');

                Navigator.pop(context);
              }
            },
            child: const Icon(Icons.check_box, size: 25),
          ),
        ],
      );
    },
  );
}