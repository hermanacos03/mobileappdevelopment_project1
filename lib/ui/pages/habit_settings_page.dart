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
    timeController = TextEditingController(text: habit?.timeOfDay ?? '');

    selectedRepeat = habit?.repeatType ?? RepeatType.daily;
    selectedDayOfWeek = habit?.dayOfWeek;
    selectedDayOfMonth = habit?.dayOfMonth;
    selectedMonth = habit?.month;
  }

  Future<void> saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedRepeat == RepeatType.weekly && selectedDayOfWeek == null) {
      showError('Please select a weekday');
      return;
    }

    if (selectedRepeat == RepeatType.monthly) {
      if (selectedDayOfMonth == null ||
          selectedDayOfMonth! < 1 ||
          selectedDayOfMonth! > 31) {
        showError('Enter a valid day (1-31)');
        return;
      }
    }

    if (selectedRepeat == RepeatType.yearly) {
      if (selectedMonth == null || selectedMonth! < 1 || selectedMonth! > 12) {
        showError('Enter a valid month (1-12)');
        return;
      }

      if (selectedDayOfMonth == null ||
          selectedDayOfMonth! < 1 ||
          selectedDayOfMonth! > 31) {
        showError('Enter a valid day (1-31)');
        return;
      }
    }
    final habit = Habit(
      id: widget.habit?.id,
      name: nameController.text.trim(),
      description: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
      repeatType: selectedRepeat,
      dayOfWeek:
          selectedRepeat == RepeatType.weekly ? selectedDayOfWeek : null,
      dayOfMonth: (selectedRepeat == RepeatType.monthly ||
              selectedRepeat == RepeatType.yearly)
          ? selectedDayOfMonth
          : null,
      month: selectedRepeat == RepeatType.yearly ? selectedMonth : null,
      timeOfDay: timeController.text.trim(),
      createdAt: widget.habit?.createdAt ?? DateTime.now().toIso8601String(),

      habitFrequency: widget.habit?.habitFrequency ?? 1,
      frequencyCounter: widget.habit?.frequencyCounter ?? 0,
      nextReset: widget.habit?.nextReset ?? 0,
    );

    if (isEditMode) {
      await repo.updateHabit(habit);
    } else {
      await repo.createHabit(habit);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget buildRepeatOptions() {
    switch (selectedRepeat) {
      case RepeatType.weekly:
        return DropdownButtonFormField<int>(
          value: selectedDayOfWeek,
          decoration: const InputDecoration(
            labelText: 'Day of week',
            border: OutlineInputBorder(),
          ),
          hint: const Text('Select day of week'),
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
          decoration: const InputDecoration(
            labelText: 'Day of month (1-31)',
            border: OutlineInputBorder(),
          ),
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
              decoration: const InputDecoration(
                labelText: 'Month (1-12)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                selectedMonth = int.tryParse(value);
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: selectedDayOfMonth?.toString(),
              decoration: const InputDecoration(
                labelText: 'Day (1-31)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                selectedDayOfMonth = int.tryParse(value);
              },
            ),
          ],
        );

      case RepeatType.daily:
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
        title: Text(isEditMode ? 'Edit Habit' : 'Add Habit'),
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
                  labelText: 'Habit Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a habit name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<RepeatType>(
                value: selectedRepeat,
                decoration: const InputDecoration(
                  labelText: 'Repeat Type',
                  border: OutlineInputBorder(),
                ),
                items: RepeatType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRepeat = value!;
                    selectedDayOfWeek = null;
                    selectedDayOfMonth = null;
                    selectedMonth = null;
                  });
                },
              ),
              const SizedBox(height: 20),
              buildRepeatOptions(),
              const SizedBox(height: 20),
              TextFormField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: 'Time (HHMM)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter time';
                  }

                  if (value.length != 4) {
                    return 'Enter 4 digits (HHMM)';
                  }

                  final hour = int.tryParse(value.substring(0, 2));
                  final minute = int.tryParse(value.substring(2, 4));

                  if (hour == null || minute == null) {
                    return 'Invalid number';
                  }

                  if (hour < 0 || hour > 23) {
                    return 'Hour must be 00-23';
                  }

                  if (minute < 0 || minute > 59) {
                    return 'Minute must be 00-59';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: saveHabit,
                child: Text(isEditMode ? 'Update' : 'Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}