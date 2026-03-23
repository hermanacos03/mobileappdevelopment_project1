import 'package:flutter/material.dart';
import '../data/repositories/habit_repository.dart';
import '../data/models/habit.dart';
import '../core/constants/enums.dart';
import '../../core/constants/enums.dart';
import '../core/utils/weekDays.dart';

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

  Future<void> saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    final habit = Habit(
      id: widget.habit?.id,
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
      repeatType: selectedRepeat,
      dayOfWeek: selectedRepeat == RepeatType.weekly
          ? selectedDayOfWeek
          : null,
      dayOfMonth: selectedRepeat == RepeatType.monthly ||
              selectedRepeat == RepeatType.yearly
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
          decoration: const InputDecoration(labelText: "Day of month (1-31)"),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            selectedDayOfMonth = int.tryParse(value);
          },
        );

      case RepeatType.yearly:
        return Column(
          children: [
            TextFormField(
              decoration:
                  const InputDecoration(labelText: "Month (1-12)"),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                selectedMonth = int.tryParse(value);
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
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

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    timeController.dispose();
    super.dispose();
  }

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
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Habit Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty
                        ? "Enter name"
                        : null,
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

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

              buildRepeatOptions(),

              const SizedBox(height: 20),

              TextFormField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: "Time (HHMM)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: saveHabit,
                child: Text(isEditMode ? "Update" : "Create"),
              )
            ],
          ),
        ),
      ),
    );
  }
}