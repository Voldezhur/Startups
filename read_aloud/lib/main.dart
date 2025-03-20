import 'package:flutter/material.dart';
import 'package:read_aloud/pages/main_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        primaryColor: const Color(0xFF00B358),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00B358),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 21),
        ),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}
