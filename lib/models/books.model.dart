import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:epub_view/epub_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:image/image.dart' as image;

class BooksStore extends ChangeNotifier {
  final List<BookItem> _books = [];
  final baseUrl = "http://localhost:8080/";
  UserProfile _userProfile = UserProfile();
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

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
      final String jsonString =
          await rootBundle.loadString('assets/data/books.json');
      await _prefs.setString('books', jsonString);
      return await _loadFromFile();
    }

    try {
      final String jsonString = _prefs.getString('books') ?? '[]';
      List jsonResponse = jsonDecode(jsonString);
      _books.clear();
      _books
          .addAll(jsonResponse.map((book) => BookItem.fromJson(book)).toList());
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
      _books[index].author = updBook.author;
      _books[index].title = updBook.title;
      if (_books[index].title.isEmpty) _books[index].img = updBook.img;
      await _saveToFile();
      notifyListeners();
    }
  }

  Future<void> deleteBook(int id) async {
    final book = _books.firstWhere(
      (item) => item.id == id,
      orElse: () => BookItem(id: -1, title: '', author: '', filePath: null),
    );
    if (book.id != -1) {
      if (book.filePath != null && book.filePath!.isNotEmpty) {
        final file = File(book.filePath!);
        if (await file.exists()) {
          try {
            await file.delete();
          } catch (e) {
            // ignore error
          }
        }
      }
      if (book.img.isNotEmpty) {
        final coverFile = File(book.img);
        if (await coverFile.exists()) {
          try {
            await coverFile.delete();
          } catch (e) {
            // ignore error
          }
        }
      }
      _books.removeWhere((item) => item.id == id);
      await _saveToFile();
      notifyListeners();
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    _userProfile = profile;
    notifyListeners();
  }

  Future<void> playAudio(String txt) async {
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
          await _player.play(UrlSource(baseUrl + jsonResponse[0]));
        } else {
          await _player.play(AssetSource('demo.mp3'));
        }
      } else {
        await _player.play(AssetSource('demo.mp3'));
      }
      _isPlaying = true;
    } catch (e) {
      await _player.play(AssetSource('demo.mp3'));
      _isPlaying = true;
    }
  }

  Future<void> stopAudio() async {
    if (_isPlaying) {
      await _player.stop();
      _isPlaying = false;
    }
  }

  /// Анализирует epub файл, извлекает метаданные и добавляет книгу в библиотеку
  ///
  /// [epubFilePath] - путь к файлу epub
  ///
  /// Возвращает добавленную книгу или null в случае ошибки
  Future<BookItem?> addBookFromEpub(String epubFilePath) async {
    try {
      // Проверяем существование файла
      final File epubFile = File(epubFilePath);
      if (!await epubFile.exists()) {
        throw Exception('Файл не существует: $epubFilePath');
      }

      // Получаем директорию для хранения книг
      final appDir = await getApplicationDocumentsDirectory();
      final booksDir = Directory(p.join(appDir.path, 'books'));
      if (!await booksDir.exists()) {
        await booksDir.create(recursive: true);
      }

      // Создаем директорию для обложек
      final coversDir = Directory(p.join(appDir.path, 'covers'));
      if (!await coversDir.exists()) {
        await coversDir.create(recursive: true);
      }

      // Генерируем уникальное имя файла
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = p.basename(epubFilePath);
      final newFilePath = p.join(booksDir.path, '${timestamp}_$fileName');

      // Копируем файл в директорию приложения
      final savedFile = await epubFile.copy(newFilePath);

      // Открываем epub документ для извлечения метаданных
      final epubDocument = await EpubDocument.openFile(savedFile);

      // Извлекаем метаданные
      String title = 'Неизвестная книга';
      String author = 'Неизвестный автор';

      // Получаем название книги
      if (epubDocument.Title != null && epubDocument.Title!.isNotEmpty) {
        title = epubDocument.Title!;
      }

      // Получаем автора книги
      if (epubDocument.Author != null && epubDocument.Author!.isNotEmpty) {
        author = epubDocument.Author!;
      }

      // Пытаемся получить обложку
      final coverImage = epubDocument.CoverImage;
      String coverPath = '';
      if (coverImage != null) {
        // Сохраняем обложку, если она есть
        final coverFileName = '${timestamp}_cover.png';
        final coverFilePath = p.join(coversDir.path, coverFileName);
        File(coverFilePath).writeAsBytesSync(image.encodePng(coverImage));
        coverPath = coverFilePath;
      }

      // Создаем и добавляем новую книгу
      final newBook = BookItem(
        id: maxCode() + 1,
        title: title,
        author: author,
        img: coverPath,
        filePath: savedFile.path,
      );

      await addBook(newBook);
      return newBook;
    } catch (e) {
      throw Exception('Ошибка при добавлении книги из epub: ${e.toString()}');
    }
  }
}

class BookItem {
  final int id;
  String title;
  String author;
  String img;
  int progress;
  final String? filePath;
  bool isFavorite;

  BookItem({
    required this.id,
    required this.title,
    required this.author,
    this.img = '',
    this.progress = 0,
    this.filePath,
    this.isFavorite = false,
  });

  factory BookItem.fromJson(Map<String, dynamic> json) {
    return BookItem(
      id: json['id'] as int,
      title: json['title'] as String,
      author: json['author'] as String,
      img: json['img'] as String? ?? '',
      progress: json['progress'] as int? ?? 0,
      filePath: json['filePath'] as String?,
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'img': img,
      'progress': progress,
      'filePath': filePath,
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
