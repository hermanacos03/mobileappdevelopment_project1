import 'package:flutter/material.dart';
import '../../data/models/habit.dart';
import '../../data/repositories/habit_repository.dart';
import 'home_page.dart';
import 'habit_settings_page.dart';
import 'habit_details_page.dart';

class AppPageController extends StatefulWidget {
  const AppPageController({super.key});

  @override
  State<AppPageController> createState() => _AppPageControllerState();
}

class _AppPageControllerState extends State<AppPageController>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  final HabitRepository repository = HabitRepository();

  List<Habit> habits = [];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    loadHabits();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  // =========================
  // LOAD DATA
  // =========================
  Future<void> loadHabits() async {
    final data = await repository.getAllHabits();
    setState(() {
      habits = data;
    });
  }

  // =========================
  // NAVIGATION
  // =========================

  Future<void> openHabitSettings({Habit? habit}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HabitSettingsPage(habit: habit),
      ),
    );

    // If something changed → reload from DB
    if (result == true) {
      await loadHabits();
    }
  }

  Future<void> openHabitDetails(Map<String, dynamic> habitMap) async {
    final habit = Habit.fromMap(habitMap);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HabitDetailsPage(habit: habit),
      ),
    );

    await loadHabits();
  }

  // =========================
  // DELETE
  // =========================
  Future<void> deleteHabit(int id) async {
    await repository.deleteHabit(id);
    await loadHabits();
  }

  // =========================
  // BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(icon: Icon(Icons.home), text: 'Home'),
            Tab(icon: Icon(Icons.grid_on), text: 'Heatmap'),
            Tab(icon: Icon(Icons.smart_toy), text: 'AI'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          HomePage(
            habits: habits.map((h) => h.toMap()).toList(),
            onAddHabit: () => openHabitSettings(),
            onHabitPressed: openHabitDetails,
            onDeleteHabit: deleteHabit,
          ),

          const Center(child: Text("Heatmap Page")),
          const Center(child: Text("AI Page")),
        ],
      ),
    );
  }
}