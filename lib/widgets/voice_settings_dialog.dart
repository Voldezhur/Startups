import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_aloud_front/models/books.model.dart';

class VoiceSettingsDialog extends StatelessWidget {
  const VoiceSettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Настройки озвучки',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Язык'),
            trailing: Consumer<BooksStore>(
              builder: (context, booksStore, _) => DropdownButton<String>(
                value: booksStore.selectedTtsLanguage,
                items: booksStore.ttsLanguages
                    .map((lang) => DropdownMenuItem<String>(
                          value: lang,
                          child: Text(lang),
                        ))
                    .toList(),
                onChanged: (lang) {
                  if (lang != null) booksStore.setTtsLanguage(lang);
                },
              ),
            ),
          ),
          ListTile(
            title: const Text('Голос'),
            trailing: Consumer<BooksStore>(
              builder: (context, booksStore, _) => DropdownButton<dynamic>(
                value: booksStore.selectedTtsVoice,
                items: booksStore.ttsVoices
                    .map((voice) => DropdownMenuItem<dynamic>(
                          value: voice,
                          child: Text(voice is Map && voice['name'] != null
                              ? voice['name']
                              : voice.toString()),
                        ))
                    .toList(),
                onChanged: (voice) {
                  if (voice != null) {
                    try {
                      booksStore.setTtsVoice(Text(
                          voice is Map && voice['name'] != null
                              ? voice['name']
                              : voice.toString()));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Failed to set voice: \${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
