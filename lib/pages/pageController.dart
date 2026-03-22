import 'dart:async';
import 'package:flutter/material.dart';
import '../functions/addHabit.dart';
import '../functions/loadHabits.dart';
import '../database_helper.dart';
import 'page0.dart';
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

  Future<void> loadHabits() async {
    final habitList = await loadHabitsFromDatabase();

    setState(() {
      habits = habitList.map<Map<String, dynamic>>((habit) {
        final habitMap = habit as Map<String, dynamic>;

        return {
          ...habitMap,
          'streak': habitMap['streak'] ?? 0,
          'secondsLeft': habitMap['secondsLeft'] ?? 30,
        };
      }).toList();
    });

    debugPrint('Sorted habits: $habitList');
  }

  void startHabitTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        for (int i = 0; i < habits.length; i++) {
          if ((habits[i]['secondsLeft'] ?? 0) > 0) {
            habits[i]['secondsLeft']--;
          } else {
            habits[i]['streak'] = 0;
            habits[i]['secondsLeft'] = 30;
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

  void keepHabitStreak(Map<String, dynamic> habit) {
    setState(() {
      habit['streak'] = (habit['streak'] ?? 0) + 1;
      habit['secondsLeft'] = 30;

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
        return Page0(
          habits: habits,
          onAddHabit: () {
            addHabit(
              context: context,
              onHabitSaved: loadHabits,
            );
          },
          onHabitPressed: (habit) {
            setState(() {
              selectedHabit = habit;
              selectedIndex = 1;
            });
          },
          onDeleteHabit: (id) async {
            await deleteHabitFromList(id);
          },
        );

      case 1:
        return Page1(
          selectedHabit: selectedHabit,
          onKeepStreak: () {
            if (selectedHabit != null) {
              keepHabitStreak(selectedHabit!);
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