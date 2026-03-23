# 📈 Habit Mastery League

## 📌 Project Description

Habit Mastery League is a **gamified habit tracking mobile application** built using Flutter. It helps users build consistency and improve daily routines through:

* Habit tracking
* Visual heatmaps
* Streak systems
* AI-driven motivation messages

This app is designed for **students and individuals** who want to develop better habits in a structured, engaging, and data-driven way — all **offline** without cloud dependency.

---

## 👥 Team Members

| Name          | Role                        |
| ------------- | --------------------------- |
| Herman Acosta | Frontend & UI Development   |
| Hien Dao      | Database & Backend Logic    |


---

## 🚀 Features

### ✅ Core Features

* Create, edit, and delete habits (CRUD)
* Custom habit scheduling:

  * Daily, weekly, monthly, yearly
* Habit completion tracking ("Done Once")
* Countdown to next habit occurrence
* Streak tracking system

### 🔥 Heatmap

* Visual consistency tracking
* Darker color = more completions
* Quick navigation to next due habit

### 📊 Habit Details

* Habit description
* Repeat configuration
* Streak badges

### 🤖 AI Features

* Rule-based habit suggestions
* Daily motivational messages

### 🎨 UI/UX

* Dark mode design
* Material UI components
* Responsive layout

---

## 🛠️ Technologies Used

* **Flutter** 3.41.3
* **Dart**
* **SQLite** 2.3.0
* Packages:

  * `flutter_heatmap_calendar`
  * `sqflite`
  * `path_provider`

---

## ⚙️ Installation Instructions

### Option 1: Install via APK (Recommended for quick testing)

1. Download the APK from the releases folder:
   - `release/app-release.apk`
2. Transfer to your Android device
3. Enable "Install from unknown sources"
4. Install and open the app

### Option 2: Run from Source

1. Clone the repository:
   git clone <https://github.com/hermanacos03/mobileappdevelopment_project1.git>

2. Navigate to project:
   cd mobileappdevelopment_project1

3. Install dependencies:
   flutter pub get

4. Run the app:
   flutter run

---

## 📱 Usage Guide

### 🏠 Home Page

* View all habits
* Tap ➕ to add a new habit
* Tap a habit to edit/view details

---

### ⚙️ Create/Edit Habit

* Enter:

  * Name
  * Description
  * Repeat type
  * Schedule
* Save to start tracking

---

### 📊 Habit Detail

* View streak and details
* Tap **"Done Once"** to log completion

---

### 🔥 Heatmap Page

* View activity over time
* Tap suggested habit card to navigate

---

## 💾 Database Schema

The app uses a local **SQLite database** with three main tables:

---

### 🧾 Habits Table

Stores all user-created habits and their scheduling configuration.

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
```

#### 📌 Notes:

* `repeat_type`: daily, weekly, monthly, yearly
* `day_of_week`, `day_of_month`, `month`: used depending on repeat type
* `habit_frequency`: how many times user should complete per cycle
* `frequency_counter`: tracks current progress in cycle
* `next_reset`: used for cycle reset logic

---

### 📅 Habit Occurrences Table

Tracks each instance of a habit on a specific date.

```sql
CREATE TABLE habit_occurrences (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  habit_id INTEGER NOT NULL,
  date TEXT NOT NULL,
  status TEXT NOT NULL,
  completed_at TEXT,
  FOREIGN KEY (habit_id) REFERENCES habits(id)
);
```

#### 📌 Notes:

* `status`: stored as enum string (e.g., pending, completed, missed)
* `completed_at`: timestamp when user marks "Done Once"
* Used for:

  * Heatmap visualization
  * Consistency tracking
  * AI pattern analysis

---

### 🏅 Badges Table

Stores milestone achievements for habits.

```sql
CREATE TABLE badges (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  habit_id INTEGER NOT NULL,
  milestone INTEGER NOT NULL,
  achieved_at TEXT NOT NULL,
  FOREIGN KEY (habit_id) REFERENCES habits(id)
);
```

#### 📌 Notes:

* `milestone`: represents streak levels (e.g., 5, 10, 20 completions)
* `achieved_at`: timestamp when milestone was reached
* Used for gamification (streak badges)

---

### 🔗 Relationships Overview

```text
habits (1) ──── (many) habit_occurrences
habits (1) ──── (many) badges
```

---

### ⚙️ Data Design Considerations

* All dates stored as **TEXT (ISO format)** for consistency
* Enums stored as **string names** for readability
* Foreign keys enforce data integrity
* Designed for **offline-first usage**
* Optimized for:

  * Fast reads (heatmap, dashboard)
  * Simple AI pattern detection

---