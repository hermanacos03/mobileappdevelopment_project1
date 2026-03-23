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

  // cycle-based fields
  final int habitFrequency;
  final int frequencyCounter;
  final int nextReset;

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
    required this.habitFrequency,
    required this.frequencyCounter,
    required this.nextReset,
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
      'habit_frequency': habitFrequency,
      'frequency_counter': frequencyCounter,
      'next_reset': nextReset,
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
      habitFrequency: map['habit_frequency'] ?? 1,
      frequencyCounter: map['frequency_counter'] ?? 0,
      nextReset: map['next_reset'] ?? 0,
    );
  }

  Habit copyWith({
    int? id,
    String? name,
    String? description,
    RepeatType? repeatType,
    int? dayOfWeek,
    int? dayOfMonth,
    int? month,
    String? timeOfDay,
    String? createdAt,
    int? habitFrequency,
    int? frequencyCounter,
    int? nextReset,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      repeatType: repeatType ?? this.repeatType,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      month: month ?? this.month,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      createdAt: createdAt ?? this.createdAt,
      habitFrequency: habitFrequency ?? this.habitFrequency,
      frequencyCounter: frequencyCounter ?? this.frequencyCounter,
      nextReset: nextReset ?? this.nextReset,
    );
  }
}