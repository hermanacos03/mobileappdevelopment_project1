import 'package:flutter/material.dart';

import '../../data/repositories/habit_repository.dart';
import '../../data/models/habit.dart';
import '../../core/utils/heatmap_helper.dart';
import 'habit_details_page.dart';

class HeatmapScreen extends StatefulWidget {
  const HeatmapScreen({super.key});

  @override
  State<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> {
  final repo = HabitRepository();

  Map<DateTime, int> heatmapData = {};
  String? selectedMonthKey;

  @override
  void initState() {
    super.initState();
    loadHeatmap();
  }

  Future<void> loadHeatmap() async {
    final occurrences = await repo.getAllOccurrences();
    final builtData = buildHeatmapData(occurrences);

    final availableMonths = getAvailableMonthKeysFromData(builtData);
    final currentMonth = monthKeyFromDate(DateTime.now());

    setState(() {
      heatmapData = builtData;

      if (availableMonths.contains(currentMonth)) {
        selectedMonthKey = currentMonth;
      } else if (availableMonths.isNotEmpty) {
        selectedMonthKey = availableMonths.first;
      } else {
        selectedMonthKey = currentMonth;
      }
    });
  }

  Future<Habit?> loadNextHabit() async {
    final habits = await repo.getAllHabits();
    return findNextHabitFromReset(habits);
  }

  String monthKeyFromDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  List<String> getAvailableMonthKeysFromData(Map<DateTime, int> data) {
    final keys = data.keys.map((date) => monthKeyFromDate(date)).toSet().toList();
    keys.sort((a, b) => b.compareTo(a));
    return keys;
  }

  String formatMonthLabel(String monthKey) {
    final parts = monthKey.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[month - 1]} $year';
  }

  DateTime getMonthStart(String monthKey) {
    final parts = monthKey.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    return DateTime(year, month, 1);
  }

  DateTime getMonthEnd(String monthKey) {
    final parts = monthKey.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    return DateTime(year, month + 1, 0);
  }

  Map<DateTime, int> getSelectedMonthHeatmapData() {
    if (selectedMonthKey == null) return {};

    final Map<DateTime, int> filtered = {};

    for (final entry in heatmapData.entries) {
      if (monthKeyFromDate(entry.key) == selectedMonthKey) {
        filtered[entry.key] = entry.value;
      }
    }

    return filtered;
  }

  List<MapEntry<DateTime, int>> getSelectedMonthEntries() {
    final entries = getSelectedMonthHeatmapData().entries.toList();
    entries.sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  String formatDateLabel(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  int getLongestStreakForEntries(List<MapEntry<DateTime, int>> entries) {
    if (entries.isEmpty) return 0;

    int longest = 1;
    int current = 1;

    for (int i = 1; i < entries.length; i++) {
      final previous = entries[i - 1].key;
      final currentDate = entries[i].key;

      if (currentDate.difference(previous).inDays == 1) {
        current++;
      } else {
        current = 1;
      }

      if (current > longest) {
        longest = current;
      }
    }

    return longest;
  }

  int getCurrentStreakForEntries(List<MapEntry<DateTime, int>> entries) {
    if (entries.isEmpty) return 0;

    int streak = 1;

    for (int i = entries.length - 1; i > 0; i--) {
      final currentDate = entries[i].key;
      final previousDate = entries[i - 1].key;

      if (currentDate.difference(previousDate).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  int getTotalCompletionsForEntries(List<MapEntry<DateTime, int>> entries) {
    int total = 0;
    for (final entry in entries) {
      total += entry.value;
    }
    return total;
  }

  Color getDayColor(int completions) {
    if (completions <= 0) return Colors.grey[900]!;
    if (completions == 1) return Colors.green[300]!;
    if (completions == 2) return Colors.green[500]!;
    if (completions == 3) return Colors.green[700]!;
    return Colors.green[900]!;
  }

  List<Widget> buildCalendarCells() {
    if (selectedMonthKey == null) return [];

    final monthData = getSelectedMonthHeatmapData();
    final monthStart = getMonthStart(selectedMonthKey!);
    final monthEnd = getMonthEnd(selectedMonthKey!);
    final int daysInMonth = monthEnd.day;

    final int leadingBlankDays = monthStart.weekday % 7;

    final List<Widget> cells = [];

    for (int i = 0; i < leadingBlankDays; i++) {
      cells.add(const SizedBox.shrink());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(monthStart.year, monthStart.month, day);
      final completions = monthData[date] ?? 0;
      final isToday = DateUtils.isSameDay(date, DateTime.now());

      cells.add(
        Container(
          decoration: BoxDecoration(
            color: getDayColor(completions),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isToday ? Colors.white : Colors.grey[800]!,
              width: isToday ? 2.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              '$day',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    while (cells.length % 7 != 0) {
      cells.add(const SizedBox.shrink());
    }

    return cells;
  }

  @override
  Widget build(BuildContext context) {
    final availableMonths = getAvailableMonthKeysFromData(heatmapData);
    final selectedMonthEntries = getSelectedMonthEntries();

    final totalActiveDays = selectedMonthEntries.length;
    final totalCompletions = getTotalCompletionsForEntries(selectedMonthEntries);
    final longestStreak = getLongestStreakForEntries(selectedMonthEntries);
    final currentStreak = getCurrentStreakForEntries(selectedMonthEntries);

    const weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Habit Heatmap'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Monthly Calendar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (availableMonths.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: const Text(
                'No completed habit data yet.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            )
          else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedMonthKey,
                  dropdownColor: Colors.grey[900],
                  iconEnabledColor: Colors.white,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  isExpanded: true,
                  items: availableMonths.map((monthKey) {
                    return DropdownMenuItem<String>(
                      value: monthKey,
                      child: Text(
                        formatMonthLabel(monthKey),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedMonthKey = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[950],
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatMonthLabel(selectedMonthKey!),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: weekdays
                        .map(
                          (day) => Expanded(
                            child: Center(
                              child: Text(
                                day,
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  GridView.count(
                    crossAxisCount: 7,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.82,
                    children: buildCalendarCells(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatMonthLabel(selectedMonthKey!),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Active days: $totalActiveDays',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Total completions: $totalCompletions',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Longest streak this month: $longestStreak day${longestStreak == 1 ? '' : 's'}',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Current streak in this month: $currentStreak day${currentStreak == 1 ? '' : 's'}',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (selectedMonthEntries.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: const Text(
                  'No completed days in this month.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              )
            else
              ...selectedMonthEntries.map(
                (entry) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey[800]!),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[700],
                      child: Text(
                        '${entry.key.day}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      formatDateLabel(entry.key),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${entry.value} completion${entry.value == 1 ? '' : 's'}',
                      style: TextStyle(
                        color: Colors.grey[300],
                      ),
                    ),
                    trailing: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 20),
          FutureBuilder<Habit?>(
            future: loadNextHabit(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();

              final habit = snapshot.data!;
              final nextTime = getNextHabitDateTime(habit);
              final hoursUntil = nextTime.difference(DateTime.now()).inHours;

              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HabitDetailsPage(habit: habit),
                    ),
                  );
                },
                child: Card(
                  color: Colors.grey[900],
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(color: Colors.grey[800]!),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Next Up',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                habit.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'In $hoursUntil hours',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HabitDetailsPage(habit: habit),
                                ),
                              );
                            },
                            child: const Text('View Details'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}