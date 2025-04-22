import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:books_reader/models/books.model.dart';

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

  double get _fontSize => 16.0 * _fontSizePercent / 100;
  double get _lineHeight => _lineHeightPercent / 100;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    final args = ModalRoute.of(context)?.settings.arguments;
    super.didChangeDependencies();
    assert(args != null && args is int, 'Error: arguments must be int');
    index = args as int;
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
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          alignment: Alignment.topCenter,
          insetPadding: EdgeInsets.only(top: 60, left: 16, right: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Шрифт',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    _FontButton(
                      title: 'Sans',
                      isSelected: _selectedFont == 'Sans',
                      onTap: () {
                        setState(() {
                          _selectedFont = 'Sans';
                        });
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 8),
                    _FontButton(
                      title: 'Literata',
                      isSelected: _selectedFont == 'Literata',
                      onTap: () {
                        setState(() {
                          _selectedFont = 'Literata';
                        });
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 8),
                    _FontButton(
                      title: 'Vollkorn',
                      isSelected: _selectedFont == 'Vollkorn',
                      onTap: () {
                        setState(() {
                          _selectedFont = 'Vollkorn';
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Размер',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  setDialogState(() {
                                    setState(() {
                                      _fontSizePercent = (_fontSizePercent - 10).clamp(50, 200);
                                    });
                                  });
                                },
                              ),
                              Text('$_fontSizePercent%'),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  setDialogState(() {
                                    setState(() {
                                      _fontSizePercent = (_fontSizePercent + 10).clamp(50, 200);
                                    });
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Межстрочный интервал',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  setDialogState(() {
                                    setState(() {
                                      _lineHeightPercent = (_lineHeightPercent - 25).clamp(75, 200);
                                    });
                                  });
                                },
                              ),
                              Text('$_lineHeightPercent%'),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  setDialogState(() {
                                    setState(() {
                                      _lineHeightPercent = (_lineHeightPercent + 25).clamp(75, 200);
                                    });
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Режим просмотра',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    _ThemeButton(
                      color: Colors.white,
                      borderColor: Colors.black12,
                      isSelected: _backgroundColor == Colors.white,
                      onTap: () {
                        setState(() {
                          _backgroundColor = Colors.white;
                          _textColor = Colors.black87;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 8),
                    _ThemeButton(
                      color: Color(0xFFF5F1E4),
                      borderColor: Colors.black12,
                      isSelected: _backgroundColor == Color(0xFFF5F1E4),
                      onTap: () {
                        setState(() {
                          _backgroundColor = Color(0xFFF5F1E4);
                          _textColor = Colors.black87;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 8),
                    _ThemeButton(
                      color: Colors.black,
                      borderColor: Colors.transparent,
                      isSelected: _backgroundColor == Colors.black,
                      onTap: () {
                        setState(() {
                          _backgroundColor = Colors.black;
                          _textColor = Colors.white;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_isPlaying) {
      await bookStore.playAudio(book.booktxt);
    }
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Text(
          book.booktxt,
          style: TextStyle(
            fontSize: _fontSize,
            color: _textColor,
            height: _lineHeight,
            fontFamily: _selectedFont,
          ),
          textAlign: TextAlign.justify,
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
                  onPressed: () {},
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

class _FontButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _FontButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.green : Colors.black12,
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeButton({
    required this.color,
    required this.borderColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.green : borderColor,
              width: isSelected ? 2 : 1,
            ),
          ),
        ),
      ),
    );
  }
} 