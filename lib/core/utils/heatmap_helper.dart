import '../../data/models/habit_occurrence.dart';
import '../../data/models/habit.dart';
import '../functions/next_Reset.dart';

Map<DateTime, int> buildHeatmapData(List<HabitOccurrence> occurrences) {
  final Map<DateTime, int> data = {};

  for (var occ in occurrences) {
    // Only count completed habits
    if (occ.status.name != 'done') continue;

    final parsedDate = DateTime.parse(occ.date);

    // Normalize to remove time (VERY IMPORTANT)
    final date = DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
    );

    // Count how many habits completed per day
    data.update(date, (value) => value + 1, ifAbsent: () => 1);
  }

  return data;
}

Habit? findNextHabitFromReset(List<Habit> habits) {
  Habit? closestHabit;
  int? closestTime;

  final now = DateTime.now().millisecondsSinceEpoch;

  for (var habit in habits) {
    final nextReset = calculateNextReset(habit);
    if (closestTime == null || nextReset < closestTime) {
      closestTime = nextReset;
      closestHabit = habit;
    }
  }

  return closestHabit;
}

// Get the DateTime of a habit's next reset
DateTime getNextHabitDateTime(Habit habit) {
  return DateTime.fromMillisecondsSinceEpoch(calculateNextReset(habit));
}