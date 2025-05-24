import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_aloud_front/models/books.model.dart';
import 'package:read_aloud_front/widgets/book_card.dart';
import 'package:read_aloud_front/widgets/book_card_grid.dart';
import 'package:read_aloud_front/utils/book_list_helpers.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key, required this.title});
  final String title;

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final _searchController = TextEditingController();
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => Provider.of<BooksStore>(context, listen: false).fetchBooks());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookStore = Provider.of<BooksStore>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Поиск',
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                          prefixIcon: Icon(Icons.search, color: Colors.black54),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.filter_alt_outlined),
                      onPressed: () {},
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(width: 16),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon:
                          Icon(_isGridView ? Icons.view_list : Icons.grid_view),
                      onPressed: () {
                        setState(() {
                          _isGridView = !_isGridView;
                        });
                      },
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(width: 16),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(
                          bookStore.profile.uid > 0
                              ? Icons.person_2
                              : Icons.person_2_outlined,
                          color: bookStore.profile.uid > 0
                              ? Colors.green
                              : Colors.red),
                      onPressed: () {
                        if (bookStore.profile.uid > 0) {
                          Navigator.of(context).pushNamed('/profile');
                        } else {
                          Navigator.of(context).pushNamed('/auth');
                        }
                      },
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: _isGridView
                    ? GridView.builder(
                        padding: EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: bookStore.length,
                        itemBuilder: (context, index) => BookCardGrid(
                          book: bookStore.list[index],
                          onAction: () => showBookActions(
                            context: context,
                            bookStore: bookStore,
                            index: index,
                            onEdit: () => showEditBookDialog(
                              context: context,
                              bookStore: bookStore,
                              index: index,
                              onSave: (updatedBook) async {
                                await bookStore.updateBook(updatedBook);
                                setState(() {});
                              },
                            ),
                            onDelete: () => showDeleteBookDialog(
                              context: context,
                              onDelete: () async {
                                await bookStore
                                    .deleteBook(bookStore.list[index].id);
                                setState(() {});
                              },
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed('/info', arguments: index);
                          },
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.only(top: 16),
                        itemCount: bookStore.length,
                        separatorBuilder: (context, index) => Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Divider(height: 1, color: Colors.black12),
                        ),
                        itemBuilder: (context, index) => BookCard(
                          book: bookStore.list[index],
                          onAction: () => showBookActions(
                            context: context,
                            bookStore: bookStore,
                            index: index,
                            onEdit: () => showEditBookDialog(
                              context: context,
                              bookStore: bookStore,
                              index: index,
                              onSave: (updatedBook) async {
                                await bookStore.updateBook(updatedBook);
                                setState(() {});
                              },
                            ),
                            onDelete: () => showDeleteBookDialog(
                              context: context,
                              onDelete: () async {
                                await bookStore
                                    .deleteBook(bookStore.list[index].id);
                                setState(() {});
                              },
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed('/info', arguments: index);
                          },
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          onPressed: () async {
            final result = await FilePicker.platform
                .pickFiles(type: FileType.custom, allowedExtensions: ['epub']);
            if (result != null && result.files.single.path != null) {
              final filePath = result.files.single.path!;
              final newBook = await bookStore.addBookFromEpub(filePath);
              if (newBook != null) setState(() {});
            }
          },
          backgroundColor: Colors.white,
          elevation: 2,
          shape: CircleBorder(
            side: BorderSide(
              width: 2,
              color: Colors.black54,
            ),
          ),
          child: Icon(Icons.add, color: Colors.black54, size: 32),
        ),
      ),
    );
  }
}
