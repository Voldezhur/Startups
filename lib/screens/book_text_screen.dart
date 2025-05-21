import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_aloud_front/models/books.model.dart';
import 'package:read_aloud_front/widgets/book_text_settings_dialog.dart';
import 'package:epub_view/epub_view.dart';
import 'dart:io';

class BookTextScreen extends StatefulWidget {
  const BookTextScreen({super.key});

  @override
  State<BookTextScreen> createState() => _BookTextScreenState();
}

class _BookTextScreenState extends State<BookTextScreen> {
  int index = 0;
  bool _isSearching = false;
  bool _isPlaying = false;
  final TextEditingController _searchController = TextEditingController();
  int _fontSizePercent = 100;
  int _lineHeightPercent = 100;
  String _selectedFont = 'Sans';
  Color _backgroundColor = Color(0xFFF5F1E4);
  Color _textColor = Colors.black87;

  EpubController? _epubController;
  BookItem? _book;

  double get _fontSize => 16.0 * _fontSizePercent / 100;
  double get _lineHeight => _lineHeightPercent / 100;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final args = ModalRoute.of(context)?.settings.arguments;
      assert(args != null && args is int, 'Error: arguments must be int');
      index = args as int;
      final booksStore = Provider.of<BooksStore>(context, listen: false);
      _book = booksStore.list[index];
      if (_book?.filePath != null && _book!.filePath!.isNotEmpty) {
        setState(() {
          _epubController = EpubController(
            document: EpubDocument.openFile(File(_book!.filePath!)),
          );
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _epubController?.dispose();
    super.dispose();
  }

  void _changeFontSize(int delta) {
    setState(() {
      _fontSizePercent = (_fontSizePercent + delta).clamp(50, 200);
    });
  }

  void _changeLineHeight(int delta) {
    setState(() {
      _lineHeightPercent = (_lineHeightPercent + delta).clamp(75, 200);
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
      }
    });
  }

  Widget _buildTitle(String title) {
    return _isSearching
        ? TextField(
            controller: _searchController,
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'Поиск...',
              hintStyle: TextStyle(color: Colors.black54),
              border: InputBorder.none,
            ),
            autofocus: true,
          )
        : Text(title, style: TextStyle(color: Colors.black87));
  }

  void _showTextSettings() {
    showDialog(
      context: context,
      builder: (dialogContext) => BookTextSettingsDialog(
        selectedFont: _selectedFont,
        fontSizePercent: _fontSizePercent,
        lineHeightPercent: _lineHeightPercent,
        backgroundColor: _backgroundColor,
        onFontSelected: (font) {
          setState(() {
            _selectedFont = font;
          });
          Navigator.pop(context);
        },
        onFontSizeChanged: (delta) {
          setState(() {
            _fontSizePercent = (_fontSizePercent + delta).clamp(50, 200);
          });
        },
        onLineHeightChanged: (delta) {
          setState(() {
            _lineHeightPercent = (_lineHeightPercent + delta).clamp(75, 200);
          });
        },
        onThemeSelected: (bg, txt) {
          setState(() {
            _backgroundColor = bg;
            _textColor = txt;
          });
          Navigator.pop(context);
        },
        fontSize: _fontSize,
        lineHeight: _lineHeight,
        fontFamily: _selectedFont,
        textColor: _textColor,
        epubBackgroundColor: _backgroundColor,
      ),
    );
  }

  void _showVoiceSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Настройки озвучки',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text('Скорость речи'),
              trailing: DropdownButton<String>(
                value: 'Нормальная',
                items: ['Медленная', 'Нормальная', 'Быстрая']
                    .map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
                onChanged: (_) {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _togglePlay(BooksStore bookStore, BookItem book) async {
    if (_isPlaying) {
      await bookStore.stopAudio();
    } else {
      await bookStore.playAudio(book.title);
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    final booksStore = Provider.of<BooksStore>(context);
    final book = booksStore.list[index];

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: _buildTitle(book.title),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search,
                color: _textColor),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: Icon(Icons.text_fields, color: _textColor),
            onPressed: _showTextSettings,
          ),
          IconButton(
            icon: Icon(Icons.settings_voice, color: _textColor),
            onPressed: _showVoiceSettings,
          ),
        ],
      ),
      body: (book.filePath != null &&
              book.filePath!.isNotEmpty &&
              _epubController != null)
          ? EpubView(
              controller: _epubController!,
            )
          : Center(
              child: Text(
                'Файл книги не найден',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: _backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () => _togglePlay(booksStore, book),
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.green,
                  ),
                  label: Text(
                    'Начать озвучивать',
                    style: TextStyle(color: _textColor),
                  ),
                ),
                Container(
                  height: 24,
                  width: 1,
                  color: Colors.black12,
                ),
                TextButton.icon(
                  onPressed: () {
                    if (_epubController != null) {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        isScrollControlled: true,
                        builder: (context) => SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: EpubViewTableOfContents(
                              controller: _epubController!,
                              itemBuilder: (context, index, chapter,
                                      itemCount) =>
                                  ListTile(
                                    title: Text(
                                        chapter.title ?? 'Нет заголовка',
                                        style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 14)),
                                    onTap: () {
                                      Navigator.pop(context);
                                      final cfi =
                                          _epubController?.generateEpubCfi();
                                      _epubController?.gotoEpubCfi(cfi ?? '');
                                    },
                                  )),
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    Icons.list,
                    color: Colors.black54,
                  ),
                  label: Text(
                    'Оглавление',
                    style: TextStyle(color: _textColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
