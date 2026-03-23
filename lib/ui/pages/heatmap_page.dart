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
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];

    return '${months[month - 1]} $year';
  }

  DateTime getMonthStart(String key) {
    final parts = key.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
  }

  DateTime getMonthEnd(String key) {
    final parts = key.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]) + 1, 0);
  }

  Map<DateTime, int> getSelectedMonthData() {
    if (selectedMonthKey == null) return {};

    return {
      for (final e in heatmapData.entries)
        if (monthKeyFromDate(e.key) == selectedMonthKey!) e.key: e.value
    };
  }

  Color getDayColor(int c) {
    if (c <= 0) return Colors.grey[900]!;
    if (c == 1) return Colors.green[300]!;
    if (c == 2) return Colors.green[500]!;
    if (c == 3) return Colors.green[700]!;
    return Colors.green[900]!;
  }

  List<Widget> buildCalendarCells() {
    if (selectedMonthKey == null) return [];

    final data = getSelectedMonthData();
    final start = getMonthStart(selectedMonthKey!);
    final end = getMonthEnd(selectedMonthKey!);

    final leading = start.weekday % 7;
    final days = end.day;

    final cells = <Widget>[];

    for (int i = 0; i < leading; i++) {
      cells.add(const SizedBox());
    }

    for (int d = 1; d <= days; d++) {
      final date = DateTime(start.year, start.month, d);
      final val = data[date] ?? 0;

      cells.add(
        Container(
          decoration: BoxDecoration(
            color: getDayColor(val),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }

    return cells;
  }

  @override
  Widget build(BuildContext context) {
    final months = getAvailableMonthKeysFromData(heatmapData);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Habit Heatmap'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (months.isNotEmpty)
            DropdownButton<String>(
              value: selectedMonthKey,
              dropdownColor: Colors.grey[900],
              items: months.map((m) {
                return DropdownMenuItem(
                  value: m,
                  child: Text(formatMonthLabel(m),
                      style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (v) => setState(() => selectedMonthKey = v),
            ),

          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: buildCalendarCells(),
          ),

          const SizedBox(height: 20),

          FutureBuilder<Habit?>(
            future: loadNextHabit(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();

              final habit = snapshot.data!;
              final nextTime = getNextHabitDateTime(habit);

              return ListTile(
                title: Text(habit.name,
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                  'In ${nextTime.difference(DateTime.now()).inHours} hours',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                trailing: const Icon(Icons.arrow_forward, color: Colors.white),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HabitDetailsPage(habit: habit),
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