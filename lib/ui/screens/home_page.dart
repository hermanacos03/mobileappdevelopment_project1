import 'package:flutter/material.dart';
import '../../data/repositories/habit_repository.dart';
import '../../data/models/habit.dart';
import '../widgets/habit_card.dart';
import '../widgets/add_habit_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final repo = HabitRepository();
  List<Habit> habits = [];

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final loaded = await repo.getAllHabits();
    setState(() {
      habits = loaded;
    });
  }

  void _showAddHabitDialog() async {
    final added = await showDialog(
      context: context,
      builder: (context) => AddHabitDialog(repo: repo),
    );
    if (added == true) _loadHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Habit Mastery League')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: habits.isEmpty
            ? const Center(child: Text('No habits yet'))
            : ListView.builder(
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  return HabitCard(habit: habits[index]);
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}