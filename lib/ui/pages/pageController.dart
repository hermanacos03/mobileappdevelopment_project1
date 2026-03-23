import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/functions/next_Reset.dart';
import '../../data/database_helper.dart';
import '../../data/models/habit.dart';
import '../../data/repositories/habit_repository.dart';

import 'home_page.dart';
import 'habit_settings_page.dart';
import 'habit_details_page.dart';
import 'heatmap_page.dart';

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
    final List<Map<String, dynamic>> updatedHabits = [];

    for (final habit in habitList) {
      Habit workingHabit = habit;

      if (workingHabit.nextReset <= 0) {
        final fixedReset = calculateNextReset(workingHabit);
        workingHabit = workingHabit.copyWith(nextReset: fixedReset);
        await repository.updateHabit(workingHabit);
      }

      final doneThisCycle = await repository.isHabitDoneThisCycle(workingHabit);

      updatedHabits.add({
        ...workingHabit.toMap(),
        'doneThisCycle': doneThisCycle,
      });
    }

    if (!mounted) return;

    setState(() {
      habits = updatedHabits;

      if (selectedHabit != null) {
        final selectedId = selectedHabit!['id'];
        final matches = habits.where((habit) => habit['id'] == selectedId);

        if (matches.isNotEmpty) {
          selectedHabit = matches.first;
        }
      }
    });
  }

  void startHabitTimer() {
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!mounted) return;

      bool changedAnything = false;

      for (int i = 0; i < habits.length; i++) {
        final secondsLeft = getSecondsLeft(habits[i]);

        if (secondsLeft <= 0) {
          final refreshedHabit = Habit.fromMap(habits[i]);
          final newReset = calculateNextReset(refreshedHabit);

          final resetHabit = refreshedHabit.copyWith(
            frequencyCounter: 0,
            nextReset: newReset,
          );

          await repository.updateHabit(resetHabit);

          habits[i] = {
            ...resetHabit.toMap(),
            'doneThisCycle': false,
          };

          changedAnything = true;
        }
      }

      if (!mounted) return;

      if (changedAnything) {
        await loadHabits();
      } else {
        setState(() {});
      }
    });
  }

  Future<void> deleteHabitFromList(int id) async {
    await DatabaseHelper.instance.deleteHabit(id);

    if (selectedHabit != null && selectedHabit!['id'] == id) {
      selectedHabit = null;
    }

    if (selectedIndex != 0) {
      selectedIndex = 0;
    }

    await loadHabits();
  }

  Widget _buildHomePage() {
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

          if (!mounted) return;

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

          if (!mounted) return;

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

  Widget _buildPage() {
    switch (selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return const HeatmapScreen();
      default:
        return _buildHomePage();
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
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => changePages(0),
                      child: const Text('Home'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => changePages(1),
                      child: const Text('Heatmap'),
                    ),
                  ),
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