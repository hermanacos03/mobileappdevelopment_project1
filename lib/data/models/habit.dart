import '../../core/constants/enums.dart';

class Habit {
  final int? id;
  final String name;
  final String? description;

  final RepeatType repeatType;

  final int? dayOfWeek;
  final int? dayOfMonth;
  final int? month;

  final String timeOfDay;
  final String createdAt;

  Habit({
    this.id,
    required this.name,
    this.description,
    required this.repeatType,
    this.dayOfWeek,
    this.dayOfMonth,
    this.month,
    required this.timeOfDay,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'repeat_type': repeatType.name,
      'day_of_week': dayOfWeek,
      'day_of_month': dayOfMonth,
      'month': month,
      'time_of_day': timeOfDay,
      'created_at': createdAt,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      repeatType: RepeatType.values.firstWhere(
        (e) => e.name == map['repeat_type'],
      ),
      dayOfWeek: map['day_of_week'],
      dayOfMonth: map['day_of_month'],
      month: map['month'],
      timeOfDay: map['time_of_day'],
      createdAt: map['created_at'],
    );
  }
}