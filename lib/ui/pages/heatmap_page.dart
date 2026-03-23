import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

import '../../data/repositories/habit_repository.dart';
import '../../data/models/habit_occurrence.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Habit Heatmap"),
      ),
      body: SingleChildScrollView(
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
      )
    );
  }
}