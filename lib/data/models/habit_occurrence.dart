import '../../core/constants/enums.dart';

class HabitOccurrence {
  final int? id;
  final int habitId;
  final String date;
  final HabitStatus status;
  final String? completedAt;

  HabitOccurrence({
    this.id,
    required this.habitId,
    required this.date,
    this.status = HabitStatus.pending,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'date': date,
      'status': status.name,
      'completed_at': completedAt,
    };
  }

  factory HabitOccurrence.fromMap(Map<String, dynamic> map) {
    return HabitOccurrence(
      id: map['id'],
      habitId: map['habit_id'],
      date: map['date'],
      status: HabitStatus.values.firstWhere(
        (e) => e.name == map['status'],
      ),
      completedAt: map['completed_at'],
    );
  }
}