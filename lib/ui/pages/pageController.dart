import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/functions/next_Reset.dart';
import '../../data/database_helper.dart';
import '../../data/models/habit.dart';
import '../../data/repositories/habit_repository.dart';

import 'home_page.dart';
import 'habit_settings_page.dart';
import 'habit_details_page.dart';

class PageControllerapp extends StatefulWidget {
  const PageControllerapp({super.key});

  @override
  State<PageControllerapp> createState() => _PageControllerappState();
}

class _PageControllerappState extends State<PageControllerapp> {
  final HabitRepository repository = HabitRepository();

  int selectedIndex = 0;
  List<Map<String, dynamic>> habits = [];
  Map<String, dynamic>? selectedHabit;

  Timer? timer;

  @override
  void initState() {
    super.initState();
    loadHabits();
    startHabitTimer();
  }

  int getSecondsLeft(Map<String, dynamic> habit) {
    final nextReset = habit['nextReset'];
    if (nextReset == null) return 0;

    final now = DateTime.now().millisecondsSinceEpoch;
    final secondsLeft = ((nextReset - now) / 1000).floor();

    return secondsLeft > 0 ? secondsLeft : 0;
  }

  Future<void> loadHabits() async {
    final habitList = await repository.getAllHabits();

    List<Map<String, dynamic>> updatedHabits = [];

    for (final habit in habitList) {
      final habitMap = habit.toMap();
      final doneToday = await repository.isHabitDoneToday(habit.id!);

      updatedHabits.add({
        ...habitMap,
        'streak': habitMap['streak'] ?? 0,
        'habitFrequency': habitMap['habitFrequency'] ?? 1,
        'frequencyCounter': habitMap['frequencyCounter'] ?? 0,
        'nextReset': calculateNextReset(habit),
        'doneToday': doneToday,
      });
    }

    setState(() {
      habits = updatedHabits;

      if (selectedHabit != null) {
        final selectedId = selectedHabit!['id'];
        final match = habits.where((habit) => habit['id'] == selectedId);

        if (match.isNotEmpty) {
          selectedHabit = match.first;
        }
      }
    });
  }

  void startHabitTimer() {
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {
        for (int i = 0; i < habits.length; i++) {
          final secondsLeft = getSecondsLeft(habits[i]);

          if (secondsLeft <= 0) {
            habits[i]['frequencyCounter'] = 0;

            // THIS is the missing reset for your button color
            habits[i]['doneToday'] = false;

            final refreshedHabit = Habit.fromMap(habits[i]);
            habits[i]['nextReset'] = calculateNextReset(refreshedHabit);
          }
        }

        if (selectedHabit != null) {
          final selectedId = selectedHabit!['id'];
          final match = habits.where((habit) => habit['id'] == selectedId);

          if (match.isNotEmpty) {
            selectedHabit = match.first;
          }
        }
      });
    });
  }

  void increaseFrequencyCounter(Map<String, dynamic> habit) {
    setState(() {
      final currentCount =
          int.tryParse((habit['frequencyCounter'] ?? 0).toString()) ?? 0;
      habit['frequencyCounter'] = currentCount + 1;

      if (selectedHabit != null && selectedHabit!['id'] == habit['id']) {
        selectedHabit = habit;
      }
    });
  }

  void keepHabitStreak(Map<String, dynamic> habit) {
    setState(() {
      habit['streak'] = (habit['streak'] ?? 0) + 1;
      habit['frequencyCounter'] = 0;

      final refreshedHabit = Habit.fromMap(habit);
      habit['nextReset'] = calculateNextReset(refreshedHabit);

      if (selectedHabit != null && selectedHabit!['id'] == habit['id']) {
        selectedHabit = habit;
      }
    });
  }

  Future<void> deleteHabitFromList(int id) async {
    await DatabaseHelper.instance.deleteHabit(id);

    if (selectedHabit != null && selectedHabit!['id'] == id) {
      selectedHabit = null;
      selectedIndex = 0;
    }

    await loadHabits();
  }

  Widget _buildPage() {
    switch (selectedIndex) {
      case 0:
      default:
        return HomePage(
          habits: habits,
          onAddHabit: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HabitSettingsPage(),
              ),
            );

            if (result == true) {
              await loadHabits();
            }
          },
          onHabitPressed: (habitMap) async {
            final habit = Habit.fromMap(habitMap);

            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HabitDetailsPage(habit: habit),
              ),
            );

            if (result == true) {
              await loadHabits();
            }
          },
          onEditHabit: (habitMap) async {
            final habit = Habit.fromMap(habitMap);

            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HabitSettingsPage(habit: habit),
              ),
            );

            if (result == true) {
              await loadHabits();

              setState(() {
                if (selectedHabit != null &&
                    selectedHabit!['id'] == habitMap['id']) {
                  final updatedHabit = habits.firstWhere(
                    (h) => h['id'] == habitMap['id'],
                    orElse: () => selectedHabit!,
                  );
                  selectedHabit = updatedHabit;
                }
              });
            }
          },
          onDeleteHabit: (id) async {
            await deleteHabitFromList(id);
          },
        );
    }
  }

  void changePages(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Switcher'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => changePages(0),
                  child: const Text('Home'),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Expanded(
              child: _buildPage(),
            ),
          ],
        ),
      ),
    );
  }
}