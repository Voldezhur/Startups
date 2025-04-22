import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class BooksStore extends ChangeNotifier {
  final List<BookItem> _books = [];
  final baseUrl = "http://localhost:8080/";
  UserProfile _userProfile = UserProfile();
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  List<BookItem> get list => _books;
  UserProfile get userProfile => _userProfile;

  Future<void> _initializeLocalPath() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  Future<void> _saveToFile() async {
    await _initializeLocalPath();
    final jsonList = _books.map((book) => book.toJson()).toList();
    await _prefs.setString('books', jsonEncode(jsonList));
  }

  Future<void> _loadFromFile() async {
    await _initializeLocalPath();
    
    if (!_prefs.containsKey('books')) {
      // If no data exists, load from assets
      final String jsonString = await rootBundle.loadString('assets/data/books.json');
      await _prefs.setString('books', jsonString);
      return await _loadFromFile();
    }

    try {
      final String jsonString = _prefs.getString('books') ?? '[]';
      List jsonResponse = jsonDecode(jsonString);
      _books.clear();
      _books.addAll(jsonResponse.map((book) => BookItem.fromJson(book)).toList());
      notifyListeners();
    } catch (e) {
      throw Exception('Ошибка загрузки книг: ${e.toString()}');
    }
  }

  int maxCode() {
    if (_books.isEmpty) return 0;
    int maxCode = _books[0].id;
    for (int i = 1; i < _books.length; i++) {
      if (_books[i].id > maxCode) {
        maxCode = _books[i].id;
      }
    }
    return maxCode;
  }

  int get length => _books.length;

  Future<void> fetchBooks() async {
    try {
      await _loadFromFile();
    } catch (e) {
      throw Exception('Ошибка загрузки книг: ${e.toString()}');
    }
  }

  Future<void> addBook(BookItem newBook) async {
    _books.insert(0, newBook);
    await _saveToFile();
    notifyListeners();
  }

  Future<void> updateBook(BookItem updBook) async {
    int index = _books.indexWhere((item) => item.id == updBook.id);
    if (index != -1) {
      _books[index] = updBook;
      await _saveToFile();
      notifyListeners();
    }
  }

  Future<void> deleteBook(int id) async {
    _books.removeWhere((item) => item.id == id);
    await _saveToFile();
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile profile) async {
    _userProfile = profile;
    notifyListeners();
  }

  Future<void> playAudio(String txt) async {
    final player = AudioPlayer();
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}getaudio'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'text': txt}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        List jsonResponse = json.decode(response.body);
        if (jsonResponse.isNotEmpty) {
          await player.play(UrlSource(baseUrl + jsonResponse[0]));
        } else {
          await player.play(AssetSource('demo.mp3'));
        }
      } else {
        await player.play(AssetSource('demo.mp3'));
      }
    } catch (e) {
      await player.play(AssetSource('demo.mp3'));
    }
  }
}

class BookItem {
  final int id;
  final String title;
  final String author;
  final String booktxt;
  final String img;
  final int progress;
  bool isFavorite;

  BookItem({
    required this.id,
    required this.title,
    required this.author,
    this.booktxt = '',
    this.img = '',
    this.progress = 0,
    this.isFavorite = false,
  });

  factory BookItem.fromJson(Map<String, dynamic> json) {
    return BookItem(
      id: json['id'] as int,
      title: json['title'] as String,
      author: json['author'] as String,
      booktxt: json['booktxt'] as String? ?? '',
      img: json['img'] as String? ?? '',
      progress: json['progress'] as int? ?? 0,
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'booktxt': booktxt,
      'img': img,
      'progress': progress,
      'is_favorite': isFavorite,
    };
  }
}

class UserProfile {
  int uid;
  String name;
  String surname;
  String email;

  UserProfile({
    this.uid = 0,
    this.name = '',
    this.surname = '',
    this.email = '',
  });
}
