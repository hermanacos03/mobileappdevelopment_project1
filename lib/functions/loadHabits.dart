import '../database_helper.dart';

Future<List<Map<String, dynamic>>> loadHabitsFromDatabase() async {
  final savedHabits = await DatabaseHelper.instance.getHabits();

  final habitList = List<Map<String, dynamic>>.from(savedHabits);

  habitList.sort((a, b) {
    final nameA = (a['name'] ?? '').toString();
    final nameB = (b['name'] ?? '').toString();
    return nameB.length.compareTo(nameA.length);
  });

  return habitList;
}