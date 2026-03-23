import 'package:flutter/material.dart';
import '../../data/repositories/habit_repository.dart';
import '../../data/models/habit.dart';
import '../../core/constants/enums.dart';
import '../../core/utils/weekDays.dart';

class HabitSettingsPage extends StatefulWidget {
  final Habit? habit;

  const HabitSettingsPage({super.key, this.habit});

  @override
  State<HabitSettingsPage> createState() => _HabitSettingsPageState();
}

class _HabitSettingsPageState extends State<HabitSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final repo = HabitRepository();

  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController timeController;

  RepeatType selectedRepeat = RepeatType.daily;

  int? selectedDayOfWeek;
  int? selectedDayOfMonth;
  int? selectedMonth;

  bool get isEditMode => widget.habit != null;

  @override
  void initState() {
    super.initState();

    final habit = widget.habit;

    nameController = TextEditingController(text: habit?.name ?? '');
    descriptionController =
        TextEditingController(text: habit?.description ?? '');
    timeController =
        TextEditingController(text: habit?.timeOfDay ?? '');

    selectedRepeat = habit?.repeatType ?? RepeatType.daily;
    selectedDayOfWeek = habit?.dayOfWeek;
    selectedDayOfMonth = habit?.dayOfMonth;
    selectedMonth = habit?.month;
  }

  // =========================
  // VALIDATION + SAVE
  // =========================
  Future<void> saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    // Extra validation for repeat rules
    if (selectedRepeat == RepeatType.weekly && selectedDayOfWeek == null) {
      showError("Please select a weekday");
      return;
    }

    if (selectedRepeat == RepeatType.monthly) {
      if (selectedDayOfMonth == null ||
          selectedDayOfMonth! < 1 ||
          selectedDayOfMonth! > 31) {
        showError("Enter a valid day (1–31)");
        return;
      }
    }

    if (selectedRepeat == RepeatType.yearly) {
      if (selectedMonth == null ||
          selectedMonth! < 1 ||
          selectedMonth! > 12) {
        showError("Enter a valid month (1–12)");
        return;
      }

      if (selectedDayOfMonth == null ||
          selectedDayOfMonth! < 1 ||
          selectedDayOfMonth! > 31) {
        showError("Enter a valid day (1–31)");
        return;
      }
    }

    final habit = Habit(
      id: widget.habit?.id,
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
      repeatType: selectedRepeat,
      dayOfWeek:
          selectedRepeat == RepeatType.weekly ? selectedDayOfWeek : null,
      dayOfMonth: (selectedRepeat == RepeatType.monthly ||
              selectedRepeat == RepeatType.yearly)
          ? selectedDayOfMonth
          : null,
      month: selectedRepeat == RepeatType.yearly ? selectedMonth : null,
      timeOfDay: timeController.text.trim(),
      createdAt:
          widget.habit?.createdAt ?? DateTime.now().toIso8601String(),
    );

    if (isEditMode) {
      await repo.updateHabit(habit);
    } else {
      await repo.createHabit(habit);
    }

    Navigator.pop(context, true);
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // =========================
  // REPEAT OPTIONS UI
  // =========================
  Widget buildRepeatOptions() {
    switch (selectedRepeat) {
      case RepeatType.weekly:
        return DropdownButtonFormField<int>(
          value: selectedDayOfWeek,
          hint: const Text("Select day of week"),
          items: List.generate(
            7,
            (index) => DropdownMenuItem(
              value: index,
              child: Text(weekDays[index]),
            ),
          ),
          onChanged: (value) {
            setState(() {
              selectedDayOfWeek = value;
            });
          },
        );

      case RepeatType.monthly:
        return TextFormField(
          initialValue: selectedDayOfMonth?.toString(),
          decoration:
              const InputDecoration(labelText: "Day of month (1-31)"),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            selectedDayOfMonth = int.tryParse(value);
          },
        );

      case RepeatType.yearly:
        return Column(
          children: [
            TextFormField(
              initialValue: selectedMonth?.toString(),
              decoration:
                  const InputDecoration(labelText: "Month (1-12)"),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                selectedMonth = int.tryParse(value);
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: selectedDayOfMonth?.toString(),
              decoration:
                  const InputDecoration(labelText: "Day (1-31)"),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                selectedDayOfMonth = int.tryParse(value);
              },
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  // =========================
  // DISPOSE
  // =========================
  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    timeController.dispose();
    super.dispose();
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Edit Habit" : "Add Habit"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // NAME
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Habit Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? "Enter a habit name"
                        : null,
              ),

              const SizedBox(height: 20),

              // DESCRIPTION
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              // REPEAT TYPE
              DropdownButtonFormField<RepeatType>(
                value: selectedRepeat,
                decoration: const InputDecoration(
                  labelText: "Repeat Type",
                  border: OutlineInputBorder(),
                ),
                items: RepeatType.values
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRepeat = value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              // REPEAT OPTIONS
              buildRepeatOptions(),

              const SizedBox(height: 20),

              // TIME
              TextFormField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: "Time (HHMM)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter time";
                  }

                  if (value.length != 4) {
                    return "Enter 4 digits (HHMM)";
                  }

                  final hour =
                      int.tryParse(value.substring(0, 2));
                  final minute =
                      int.tryParse(value.substring(2, 4));

                  if (hour == null || minute == null) {
                    return "Invalid number";
                  }

                  if (hour < 0 || hour > 23) {
                    return "Hour must be 00–23";
                  }

                  if (minute < 0 || minute > 59) {
                    return "Minute must be 00–59";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 30),

              // SAVE BUTTON
              ElevatedButton(
                onPressed: saveHabit,
                child: Text(isEditMode ? "Update" : "Create"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
