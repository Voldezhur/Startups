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
          // title: const Text('Главная'),
          ),
      body: ListView.builder(
        itemCount: textFiles.length,
        itemBuilder: (context, index) {
          return fileCard(textFiles[index], context);
        },
      ),
    );
  }

  // Book card
  // Gets a TextFile object
  Widget fileCard(TextFile file, context) {
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Color(0x77000000)))),
      height: MediaQuery.sizeOf(context).height * 0.16,
      margin: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
      padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: MediaQuery.sizeOf(context).height * 0.16,
                width: MediaQuery.sizeOf(context).height * 0.09,
                color: Colors.grey,
              ),
              SizedBox(
                width: MediaQuery.sizeOf(context).height * 0.025,
              ),
              FutureBuilder<Map>(
                future: file.fileInfo,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${snapshot.data!['title']}',
                                style: const TextStyle(fontSize: 17),
                              ),
                              Text(
                                '${snapshot.data!['authorFirstName']} ${snapshot.data!['authorLastName']}',
                                style: const TextStyle(fontSize: 11, color: Color.fromARGB(230, 0, 0, 0)),
                              ),
                            ],
                          ),
                          const Text(
                            'Не начато',
                            style: TextStyle(fontSize: 7, color: Color.fromARGB(191, 0, 0, 0)),
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
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_horiz),
                iconSize: 35,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
