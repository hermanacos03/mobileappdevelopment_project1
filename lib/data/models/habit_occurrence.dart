class HabitOccurrence {
  final int? id;
  final int habitId;          // Foreign key to Habit
  final String date;          // "2024-03-18" (YYYY-MM-DD)
  final String status;        // "pending", "done", "missed"
  final String? completedAt;  // timestamp when user marked it done

  HabitOccurrence({
    this.id,
    required this.habitId,
    required this.date,
    this.status = "pending",
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'date': date,
      'status': status,
      'completed_at': completedAt,
    };
  }

  factory HabitOccurrence.fromMap(Map<String, dynamic> map) {
    return HabitOccurrence(
      id: map['id'],
      habitId: map['habit_id'],
      date: map['date'],
      status: map['status'],
      completedAt: map['completed_at'],
    );
  }
}
