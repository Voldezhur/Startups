import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:read_aloud_front/models/books.model.dart';
import 'package:read_aloud_front/widgets/book_action_sheet.dart';

Future<void> showBookActions({
  required BuildContext context,
  required BooksStore bookStore,
  required int index,
  required void Function() onEdit,
  required void Function() onDelete,
}) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return BookActionSheet(
        book: bookStore.list[index],
        onShare: () {
          Navigator.pop(context);
        },
        onEdit: () {
          Navigator.pop(context);
          onEdit();
        },
        onDelete: () {
          Navigator.pop(context);
          onDelete();
        },
      );
    },
  );
}

Future<void> showEditBookDialog({
  required BuildContext context,
  required BooksStore bookStore,
  required int index,
  required void Function(BookItem) onSave,
}) async {
  final book = bookStore.list[index];
  final titleController = TextEditingController(text: book.title);
  final authorController = TextEditingController(text: book.author);
  final imgController = TextEditingController(text: book.img);

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Редактировать книгу'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  // Открытие файлового диалога для выбора PNG
                  /* final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['png'],
                  );
                  if (result != null && result.files.single.path != null) {
                    final selectedPath = result.files.single.path!;
                    await File(selectedPath).copy(imgController.text);
                  } */
                },
                child: imgController.text.isNotEmpty
                    ? Image.file(
                        File(imgController.text),
                        width: 120,
                        height: 180,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 120,
                        height: 180,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 48),
                      ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Название'),
              ),
              TextField(
                controller: authorController,
                decoration: const InputDecoration(labelText: 'Автор'),
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Отмена'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Сохранить'),
            onPressed: () async {
              if (titleController.text.isNotEmpty &&
                  authorController.text.isNotEmpty) {
                final updatedBook = BookItem(
                    id: book.id,
                    title: titleController.text,
                    author: authorController.text,
                    img: imgController.text);
                onSave(updatedBook);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Ошибка: все поля должны быть заполнены.')),
                );
              }
            },
          ),
        ],
      );
    },
  );
}

Future<void> showDeleteBookDialog({
  required BuildContext context,
  required VoidCallback onDelete,
}) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Подтверждение удаления'),
        content: const Text('Вы уверены, что хотите удалить эту книгу?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Отмена'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Удалить'),
            onPressed: () {
              onDelete();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
