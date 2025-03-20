import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:read_aloud/consts.dart';
import 'package:read_aloud/models/text_file.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  void getFilesFromDownload() async {
    // Get storage permission
    var status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      openAppSettings();
    }

    // Recursively get the list of files in Download folder
    Directory directory = Directory('/storage/emulated/0/Download');
    List<FileSystemEntity> files = await directory.list(recursive: true).toList();

    // SetState the files into a list
    for (FileSystemEntity file in files) {
      if (file is File && extension(file.path) == '.fb2') {
        setState(() {
          textFiles.add(TextFile(file.path));
        });
      }
    }
  }

  @override
  void initState() {
    getFilesFromDownload();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главная'),
      ),
      body: ListView.builder(
        itemCount: textFiles.length,
        itemBuilder: (context, index) {
          return fileCard(textFiles[index]);
        },
      ),
    );
  }

  // Book card
  // Gets a TextFile object
  Widget fileCard(TextFile file) {
    return Container(
      child: FutureBuilder<Map>(
        future: file.fileInfo,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                Text('Название: ${snapshot.data!['title']}'),
                Text('Автор: ${snapshot.data!['authorFirstName']} ${snapshot.data!['authorLastName']}'),
              ],
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
