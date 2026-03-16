import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Pages(),
    );
  }
}

class Pages extends StatefulWidget {
  const Pages({super.key});

  @override
  State<Pages> createState() => _Pages();
}

class _Pages extends State<Pages> {
  int selectedIndex = 0;

  Widget _buildPage() {
    switch (selectedIndex) {
      case 0:
        return const Text(
          'Homepage',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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

  void changePage(int index) {
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            _buildPage(),

            const SizedBox(height: 30),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => changePage(0),
                  child: const Text('Home'),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () => changePage(1),
                  child: const Text('1'),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () => changePage(2),
                  child: const Text('2'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}