import 'package:flutter/material.dart';

/// Диалог настроек текста для экрана чтения книги
class BookTextSettingsDialog extends StatelessWidget {
  final String selectedFont;
  final int fontSizePercent;
  final int lineHeightPercent;
  final Color backgroundColor;
  final Function(String) onFontSelected;
  final Function(int) onFontSizeChanged;
  final Function(int) onLineHeightChanged;
  final Function(Color, Color) onThemeSelected;
  final double fontSize;
  final double lineHeight;
  final String fontFamily;
  final Color textColor;
  final Color epubBackgroundColor;

  const BookTextSettingsDialog({
    super.key,
    required this.selectedFont,
    required this.fontSizePercent,
    required this.lineHeightPercent,
    required this.backgroundColor,
    required this.onFontSelected,
    required this.onFontSizeChanged,
    required this.onLineHeightChanged,
    required this.onThemeSelected,
    required this.fontSize,
    required this.lineHeight,
    required this.fontFamily,
    required this.textColor,
    required this.epubBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.only(top: 60, left: 16, right: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Шрифт',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _FontButton(
                  title: 'Sans',
                  isSelected: selectedFont == 'Sans',
                  onTap: () => onFontSelected('Sans'),
                ),
                const SizedBox(width: 8),
                _FontButton(
                  title: 'Literata',
                  isSelected: selectedFont == 'Literata',
                  onTap: () => onFontSelected('Literata'),
                ),
                const SizedBox(width: 8),
                _FontButton(
                  title: 'Vollkorn',
                  isSelected: selectedFont == 'Vollkorn',
                  onTap: () => onFontSelected('Vollkorn'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Размер', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () => onFontSizeChanged(-10),
                          ),
                          Text('$fontSizePercent%'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => onFontSizeChanged(10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Межстрочный интервал', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () => onLineHeightChanged(-25),
                          ),
                          Text('$lineHeightPercent%'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => onLineHeightChanged(25),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Режим просмотра', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: [
                _ThemeButton(
                  color: Colors.white,
                  borderColor: Colors.black12,
                  isSelected: backgroundColor == Colors.white,
                  onTap: () => onThemeSelected(Colors.white, Colors.black87),
                ),
                const SizedBox(width: 8),
                _ThemeButton(
                  color: const Color(0xFFF5F1E4),
                  borderColor: Colors.black12,
                  isSelected: backgroundColor == const Color(0xFFF5F1E4),
                  onTap: () => onThemeSelected(const Color(0xFFF5F1E4), Colors.black87),
                ),
                const SizedBox(width: 8),
                _ThemeButton(
                  color: Colors.black,
                  borderColor: Colors.transparent,
                  isSelected: backgroundColor == Colors.black,
                  onTap: () => onThemeSelected(Colors.black, Colors.white),
                ),
              ],
            ),
          ],
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
          padding: const EdgeInsets.symmetric(vertical: 8),
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