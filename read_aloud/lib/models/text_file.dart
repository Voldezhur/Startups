import 'dart:io';

import 'package:path/path.dart';
import 'package:xml/xml.dart';

Future<Map> parseFile(String path) async {
  // Processing different file types
  var file = File(path);

  switch (extension(path)) {
    case '.fb2':
      var document = XmlDocument.parse(file.readAsStringSync());
      var title = document.findAllElements('book-title').first.innerText;
      var author = document.findAllElements('author').first;
      var authorFirstName = author.findAllElements('first-name').first.innerText;
      var authorLastName = author.findAllElements('last-name').first.innerText;

      return {
        'title': title,
        'authorFirstName': authorFirstName,
        'authorLastName': authorLastName,
      };
  }

  return {};
}

class TextFile {
  final String filePath;
  late Future<Map> fileInfo;

  TextFile(this.filePath) {
    fileInfo = parseFile(filePath);
  }
}
