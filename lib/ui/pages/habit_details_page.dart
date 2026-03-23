import 'package:flutter/material.dart';
import '../../data/models/habit.dart';
import '../../data/models/badge.dart' as models;
import '../../data/repositories/habit_repository.dart';

import 'habit_settings_page.dart';
import '../widgets/streak_badge.dart';

class HabitDetailsPage extends StatefulWidget {
  final Habit habit;

  const HabitDetailsPage({super.key, required this.habit});

  @override
  State<HabitDetailsPage> createState() => _HabitDetailsPageState();
}

class _HabitDetailsPageState extends State<HabitDetailsPage> {
  final HabitRepository repository = HabitRepository();

  int currentStreak = 0;
  int bestStreak = 0;
  List<models.Badge> badges = [];

  @override
  void initState() {
    super.initState();
    loadHabitDetails();
  }

  Future<void> loadHabitDetails() async {
    final streak = await repository.getHabitStreak(widget.habit.id!);
    final badgeList = await repository.getBadges(widget.habit.id!);

    setState(() {
      currentStreak = streak;
      bestStreak = streak; // For now, assume best streak = current streak
      badges = badgeList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // Navigate to HabitSettingsPage for editing
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HabitSettingsPage(habit: widget.habit),
                ),
              );

              if (updated != null) {
                // Refresh habit details after edit
                await loadHabitDetails();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              widget.habit.name,
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              widget.habit.description ?? 'No description',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              'Repeats: ${widget.habit.repeatType.name}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              'Current Streak: $currentStreak',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Best Streak: $bestStreak',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text(
              'Badges',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            badges.isEmpty
                ? const Text('No badges earned yet')
                : Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: badges
                        .map((b) => StreakBadge(badge: b))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }
}