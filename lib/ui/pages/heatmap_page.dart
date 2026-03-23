import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

import '../../data/repositories/habit_repository.dart';
import '../../data/models/habit.dart';

import 'habit_details_page.dart';

import '../../core/utils/heatmap_helper.dart';

class HeatmapScreen extends StatefulWidget {
  const HeatmapScreen({super.key});

  @override
  State<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> {
  final repo = HabitRepository();

  Map<DateTime, int> heatmapData = {};

  @override
  void initState() {
    super.initState();
    loadHeatmap();
  }

  Future<void> loadHeatmap() async {
    final occurrences = await repo.getAllOccurrences();

    heatmapData = buildHeatmapData(occurrences);

    setState(() {});
  }

  Future<Habit?> loadNextHabit() async {
    final habits = await repo.getAllHabits();
    return findNextHabitFromReset(habits);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Habit Heatmap"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: HeatMap(
              startDate: DateTime.now().subtract(const Duration(days: 90)),
              endDate: DateTime.now(),
              datasets: heatmapData,
              colorMode: ColorMode.color,
              defaultColor: Colors.grey[200]!,
              textColor: Colors.black,
              showColorTip: false,
              colorsets: {
                1: Colors.green[200]!,
                2: Colors.green[400]!,
                3: Colors.green[600]!,
                4: Colors.green[800]!,
              },
            ),
          ),

          const SizedBox(height: 16),

          FutureBuilder<Habit?>(
            future: loadNextHabit(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();

              final habit = snapshot.data!;
              final nextTime = getNextHabitDateTime(habit);

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HabitDetailsPage(habit: habit),
                    ),
                  );
                },
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Next Up",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (nextTime != null)
                          Text(
                            "In ${nextTime.difference(DateTime.now()).inHours} hours",
                            style: TextStyle(color: Colors.grey[600]),
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
                            child: const Text("View Details"),
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
      )
    );
  }
}