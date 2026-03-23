# 🏗️ ARCHITECTURE.md

## Habit Mastery League

---

## 📌 Overview

Habit Mastery League follows a **layered architecture pattern** to ensure:

* Separation of concerns
* Maintainability
* Scalability
* Testability

The app is designed as an **offline-first Flutter application** using local data storage and simple AI logic.

---

## 🧱 Architecture Pattern

We adopted a **3-layer architecture**:

```text
UI Layer (Presentation)
        ↓
Data Layer (Repository)
        ↓
Storage Layer (SQLite / SharedPreferences)
```

---

## 🎯 Why This Architecture?

We chose this structure because it:

* Keeps UI independent from data logic
* Makes database changes easier without affecting UI
* Improves code readability and organization
* Supports future scalability (e.g., adding APIs later)

---

## 📂 Project Structure

```text
lib/
│── core/
│   ├── constants/
│   ├── functions/
│   └── utils/
│
│── data/
│   ├── models/
│   ├── repositories/
│   └── database_helper.dart
│
│── ui/
│   ├── pages/
│   └── widgets/
│
└── main.dart
```

---

## 🖥️ 1. UI Layer (Presentation)

### 📍 Location:

```text
lib/ui/
```

### 🧩 Responsibilities:

* Display data to users
* Handle user interactions
* Manage navigation between screens
* Apply theming and layout

### 📄 Components:

* Pages (Screens):

  * Home Page
  * Habit Settings Page
  * Habit Detail Page
  * Heatmap Page
  * AI Page
* Reusable Widgets

### ✅ Why?

Separating UI ensures:

* Cleaner code
* Easier UI updates
* Better reusability

---

## 🗃️ 2. Data Layer (Repository Pattern)

### 📍 Location:

```text
lib/data/repositories/
```

### 🧩 Responsibilities:

* Acts as a bridge between UI and database
* Handles all CRUD operations
* Processes and prepares data

### 📄 Example:

```dart
final repo = HabitRepository();
final habits = await repo.getAllHabits();
```

### ✅ Why Repository Pattern?

* Centralizes data access logic
* Prevents duplication
* Makes testing easier
* Allows future switch to APIs without changing UI

---

## 📦 3. Models Layer

### 📍 Location:

```text
lib/data/models/
```

### 🧩 Responsibilities:

* Define data structures
* Convert between Dart objects and database maps

### 📄 Key Models:

* `Habit`
* `HabitOccurrence`
* `Badge`

### ✅ Design Decisions:

* Use `toMap()` and `fromMap()` for SQLite integration
* Store enums as strings for readability
* Use nullable fields where appropriate

---

## 💾 4. Storage Layer

### 🗄️ SQLite Database

Used for:

* Habits
* Habit occurrences
* Badges

### ⚙️ SharedPreferences

Used for:

* App settings (e.g., theme preferences)
* Lightweight persistent data

### ✅ Why Local Storage?

* Meets requirement: **No cloud storage**
* Faster performance
* Works offline

---

## 🔄 Data Flow

```text
User Action (UI)
      ↓
Page calls Repository
      ↓
Repository queries SQLite
      ↓
Data returned to UI
      ↓
UI updates display
```

---

## 🤖 AI Component Architecture

### 📍 Location:

```text
lib/core/utils/
```

### 🧩 Approach:

We use a **rule-based AI system** instead of complex ML models.

### 📊 How It Works:

1. Retrieve user habit history from SQLite
2. Analyze patterns:

   * Missed habits
   * Completion frequency
3. Generate suggestions:

   * Micro-goals
   * Motivational messages

### 📌 Example:

```text
"If user misses habit 3 times → suggest easier goal"
```

### ✅ Why Rule-Based AI?

* Simple to implement
* Fully explainable (important for grading)
* No external dependencies
* Works offline

---

## 🎨 UI Design Decisions

* **Material Design** for consistency
* **Dark mode first** approach
* Reusable widgets to reduce duplication
* Responsive layouts for different orientations

---

## 🔁 State Management

Currently uses:

* `setState()` for simplicity

### ✅ Why?

* Suitable for small-to-medium apps
* Easy to understand and implement

### 🔮 Future Upgrade:

* Provider / Riverpod for scalability

---

## 🧪 Error Handling Strategy

* Input validation on forms
* Null safety across app
* Safe database queries
* Graceful UI fallbacks (empty states)

---

## 🔐 Data Integrity & Validation

* Foreign key constraints in SQLite
* Enum validation when parsing data
* Required fields enforced at model level

---

## 🚀 Scalability Considerations

This architecture allows easy extension:

* Add API layer without breaking UI
* Replace local DB with remote backend
* Introduce advanced AI models
* Add notification system

---

## ⚖️ Trade-offs

| Decision             | Benefit           | Trade-off                 |
| -------------------- | ----------------- | ------------------------- |
| SQLite               | Offline, fast     | No cloud sync             |
| setState             | Simple            | Not scalable              |
| Rule-based AI        | Easy, explainable | Limited intelligence      |
| Layered architecture | Clean structure   | Slightly more boilerplate |

---

## 🏁 Conclusion

The architecture of Habit Mastery League is designed to:

* Be simple yet structured
* Meet academic requirements
* Support future improvements

By combining:

* Layered architecture
* Repository pattern
* Local persistence
* Rule-based AI

the app achieves a balance between **functionality, maintainability, and scalability**.

---
