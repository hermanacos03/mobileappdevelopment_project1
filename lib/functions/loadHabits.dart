import '../database_helper.dart';

Future<List<String>> loadHabitsFromDatabase() async {
  final savedHabits = await DatabaseHelper.instance.getHabits();

  final habitList =
      savedHabits.map((habit) => habit['name'] as String).toList();

  habitList.sort((a, b) => b.length.compareTo(a.length));

  return habitList;
}