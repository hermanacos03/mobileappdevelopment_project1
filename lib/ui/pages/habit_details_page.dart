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

  late Habit currentHabit;

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

    currentHabit = widget.habit;
    currentCycleCount = currentHabit.frequencyCounter;
    cycleGoal = currentHabit.habitFrequency;
    doneThisCycle = currentCycleCount >= cycleGoal;

    // use saved DB-backed value first
    nextResetMillis = currentHabit.nextReset;

    // fallback only if missing/invalid
    if (nextResetMillis <= 0) {
      nextResetMillis = calculateNextReset(currentHabit);
    }

    loadHabitDetails();
    setupNextReset();
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> loadHabitDetails() async {
    if (currentHabit.id == null) return;

    final allHabits = await repository.getAllHabits();
    final matchingHabits = allHabits.where((h) => h.id == currentHabit.id);

    if (matchingHabits.isNotEmpty) {
      currentHabit = matchingHabits.first;
    }

    final streak = await repository.getHabitStreak(currentHabit.id!);
    final badgeList = await repository.getBadges(currentHabit.id!);
    final cycleDone = await repository.isHabitDoneThisCycle(currentHabit);

    if (!mounted) return;

    setState(() {
      currentStreak = streak;
      badges = badgeList;
      currentCycleCount = currentHabit.frequencyCounter;
      cycleGoal = currentHabit.habitFrequency;
      nextResetMillis = currentHabit.nextReset;
      doneThisCycle = cycleDone || currentCycleCount >= cycleGoal;
    });
  }

  void setupNextReset() {
    countdownTimer?.cancel();

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!mounted) return;

      final now = DateTime.now().millisecondsSinceEpoch;

      if (now >= nextResetMillis) {
        final newReset = calculateNextReset(currentHabit);

        final resetHabit = Habit(
          id: currentHabit.id,
          name: currentHabit.name,
          description: currentHabit.description,
          repeatType: currentHabit.repeatType,
          dayOfWeek: currentHabit.dayOfWeek,
          dayOfMonth: currentHabit.dayOfMonth,
          month: currentHabit.month,
          timeOfDay: currentHabit.timeOfDay,
          createdAt: currentHabit.createdAt,
          habitFrequency: currentHabit.habitFrequency,
          frequencyCounter: 0,
          nextReset: newReset,
        );

        await repository.updateHabit(resetHabit);
        currentHabit = resetHabit;

        if (!mounted) return;

        setState(() {
          currentCycleCount = 0;
          doneThisCycle = false;
          nextResetMillis = newReset;
        });
      } else {
        setState(() {});
      }
    });
  }

  Future<void> markDoneOnce() async {
    if (currentHabit.id == null) return;
    if (doneThisCycle) return;

    final nowIso = DateTime.now().toIso8601String();

    final newCount = currentCycleCount + 1;
    final reachedGoal = newCount >= cycleGoal;

    final updatedHabit = Habit(
      id: currentHabit.id,
      name: currentHabit.name,
      description: currentHabit.description,
      repeatType: currentHabit.repeatType,
      dayOfWeek: currentHabit.dayOfWeek,
      dayOfMonth: currentHabit.dayOfMonth,
      month: currentHabit.month,
      timeOfDay: currentHabit.timeOfDay,
      createdAt: currentHabit.createdAt,
      habitFrequency: currentHabit.habitFrequency,
      frequencyCounter: newCount,
      nextReset: currentHabit.nextReset,
    );

    await repository.markHabitDone(currentHabit.id!, nowIso);
    await repository.updateHabit(updatedHabit);
    await repository.checkAndAwardBadges(currentHabit.id!);

    currentHabit = updatedHabit;

    if (!mounted) return;

    setState(() {
      currentCycleCount = newCount;
      doneThisCycle = reachedGoal;
    });

    await loadHabitDetails();

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  String get countdown {
    final now = DateTime.now();
    final diff =
        DateTime.fromMillisecondsSinceEpoch(nextResetMillis).difference(now);

    if (diff.isNegative) return '00:00:00';

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
        title: Text(currentHabit.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HabitSettingsPage(habit: currentHabit),
                ),
              );

              if (updated == true) {
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
              currentHabit.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              currentHabit.description ?? 'No description',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              'Repeats: ${currentHabit.repeatType.name}',
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