import 'package:flutter/material.dart';
import '../functions/addHabit.dart';
import '../functions/loadHabits.dart';
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
  List<String> habits = [];
  String selectedHabit = '';

  @override
  void initState() {
    super.initState();
    loadHabits();
  }

  Future<void> loadHabits() async {
    final habitList = await loadHabitsFromDatabase();

    setState(() {
      habits = habitList;
    });

    debugPrint('Sorted habits: $habitList');
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
        );

      case 1:
        return Page1(selectedHabit: selectedHabit);

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