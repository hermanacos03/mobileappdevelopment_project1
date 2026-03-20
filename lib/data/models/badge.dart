class Badge {
  final int? id;
  final int habitId;
  final int milestone; // 5, 10, 20...
  final String achievedAt;

  Badge({
    this.id,
    required this.habitId,
    required this.milestone,
    required this.achievedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'milestone': milestone,
      'achieved_at': achievedAt,
    };
  }

  factory Badge.fromMap(Map<String, dynamic> map) {
    return Badge(
      id: map['id'],
      habitId: map['habit_id'],
      milestone: map['milestone'],
      achievedAt: map['achieved_at'],
    );
  }
}