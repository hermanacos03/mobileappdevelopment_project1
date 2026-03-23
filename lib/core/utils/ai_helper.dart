import '../../data/models/habit.dart';

class AiHelper {
  static String generateHabitMessage({
    required Habit habit,
    required int currentStreak,
    required int currentCycleCount,
    required int cycleGoal,
    required bool doneThisCycle,
  }) {
    if (currentStreak >= 30) {
      return "🏆 Elite consistency. You're mastering this habit.";
    } else if (currentStreak >= 14) {
      return "🔥 Amazing work. Two strong weeks in a row.";
    } else if (currentStreak >= 7) {
      return "💪 One full week locked in. Keep the momentum going.";
    } else if (doneThisCycle) {
      return "✅ Great job. You completed this habit for the current cycle.";
    } else if (currentCycleCount == 0) {
      return "🚀 Start this cycle strong. One completion gets the momentum going.";
    } else if (currentCycleCount < cycleGoal) {
      return "📈 You're making progress. Keep pushing toward this cycle's goal.";
    } else {
      return "👍 Keep going. Small, consistent wins build real mastery.";
    }
  }

  static String generateMicroGoal({
    required Habit habit,
    required int currentStreak,
    required int currentCycleCount,
    required int cycleGoal,
    required bool doneThisCycle,
  }) {
    final habitName = habit.name;

    if (doneThisCycle) {
      return "Today's micro-goal: protect your momentum and be ready for the next reset.";
    } else if (currentStreak >= 14) {
      return "Today's micro-goal: complete $habitName and extend your high-level streak.";
    } else if (currentStreak >= 7) {
      return "Today's micro-goal: finish $habitName and push toward two full weeks.";
    } else if (currentCycleCount == 0) {
      return "Today's micro-goal: complete $habitName once this cycle.";
    } else if (currentCycleCount < cycleGoal) {
      return "Today's micro-goal: get ${cycleGoal - currentCycleCount} more step(s) toward your cycle goal.";
    } else {
      return "Today's micro-goal: maintain your consistency.";
    }
  }

  static String generateStatusLabel({
    required int currentStreak,
    required int currentCycleCount,
    required int cycleGoal,
    required bool doneThisCycle,
  }) {
    if (currentStreak >= 30) return 'Master';
    if (currentStreak >= 14) return 'Elite';
    if (currentStreak >= 7) return 'Hot Streak';
    if (doneThisCycle) return 'Cycle Cleared';
    if (currentCycleCount > 0) return 'In Progress';
    return 'Starting Out';
  }
}