import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Habits(),
    );
  }
}

class Habits extends StatefulWidget {
  const Habits({super.key});

  @override
  State<Habits> createState() => _HabitsState();
}

class _HabitsState extends State<Habits> {
  int selectedIndex = 0;
  List<String> habits = [];

  Widget _buildPage() {
    switch (selectedIndex) {
      case 0:
         final now = DateTime.now();

          final time =
              '${(now.hour % 12 == 0 ? 12 : now.hour % 12)}:${now.minute.toString().padLeft(2, '0')} '
              '${now.hour >= 12 ? 'PM' : 'AM'}';

          final date =
              '${now.month}/${now.day}/${now.year}';

          return Text(
            '$date\n$time',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          );

      case 1:
        return const Text(
          'Page1',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        );
      case 2:
        return const Text(
          'Page2',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void addHabit() {
    final formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController timeController = TextEditingController();
    final TextEditingController frequencyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Creating a new habit'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: double.maxFinite,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Habit Name",
                        hintText: "Example: Laundry",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a habit name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),
                    TextFormField(
                      controller: frequencyController,
                      decoration: const InputDecoration(
                        labelText: "Frequency",
                        hintText: "1(once a day), 2(twice a day)",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a frequency';
                        }
                        if(int.tryParse(value)==null){
                            return 'Please numbers only';
                          }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),
                    TextFormField(
                      controller: timeController,
                      maxLines: 1,
                      decoration: const InputDecoration(
                        labelText: "What time of day for habit",
                        hintText: "0130 (hrs mins)",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a time';
                        }
                        if (value.length != 4) {
                          return 'Please enter exactly 4 digits';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.cancel, size: 20),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final habitTitle = nameController.text.trim();

                  final habitFrequency = frequencyController.text.trim();
                  final habitTime = timeController.text.trim();

                  setState(() {
                    habits.add(habitTitle);
                  });

                  // these are still available here if you need them later
                  debugPrint('Habit title: $habitTitle');
                  debugPrint('Habit frequency: $habitFrequency');
                  debugPrint('Habit time: $habitTime');

                  Navigator.pop(context);
                }
              },
              child: const Icon(Icons.check_box, size: 25),
            ),
          ],
        );
      },
    );
  }

  void changePages(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Switcher'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildPage(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => changePages(0),
                  child: const Text('Home'),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () => changePages(1),
                  child: const Text('1'),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () => changePages(2),
                  child: const Text('2'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: addHabit,
                child: const Icon(Icons.add, size: 35),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: habits.isEmpty
                  ? const Center(
                      child: Text(
                        'No habits added yet',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: habits.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: () {},
                              child: Text(
                                habits[index],
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}