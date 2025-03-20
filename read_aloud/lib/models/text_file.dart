import 'dart:io';

import 'package:path/path.dart';
import 'package:xml/xml.dart';

Future<String> parseFile(String path) async {
  // Processing different file types
  var file = File(path);

  switch (extension(path)) {
    case '.fb2':
      var document = XmlDocument.parse(file.readAsStringSync());
      var titles = document.findAllElements('book-title');

      return titles.first.innerText;
  }

  return '';
}

class TextFile {
  final String filePath;
  late Future<String> title;

  TextFile(this.filePath) {
    title = parseFile(filePath);
  }
}
