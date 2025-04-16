import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FilePage extends StatefulWidget {
  const FilePage({super.key, required this.fileInfo});

  final Map fileInfo;

  @override
  State<FilePage> createState() => _FilePageState();
}

class _FilePageState extends State<FilePage> {
  @override
  Widget build(BuildContext context) {
    var htmlBody = widget.fileInfo["body"].toString().replaceAll('title', 'titles');

    WebViewController wbController = WebViewController()
      ..loadHtmlString("""
        <!DOCTYPE html>
          <html>
            <head><meta name="viewport" content="width=device-width, initial-scale=0.7">
              <style>
                body {
                  font-size: 21px;
                }

                epigraph {
                  font-style: italic;
                  max-width: 40%;
                  text-align: end;
                }

                titles {
                  font-size: 24px;
                  text-align: center;
                }
              </style>
            </head>
              $htmlBody
          </html>
        """)
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    return Scaffold(
      appBar: AppBar(),
      body: WebViewWidget(controller: wbController),
    );
  }
}
