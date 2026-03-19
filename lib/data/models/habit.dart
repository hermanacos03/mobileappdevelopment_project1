class Habit {
  final int? id;
  final String name;
  final String? description;

  // Repeat type: weekly, monthly, yearly
  final String repeatType;

  // Weekly
  final int? dayOfWeek;     // 0 = Monday, 6 = Sunday

  // Monthly / Yearly
  final int? dayOfMonth;    // 1–31

  // Yearly only
  final int? month;         // 1–12

  // Time of day
  final String timeOfDay;   // "17:00"

  final int streak;
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
    this.streak = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'repeat_type': repeatType,
      'day_of_week': dayOfWeek,
      'day_of_month': dayOfMonth,
      'month': month,
      'time_of_day': timeOfDay,
      'streak': streak,
      'created_at': createdAt,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      repeatType: map['repeat_type'],
      dayOfWeek: map['day_of_week'],
      dayOfMonth: map['day_of_month'],
      month: map['month'],
      timeOfDay: map['time_of_day'],
      streak: map['streak'],
      createdAt: map['created_at'],
    );
  }
}
