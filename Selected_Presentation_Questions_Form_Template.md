# Selected Presentation Questions Form

## Course Information
- Course Name: Mobile App Development
- Course Section: 4
- Instructor: Prof Louis Henry
- Semester/Term: Spring 2026

## Team Information
- Group Name: RedHotTurkeys
- App/Project Title: Habit Mastery League
- Presentation Date: 2026 Mar 23

### Team Members
1. Herman Acosta
2. Hien Dao

## Selected Questions (Choose 10–15)

Use this section to list the specific Project1Q&A questions your team selected for presentation.

1. Question: What are the key advantages of using Flutter for this cross-platform project?
   - Category: Customizable UI, with clear widget tree; hot reload; can deploy on differne platform
   - Team Member Responsible: Hien Dao
   - Evidence to Show (code file/commit/UI/screenshot):

2. Question: Which state management technique did you choose (setState, Provider, Riverpod, BLoC) and why?
   - Category: We chose setState for state management because our app is relatively small and most of the state is handled within individual pages. It allowed us to update the UI quickly and simply without adding the complexity of more advanced solutions like Provider or BLoC.
   - Team Member Responsible: Herman Acosta
   - Evidence to Show (code file/commit/UI/screenshot):

3. Question: Describe one state-flow interaction from user action to UI update in your app.
   - Category: When the user presses the “Done Once” button, the app updates the habit’s completion status and calls setState() to change the button’s state. This causes the button to immediately turn green, visually confirming that the habit was completed for the day.
   - Team Member Responsible: Herman Acosta
   - Evidence to Show (code file/commit/UI/screenshot):

4. Question: What state-related challenge did you face, and what fix improved reliability?
   - Category: Habit Details Page did not update after Done Once Button was pushed. We must make sure that both the page and the database is updated once the button is pushed
   - Team Member Responsible: Hien Dao
   - Evidence to Show (code file/commit/UI/screenshot): habit_details_pages line 131
```
   Future<void> markDoneOnce() async {
    if (currentHabit.id == null) return;
    if (doneThisCycle) return;

    final nowIso = DateTime.now().toIso8601String();

    final newCount = currentCycleCount + 1;
    final reachedGoal = newCount >= cycleGoal;

    final updatedHabit = Habit(
      id: currentHabit.id,
      name: currentHabit.name,
      description: currentHabit.description,
      repeatType: currentHabit.repeatType,
      dayOfWeek: currentHabit.dayOfWeek,
      dayOfMonth: currentHabit.dayOfMonth,
      month: currentHabit.month,
      timeOfDay: currentHabit.timeOfDay,
      createdAt: currentHabit.createdAt,
      habitFrequency: currentHabit.habitFrequency,
      frequencyCounter: newCount,
      nextReset: currentHabit.nextReset,
    );
```

5. Question: How did you make the interface intuitive and responsive across device sizes/orientations?
   - Category: We designed the UI with flexible Flutter layout widgets like Expanded, SizedBox, Column, and Row so elements adjust naturally to different screen sizes and orientations. We also kept the navigation and buttons visually clear and consistent, so the app stays easy to use whether it is opened on a smaller phone screen or a wider display.
   - Team Member Responsible: Herman Acosta
   - Evidence to Show (code file/commit/UI/screenshot):

6. Question: What usability improvement did you make after testing feedback?
   - Category: We improved usability by adding a visual confirmation where the “Done Once” button turns green after being pressed, so users immediately know their action was successful. This change came from feedback that it was unclear whether a habit was actually marked complete.
   - Team Member Responsible: Herman Acosta
   - Evidence to Show (code file/commit/UI/screenshot):

7. Question: Explain your local data structure (tables/columns/keys or preference groups).
   - Category: There are 3 tables (habit, habit_occurence, and badge)
   - Team Member Responsible: Hien Dao
   - Evidence to Show (code file/commit/UI/screenshot): models/
```sql
CREATE TABLE habits (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  repeat_type TEXT NOT NULL,
  day_of_week INTEGER,
  day_of_month INTEGER,
  month INTEGER,
  time_of_day TEXT NOT NULL,
  created_at TEXT NOT NULL,
  habit_frequency INTEGER DEFAULT 1,
  frequency_counter INTEGER DEFAULT 0,
  next_reset INTEGER DEFAULT 0
);
CREATE TABLE habit_occurrences (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  habit_id INTEGER NOT NULL,
  date TEXT NOT NULL,
  status TEXT NOT NULL,
  completed_at TEXT,
  FOREIGN KEY (habit_id) REFERENCES habits(id)
);
CREATE TABLE badges (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  habit_id INTEGER NOT NULL,
  milestone INTEGER NOT NULL,
  achieved_at TEXT NOT NULL,
  FOREIGN KEY (habit_id) REFERENCES habits(id)
);
```

