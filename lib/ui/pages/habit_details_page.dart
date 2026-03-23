import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/habit.dart';
import '../../data/models/badge.dart' as models;
import '../../data/repositories/habit_repository.dart';
import '../../data/database_helper.dart';
import '../../core/functions/next_Reset.dart';
import '../../core/utils/ai_helper.dart';
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

    nextResetMillis = currentHabit.nextReset;

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

        await loadHabitDetails();
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          doneThisCycle
              ? 'Habit completed for this cycle.'
              : 'Progress saved for today.',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> seedTestStreak(int days) async {
    if (currentHabit.id == null) return;

    await DatabaseHelper.instance.seedTestStreakDirect(
      habitId: currentHabit.id!,
      streakDays: days,
    );

    await loadHabitDetails();
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

  Widget buildAiBox() {
    final mainMessage = AiHelper.generateHabitMessage(
      habit: currentHabit,
      currentStreak: currentStreak,
      currentCycleCount: currentCycleCount,
      cycleGoal: cycleGoal,
      doneThisCycle: doneThisCycle,
    );

    final microGoal = AiHelper.generateMicroGoal(
      habit: currentHabit,
      currentStreak: currentStreak,
      currentCycleCount: currentCycleCount,
      cycleGoal: cycleGoal,
      doneThisCycle: doneThisCycle,
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8, bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.green, width: 1.4),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.green,
            child: Icon(Icons.smart_toy, color: Colors.black),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Habit Buddy',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  mainMessage,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  microGoal,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCompletionMessage() {
    if (!doneThisCycle) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green),
      ),
      child: const Text(
        'Habit completed for this cycle. Streak reached for today.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.green,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(currentHabit.name),
        backgroundColor: Colors.black,
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            currentHabit.description ?? '',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            'Streak: $currentStreak',
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            'Cycle: $currentCycleCount / $cycleGoal',
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            'Reset In: $countdown',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          buildAiBox(),
          buildCompletionMessage(),
          if (badges.isNotEmpty) ...[
            const Text(
              'Badges',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: badges.map((b) => StreakBadge(badge: b)).toList(),
            ),
            const SizedBox(height: 20),
          ],
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => seedTestStreak(7),
                  child: const Text('7d'),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => seedTestStreak(14),
                  child: const Text('14d'),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => seedTestStreak(30),
                  child: const Text('30d'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          doneThisCycle
              ? ElevatedButton(
                  onPressed: null,
                  child: const Text('Done Once'),
                )
              : ElevatedButton(
                  onPressed: markDoneOnce,
                  child: const Text('Done Once'),
                ),
        ],
      ),
    );
  }
}