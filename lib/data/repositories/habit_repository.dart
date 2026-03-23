import '../models/habit.dart';
import '../models/habit_occurrence.dart';
import '../models/badge.dart';
import '../database_helper.dart';
import '../../core/constants/enums.dart';

class HabitRepository {
  final dbHelper = DatabaseHelper.instance;

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

  Future<List<HabitOccurrence>> getAllOccurrences() async {
    final result = await dbHelper.getAllOccurrences();
    return result.map((map) => HabitOccurrence.fromMap(map)).toList();
  }

  Future<bool> isHabitDoneToday(int habitId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final occurrences = await getOccurrences(habitId);

    return occurrences.any(
      (o) => o.date.startsWith(today) && o.status == HabitStatus.done,
    );
  }

  Future<bool> isHabitDoneThisCycle(Habit habit) async {
    if (habit.id == null) return false;

    final occurrences = await getOccurrences(habit.id!);

    final nextResetMillis = habit.nextReset;
    if (nextResetMillis <= 0) return false;

    final nextReset = DateTime.fromMillisecondsSinceEpoch(nextResetMillis);
    final lastReset = getLastResetTime(habit, nextReset);

    return occurrences.any((occurrence) {
      if (occurrence.status != HabitStatus.done) return false;

      final occurrenceTime = DateTime.tryParse(occurrence.date);
      if (occurrenceTime == null) return false;

      final isAfterOrAtLastReset =
          occurrenceTime.isAfter(lastReset) ||
          occurrenceTime.isAtSameMomentAs(lastReset);

      final isBeforeNextReset = occurrenceTime.isBefore(nextReset);

      return isAfterOrAtLastReset && isBeforeNextReset;
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

  Future<int> getHabitStreak(int habitId) async {
    final logs = await getOccurrences(habitId);

    logs.sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;

    for (final log in logs) {
      if (log.status == HabitStatus.done) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  Future<void> checkAndAwardBadges(int habitId) async {
    final streak = await getHabitStreak(habitId);

    const List<int> milestones = [5, 10, 20];

    for (final milestone in milestones) {
      if (streak >= milestone) {
        final badges = await dbHelper.getBadges(habitId);

        final alreadyEarned = badges.any(
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

  Future<List<Map<String, dynamic>>> getTodayHabits() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return await dbHelper.getTodayOccurrences(today);
  }
}