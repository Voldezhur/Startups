import 'package:flutter/material.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';

class FilePage extends StatefulWidget {
  const FilePage({super.key, required this.fileInfo});

  final Map fileInfo;

  @override
  State<FilePage> createState() => _FilePageState();
}

class _FilePageState extends State<FilePage> {
  EpubController epubController = EpubController();

  @override
  Widget build(BuildContext context) {
    // Handle different file types
    switch (widget.fileInfo['fileType']) {
      case 'epub':
        return Scaffold(
          appBar: AppBar(),
          body: Stack(
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
              // Going to the previous page
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Positioned(
                      child: GestureDetector(
                        onTap: epubController.prev,
                        child: Container(
                          height: MediaQuery.sizeOf(context).height,
                          width: MediaQuery.sizeOf(context).width * 0.2,
                          // Have to put some color on the Container, otherwise doesn't register a tap
                          // No clue why, don't ask questions
                          color: const Color.fromRGBO(255, 255, 255, 0.0),
                        ),
                      ),
                    ),
                  ),
                  // Going to the next page
                  Expanded(
                    child: Positioned(
                      child: GestureDetector(
                        onTap: epubController.next,
                        child: Container(
                          height: MediaQuery.sizeOf(context).height,
                          width: MediaQuery.sizeOf(context).width * 0.2,
                          // Have to put some color on the Container, otherwise doesn't register a tap
                          // No clue why, don't ask questions
                          color: const Color.fromRGBO(255, 255, 255, 0.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      default:
        return const Text('Неподдерживаемый тип файла');
    }
  }
}
