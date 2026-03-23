import 'dart:async';
import 'package:flutter/material.dart';
import '../functions/addHabit.dart';
import '../functions/next_Reset.dart';
import '../functions/loadHabits.dart';
import '../database_helper.dart';
import '../data/models/habit.dart';
import 'home_page.dart';
import 'habit_settings_page.dart';
import 'page1.dart';
import 'page2.dart';

class PageControllerapp extends StatefulWidget {
  const PageControllerapp({super.key});

  @override
  State<PageControllerapp> createState() => _PageControllerappState();
}

class _PageControllerappState extends State<PageControllerapp> {
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
    final habitList = await loadHabitsFromDatabase();

    setState(() {
      habits = habitList.map<Map<String, dynamic>>((habit) {
        final habitMap = habit as Map<String, dynamic>;
        final loadedTime = (habitMap['time_of_day'] ?? '0000').toString();

        return {
          ...habitMap,
          'streak': habitMap['streak'] ?? 0,
          'habitFrequency': habitMap['habitFrequency'] ?? 1,
          'frequencyCounter': habitMap['frequencyCounter'] ?? 0,
          'time': loadedTime,
          'nextReset': calculateNextReset(loadedTime),
        };
      }).toList();

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

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        for (int i = 0; i < habits.length; i++) {
          final secondsLeft = getSecondsLeft(habits[i]);

          if (secondsLeft <= 0) {
            habits[i]['frequencyCounter'] = 0;
            habits[i]['nextReset'] =
                calculateNextReset(habits[i]['time'].toString());
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
      habit['nextReset'] = calculateNextReset(habit['time'].toString());

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
                builder: (context) => HabitSettingsPage(habit: habit),
              ),
            );

            if (result == true) {
              await loadHabits();
            }
          },
          onDeleteHabit: (id) async {
            await deleteHabitFromList(id);
          },
        );

      case 1:
        return Page1(
          selectedHabit: selectedHabit == null
              ? null
              : {
                  ...selectedHabit!,
                  'secondsLeft': getSecondsLeft(selectedHabit!),
                },
          onKeepStreak: () {
            if (selectedHabit != null) {
              keepHabitStreak(selectedHabit!);
            }
          },
          onIncreaseFrequencyCounter: () {
            if (selectedHabit != null) {
              increaseFrequencyCounter(selectedHabit!);
            }
          },
        );

      case 2:
        return const Page2();

      default:
        return const SizedBox.shrink();
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
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () => changePages(1),
                  child: const Text('1'),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () => changePages(2),
                  child: const Text('2'),
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