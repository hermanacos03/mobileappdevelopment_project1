import '../data/models/habit.dart';
import '../core/constants/enums.dart';

int calculateNextReset(Habit habit) {
  final now = DateTime.now();

  int hour = 0;
  int minute = 0;

  // Parse timeOfDay (HHMM)
  if (habit.timeOfDay.length == 4) {
    hour = int.tryParse(habit.timeOfDay.substring(0, 2)) ?? 0;
    minute = int.tryParse(habit.timeOfDay.substring(2, 4)) ?? 0;
  }

  DateTime nextReset;

  switch (habit.repeatType) {
    case RepeatType.daily:
      nextReset = DateTime(now.year, now.month, now.day, hour, minute);
      if (!nextReset.isAfter(now)) {
        nextReset = nextReset.add(const Duration(days: 1));
      }
      break;

    case RepeatType.weekly:
      // dayOfWeek: 0 = Monday, 6 = Sunday
      int targetWeekday = habit.dayOfWeek ?? now.weekday - 1;
      // Convert to Dart weekday (1 = Monday)
      int dartWeekday = targetWeekday + 1;

      // Find next occurrence of that weekday
      nextReset = DateTime(now.year, now.month, now.day, hour, minute);
      int diffDays = (dartWeekday - now.weekday + 7) % 7;
      if (diffDays == 0 && !nextReset.isAfter(now)) diffDays = 7;
      nextReset = nextReset.add(Duration(days: diffDays));
      break;

    case RepeatType.monthly:
      int targetDay = habit.dayOfMonth ?? now.day;
      nextReset = DateTime(now.year, now.month, targetDay, hour, minute);

      if (!nextReset.isAfter(now)) {
        // Move to next month
        int nextMonth = now.month + 1;
        int nextYear = now.year;
        if (nextMonth > 12) {
          nextMonth = 1;
          nextYear += 1;
        }
        nextReset = DateTime(nextYear, nextMonth, targetDay, hour, minute);
      }
      break;

    case RepeatType.yearly:
      int targetMonth = habit.month ?? now.month;
      int targetDay = habit.dayOfMonth ?? now.day;
      nextReset = DateTime(now.year, targetMonth, targetDay, hour, minute);

      if (!nextReset.isAfter(now)) {
        // Move to next year
        nextReset = DateTime(now.year + 1, targetMonth, targetDay, hour, minute);
      }
      break;
  }

  return nextReset.millisecondsSinceEpoch;
}