import 'package:flutter/material.dart';
import 'package:read_aloud_front/models/books.model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

class AddBookDialog extends StatefulWidget {
  final void Function(BookItem) onAdd;
  final int newId;
  const AddBookDialog({super.key, required this.onAdd, required this.newId});

  @override
  State<AddBookDialog> createState() => _AddBookDialogState();
}

class _AddBookDialogState extends State<AddBookDialog> {
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final bookTxtController = TextEditingController();
  final imgController = TextEditingController();
  String? _pickedFilePath;
  String? _pickedFileName;

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    bookTxtController.dispose();
    imgController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub', 'fb2'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _pickedFilePath = result.files.single.path;
        _pickedFileName = result.files.single.name;
      });
    }
  }

  Future<String?> _copyFileToAppStorage(String sourcePath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final booksDir = Directory(p.join(appDir.path, 'books'));
      if (!await booksDir.exists()) {
        await booksDir.create(recursive: true);
      }
      final fileName = p.basename(sourcePath);
      final targetPath = p.join(booksDir.path, '${DateTime.now().millisecondsSinceEpoch}_$fileName');
      final newFile = await File(sourcePath).copy(targetPath);
      return newFile.path;
    } catch (e) {
      return null;
    }
  }

  void _submit() async {
    if (titleController.text.isNotEmpty &&
        authorController.text.isNotEmpty &&
        imgController.text.isNotEmpty) {
      String? savedFilePath;
      if (_pickedFilePath != null) {
        savedFilePath = await _copyFileToAppStorage(_pickedFilePath!);
      }
      final newBook = BookItem(
        id: widget.newId,
        title: titleController.text,
        author: authorController.text,
        booktxt: bookTxtController.text,
        img: imgController.text,
        filePath: savedFilePath,
      );
      widget.onAdd(newBook);
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка: все поля должны быть заполнены.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Добавить книгу'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            TextField(
              controller: authorController,
              decoration: const InputDecoration(labelText: 'Автор'),
            ),
            TextField(
              controller: bookTxtController,
              decoration: const InputDecoration(labelText: 'Текст'),
            ),
            TextField(
              controller: imgController,
              decoration: const InputDecoration(labelText: 'Изображение (имя файла)'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _pickedFileName != null ? 'Файл: $_pickedFileName' : 'Файл не выбран',
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: _pickFile,
                  child: const Text('Выбрать файл'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Отмена'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('Добавить'),
          onPressed: _submit,
        ),
      ],
    );
  }
} 