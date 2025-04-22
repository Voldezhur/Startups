import 'package:flutter/material.dart';
import 'package:books_reader/theme.dart';
import 'package:provider/provider.dart';
import 'package:books_reader/screens/book_list_screen.dart';
import 'package:books_reader/models/books.model.dart';
import 'package:books_reader/screens/book_text_screen.dart';
import 'package:books_reader/screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BooksStore(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'readAloud',
        theme: DarkTheme,
        routes: {
          '/': (context) => const BookListScreen(title: 'Каталог книг'),
          '/info': (context) => const BookTextScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
      )
    );
  }
}
