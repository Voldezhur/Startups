import 'package:flutter/material.dart';
import 'package:read_aloud_front/theme.dart';
import 'package:provider/provider.dart';
import 'package:read_aloud_front/screens/book_list_screen.dart';
import 'package:read_aloud_front/models/books.model.dart';
import 'package:read_aloud_front/screens/book_text_screen.dart';
import 'package:read_aloud_front/screens/profile_screen.dart';
import 'package:read_aloud_front/screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          title: 'Читалка вслух',
          theme: DarkTheme,
          routes: {
            '/': (context) => const BookListScreen(title: 'Каталог книг'),
            '/info': (context) => const BookTextScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/auth': (context) => const AuthScreen(),
          },
        ));
  }
}