8. Question: Why is documentation essential for team continuity and future enhancement planning?
   - Category: Ensuring  all teammates understand each other work, why certain things were implmented, easier fix in the future
   - Team Member Responsible: Hien Dao
   - Evidence to Show (code file/commit/UI/screenshot): Commit 84249f2471d538ab9b9bfa0cc741fa1aa7657fd0 message
```
Add habit settings page

Need more page to reach the 5 pages requirement. This page will be used to add and edit habits. It will have a form with the following fields:
- Name (text)
- Description (text)
- Repeat Type (dropdown with options: daily, weekly, monthly, yearly)
- Day of the Week (dropdown with options: Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday) - only shown if Repeat Type is weekly
- Day of the Month (dropdown with options: 1-31) - only shown if Repeat Type is monthly
- Day and month (dropdown with options: 1 1, 2 1, ..., 12 31) - only shown if Repeat Type is yearly
```

9. Question: Walk through one complete feature trace using your actual code: start from a user tap, show the triggering widget, state update logic, data-layer call, and final UI render. Identify the exact files/classes involved at each step.
   - Category:A complete feature trace is the Add Habit flow. The user taps the add-habit button in the main page/controller file, which pushes the habit creation screen; after the user submits, the app creates a Habit object, sends it through the repository/database layer to save it, and then returns to the main screen where setState() reloads the habits list so the new habit immediately appears in the UI.
      
   - Team Member Responsible: Herman Acosta
   - Evidence to Show (code file/commit/UI/screenshot):

10. Question: Present one bug your team introduced and fixed. Show the related commit(s), explain the root cause, why the first approach failed (if applicable), and how the final fix changed runtime behavior.
   - Category: One bug we introduced was that newly added or updated habits did not immediately appear correctly on the main screen after navigating back from the add-habit page. The root cause was that the UI state was not being refreshed at the right time, so the first approach saved the data but did not fully rebuild the visible habit list; the final fix was to reload the habits and call setState() after the page returned, which made the new or changed habit show up instantly at runtime.
   - Team Member Responsible: Herman Acosta
   - Evidence to Show (code file/commit/UI/screenshot):

11. Question: Compare two implementation options your team considered (for example: Provider vs setState, SQLite schema A vs B, or navigation pattern A vs B). Use project-specific constraints to justify the final choice and one trade-off you accepted.
   - Category: At first, we plan to have the AI buddy in a separate page, but we end with intergrating the AI to Habit Detail Page. This way, the Ai can pull data of that habit directly from the Habit Detail page instead of having to do that separately and figure out what message to send out in the separate page
   - Team Member Responsible: Hien Dao
   - Evidence to Show (code file/commit/UI/screenshot): habit_details_page line 211
```
Widget buildAiBox() {
   final mainMessage = AiHelper.generateHabitMessage(
   habit: currentHabit,
   currentStreak: currentStreak,
   currentCycleCount: currentCycleCount,
   cycleGoal: cycleGoal,
   doneThisCycle: doneThisCycle,
   );

   final microGoal = AiHelper.generateMicroGoal(
   habit: currentHabit,
   currentStreak: currentStreak,
   currentCycleCount: currentCycleCount,
   cycleGoal: cycleGoal,
   doneThisCycle: doneThisCycle,
   );
```

12. Question: Demonstrate a data integrity scenario (such as duplicate prevention, failed update, delete rollback, or null handling). Explain exactly where validation occurs and how the app prevents inconsistent state.
   - Category: One data integrity scenario is time handling when creating a habit. Validation occurs where the habit time is selected and then stored, making sure a valid time value exists before the habit is saved, which prevents habits from being created with missing or invalid reset times and keeps the app’s scheduling logic consistent.
   - Team Member Responsible: Herman Acosta
   - Evidence to Show (code file/commit/UI/screenshot):

13. Question: Identify one part of your app that is currently most fragile. Propose a concrete refactor plan with ordered steps, expected impact, and how you would verify improvement using your current test/demo workflow.
   - Category: Updating an existing habit is the most fragil part. Could improve this by centralize the logic and separate UI from logic because right now many pages has logic functions in them
   - Team Member Responsible: Hien Dao
   - Evidence to Show (code file/commit/UI/screenshot): habit_details_page
```
class _HabitDetailsPageState extends State<HabitDetailsPage>
   ...
   Future<void> loadHabitDetails()
   void setupNextReset()
   Future<void> markDoneOnce()
   Future<void> seedTestStreak(int days)
```

## Final Confirmation
- [x] This form includes the questions selected for our presentation.
- [x] We will submit this form at the same time as our project package.

Instruction Statement:
Please include a Selected Presentation Questions Form with your project. This document must list the questions you have chosen to incorporate into your presentation and should be submitted at the same time as your project.
