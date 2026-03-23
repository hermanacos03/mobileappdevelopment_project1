import 'package:flutter/material.dart';
import 'ui/pages/pageController.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,


      themeMode: ThemeMode.dark,

      darkTheme: ThemeData(
        brightness: Brightness.dark,


        scaffoldBackgroundColor: Colors.black,

        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 128, 109, 14),
          foregroundColor: Colors.white,
          elevation: 0,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[900],
            foregroundColor: Colors.white,
          ),
        ),

        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
        ),
      ),

      home: const PageControllerapp(),
    );
  }
}