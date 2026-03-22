int calculateNextReset(String timeValue) {
  final now = DateTime.now();

  if (timeValue.length != 4) {
    return 0;
  }

  final hour = int.parse(timeValue.substring(0, 2));
  final minute = int.parse(timeValue.substring(2, 4));

  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
    return 0;
  }

  DateTime nextReset = DateTime(
    now.year,
    now.month,
    now.day,
    hour,
    minute,
  );

  if (!nextReset.isAfter(now)) {
    nextReset = nextReset.add(const Duration(days: 1));
  }

  return nextReset.millisecondsSinceEpoch;
}