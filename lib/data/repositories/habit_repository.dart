import '../models/habit.dart';
import '../models/habit_occurrence.dart';
import '../models/badge.dart';
import '../database_helper.dart';
import '../../core/constants/enums.dart';
import '../../core/functions/next_Reset.dart';

class HabitRepository {
  final dbHelper = DatabaseHelper.instance;

  // =========================
  // HABITS
  // =========================

  Future<int> createHabit(Habit habit) async {
    return await dbHelper.insertHabit(habit.toMap());
  }

  Future<List<Habit>> getAllHabits() async {
    final result = await dbHelper.getHabits();
    return result.map((map) => Habit.fromMap(map)).toList();
  }

  Future<void> updateHabit(Habit habit) async {
    if (habit.id == null) return;
    await dbHelper.updateHabit(habit.id!, habit.toMap());
  }

  Future<void> deleteHabit(int id) async {
    await dbHelper.deleteHabit(id);
  }

  // =========================
  // OCCURRENCES
  // =========================

  Future<void> markHabitDone(int habitId, String date) async {
    final occurrence = HabitOccurrence(
      habitId: habitId,
      date: date,
      status: HabitStatus.done,
      completedAt: DateTime.now().toIso8601String(),
    );

    await dbHelper.insertOccurrence(occurrence.toMap());
  }

  Future<void> markHabitMissed(int habitId, String date) async {
    final occurrence = HabitOccurrence(
      habitId: habitId,
      date: date,
      status: HabitStatus.missed,
    );

    await dbHelper.insertOccurrence(occurrence.toMap());
  }

  Future<List<HabitOccurrence>> getOccurrences(int habitId) async {
    final result = await dbHelper.getOccurrencesByHabit(habitId);
    return result.map((map) => HabitOccurrence.fromMap(map)).toList();
  }

  Future<bool> isHabitDoneToday(int habitId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final occurrences = await getOccurrences(habitId);

    return occurrences.any(
      (o) => o.date.startsWith(today) && o.status == HabitStatus.done,
    );
  }

  // =========================
  // CURRENT CYCLE LOGIC
  // =========================

  Future<bool> isHabitDoneThisCycle(Habit habit) async {
    if (habit.id == null) return false;

    final occurrences = await getOccurrences(habit.id!);
    final nextResetMillis = calculateNextReset(habit);
    final nextReset = DateTime.fromMillisecondsSinceEpoch(nextResetMillis);
    final lastReset = getLastResetTime(habit, nextReset);

    return occurrences.any((occurrence) {
      if (occurrence.status != HabitStatus.done) return false;

      final occurrenceTime = DateTime.tryParse(occurrence.date);
      if (occurrenceTime == null) return false;

      final isAfterLastReset =
          occurrenceTime.isAfter(lastReset) || occurrenceTime.isAtSameMomentAs(lastReset);
      final isBeforeNextReset = occurrenceTime.isBefore(nextReset);

      return isAfterLastReset && isBeforeNextReset;
    });
  }

  DateTime getLastResetTime(Habit habit, DateTime nextReset) {
    switch (habit.repeatType) {
      case RepeatType.daily:
        return nextReset.subtract(const Duration(days: 1));

      case RepeatType.weekly:
        return nextReset.subtract(const Duration(days: 7));

      case RepeatType.monthly:
        return DateTime(
          nextReset.year,
          nextReset.month - 1,
          nextReset.day,
          nextReset.hour,
          nextReset.minute,
        );

      case RepeatType.yearly:
        return DateTime(
          nextReset.year - 1,
          nextReset.month,
          nextReset.day,
          nextReset.hour,
          nextReset.minute,
        );
    }
  }

  // =========================
  // STREAK LOGIC
  // =========================

  Future<int> getHabitStreak(int habitId) async {
    final logs = await getOccurrences(habitId);

    logs.sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;

    for (var log in logs) {
      if (log.status == HabitStatus.done) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  // =========================
  // BADGES
  // =========================

  Future<void> checkAndAwardBadges(int habitId) async {
    final streak = await getHabitStreak(habitId);

    List<int> milestones = [5, 10, 20];

    for (int milestone in milestones) {
      if (streak >= milestone) {
        final badges = await dbHelper.getBadges(habitId);

        bool alreadyEarned = badges.any(
          (b) => b['milestone'] == milestone,
        );

        if (!alreadyEarned) {
          final badge = Badge(
            habitId: habitId,
            milestone: milestone,
            achievedAt: DateTime.now().toIso8601String(),
          );

          await dbHelper.insertBadge(badge.toMap());
        }
      }
    }
  }

  Future<List<Badge>> getBadges(int habitId) async {
    final result = await dbHelper.getBadges(habitId);
    return result.map((map) => Badge.fromMap(map)).toList();
  }

  // =========================
  // TODAY VIEW (Notification Page)
  // =========================

  Future<List<Map<String, dynamic>>> getTodayHabits() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return await dbHelper.getTodayOccurrences(today);
  }
}