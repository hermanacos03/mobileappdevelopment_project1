import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/habit.dart';
import '../../data/models/badge.dart' as models;
import '../../data/repositories/habit_repository.dart';
import '../../core/functions/next_Reset.dart';
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
  List<models.Badge> badges = [];

  late int currentCycleCount;
  late int cycleGoal;
  late bool doneThisCycle;
  late int nextResetMillis;

  Timer? countdownTimer;

  @override
  void initState() {
    super.initState();

    currentCycleCount = widget.habit.frequencyCounter;
    cycleGoal = widget.habit.habitFrequency;
    doneThisCycle = currentCycleCount >= cycleGoal;
    nextResetMillis = calculateNextReset(widget.habit);

    loadHabitDetails();
    setupNextReset();
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> loadHabitDetails() async {
    final streak = await repository.getHabitStreak(widget.habit.id!);
    final badgeList = await repository.getBadges(widget.habit.id!);

    if (!mounted) return;

    setState(() {
      currentStreak = streak;
      badges = badgeList;
    });
  }

  void setupNextReset() {
    countdownTimer?.cancel();

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      final now = DateTime.now().millisecondsSinceEpoch;

      if (now >= nextResetMillis) {
        setState(() {
          currentCycleCount = 0;
          doneThisCycle = false;
          nextResetMillis = calculateNextReset(widget.habit);
        });
      } else {
        setState(() {});
      }
    });
  }

  Future<void> markDoneOnce() async {
    final now = DateTime.now().toIso8601String();

    await repository.markHabitDone(widget.habit.id!, now);
    await repository.checkAndAwardBadges(widget.habit.id!);

    if (!mounted) return;

    setState(() {
      currentCycleCount = currentCycleCount + 1;
      doneThisCycle = currentCycleCount >= cycleGoal;
    });

    await loadHabitDetails();

    Navigator.pop(context, true);
  }

  String get countdown {
    final now = DateTime.now();
    final diff =
        DateTime.fromMillisecondsSinceEpoch(nextResetMillis).difference(now);

    if (diff.isNegative) return "00:00:00";

    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
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
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HabitSettingsPage(habit: widget.habit),
                ),
              );

              if (updated != null) {
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
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
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
            const SizedBox(height: 16),
            Text(
              'Progress This Cycle: $currentCycleCount / $cycleGoal',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text(
              'Badges',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            badges.isEmpty
                ? const Text('No badges earned yet')
                : Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children:
                        badges.map((b) => StreakBadge(badge: b)).toList(),
                  ),
            const SizedBox(height: 24),
            Text(
              'Next Reset: $countdown',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            doneThisCycle
                ? const Text(
                    'Habit completed for this cycle',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  )
                : ElevatedButton(
                    onPressed: markDoneOnce,
                    child: const Text('Done Once'),
                  ),
          ],
        ),
      ),
    );
  }
}