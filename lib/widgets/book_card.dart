import 'package:flutter/material.dart';
import 'package:read_aloud_front/models/books.model.dart';
import 'dart:io';

class BookCard extends StatelessWidget {
  final BookItem book;
  final VoidCallback onAction;
  final VoidCallback onTap;

  const BookCard({
    super.key,
    required this.book,
    required this.onAction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(
          height: 108,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 16),
              Hero(
                tag: 'bookImage${book.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: (book.img.isNotEmpty)
                      ? Image.file(
                          File(book.img),
                          width: 72,
                          height: 108,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 72,
                              height: 108,
                              color: Colors.grey[300],
                              child: Icon(Icons.book, color: Colors.grey[600]),
                            );
                          },
                        )
                      : Container(
                          width: 72,
                          height: 108,
                          color: Colors.grey[300],
                          child: Icon(Icons.book, color: Colors.grey[600]),
                        ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: theme.textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      book.author,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    Container(
                      width: 120,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: book.progress / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${book.progress}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: onAction,
                    color: Colors.black54,
                  ),
                ],
              ),
              SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}