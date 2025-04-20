import 'package:flutter/material.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';

class FilePage extends StatefulWidget {
  const FilePage({super.key, required this.fileInfo});

  final Map fileInfo;

  @override
  State<FilePage> createState() => _FilePageState();
}

class _FilePageState extends State<FilePage> {
  final epubController = EpubController();

  @override
  Widget build(BuildContext context) {
    // Handle different file types
    switch (widget.fileInfo['fileType']) {
      case 'epub':
        return Scaffold(
          appBar: AppBar(),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: EpubViewer(
                    epubSource: EpubSource.fromFile(widget.fileInfo['file']),
                    epubController: epubController,
                    displaySettings: EpubDisplaySettings(flow: EpubFlow.paginated, snap: true),
                    onChaptersLoaded: (chapters) {},
                    onEpubLoaded: () async {},
                    onRelocated: (value) {},
                    onTextSelected: (epubTextSelection) {},
                  ),
                ),
              ],
            ),
          ),
        );
      default:
        return const Text('Неподдерживаемый тип файла');
    }
  }
}
