import 'dart:io';

import 'package:epub_view/epub_view.dart';
import 'package:path/path.dart';
import 'package:xml/xml.dart';

Future<Map> parseFile(String path) async {
  // Processing different file types
  var textFile = File(path);

  switch (extension(path)) {
    case '.fb2':
      // Convert to .epub first using https://developers.convertio.co/ru/
      // For now using old code

      var document = XmlDocument.parse(textFile.readAsStringSync());

      var description = document.findAllElements('description').first;

      var title = description.findAllElements('book-title').first.innerText;
      var author = description.findAllElements('author').first;
      var authorFirstName = author.findAllElements('first-name').first.innerText;
      var authorLastName = author.findAllElements('last-name').first.innerText;

      var annotation = description.findAllElements('annotation').isNotEmpty ? description.findAllElements('annotation').first.innerText : null;

      var body = document.findAllElements('body').first.toString();

      return {
        'title': title,
        'authorFirstName': authorFirstName,
        'authorLastName': authorLastName,
        'body': body,
        'annotation': annotation,
      };

    case '.epub':
      // Use epub_view
      EpubBook document = await EpubDocument.openFile(textFile);

      return {
        'file': textFile,
        'fileType': 'epub',
        'title': document.Title,
        'coverImage': document.CoverImage,
        'authorFirstName': document.Author,
        'authorLAstName': '',
        'annotation': '',
      };

    default:
      return {};
  }
}

class TextFile {
  final String filePath;
  late Future<Map> fileInfo;

  TextFile(this.filePath) {
    fileInfo = parseFile(filePath);
  }
}
