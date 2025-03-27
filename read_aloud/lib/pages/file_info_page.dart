import 'package:flutter/material.dart';
import 'package:read_aloud/models/text_file.dart';

class FileInfoPage extends StatefulWidget {
  const FileInfoPage({super.key, required this.file});

  final TextFile file;

  @override
  State<FileInfoPage> createState() => _FileInfoPageState();
}

class _FileInfoPageState extends State<FileInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: widget.file.fileInfo,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Text('Описание', style: TextStyle(fontSize: 21)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                    child: Text(snapshot.data!['annotation'] ?? 'Нет описания🤷‍♀️'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Ошибка: ${snapshot.error}');
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
