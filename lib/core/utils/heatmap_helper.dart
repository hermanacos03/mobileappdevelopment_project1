import '../../data/models/habit_occurrence.dart';

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