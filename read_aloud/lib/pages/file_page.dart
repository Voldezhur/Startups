import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:read_aloud/models/text_file.dart';

class FilePage extends StatefulWidget {
  const FilePage({super.key, required this.file});

  final TextFile file;

  @override
  State<FilePage> createState() => _FilePageState();
}

class _FilePageState extends State<FilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<Map>(
        future: widget.file.fileInfo,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Html(
                  data: snapshot.data!['body'],
                  style: {
                    "p.fancy": Style(
                      textAlign: TextAlign.center,
                      backgroundColor: Colors.grey,
                      margin: Margins(left: Margin(50, Unit.px), right: Margin.auto()),
                      width: Width(300, Unit.px),
                      fontWeight: FontWeight.bold,
                    ),
                  },
                ),
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
