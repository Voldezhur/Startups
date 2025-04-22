import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:books_reader/models/books.model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _surnameController = TextEditingController();
    _emailController = TextEditingController();
  }

  bool _isEditing = false;

  void _updateProfile(BooksStore booksStore) {
    UserProfile profile = UserProfile(
      uid: 1,
      name: _nameController.text,
      surname: _surnameController.text,
      email: _emailController.text
    );
    booksStore.updateProfile(profile);
    _isEditing = false;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Профиль обновлен')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booksStore = Provider.of<BooksStore>(context);
    _nameController.text = booksStore.userProfile.name;
    _surnameController.text = booksStore.userProfile.surname;
    _emailController.text = booksStore.userProfile.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Имя'),
              enabled: _isEditing,
            ),
            TextField(
              controller: _surnameController,
              decoration: const InputDecoration(labelText: 'Фамилия'),
              enabled: _isEditing,
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              enabled: _isEditing,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_isEditing) {
                  _updateProfile(booksStore);
                } else {
                  setState(() {
                    _isEditing = true;
                  });
                }
              },
              child: Text(_isEditing ? 'Сохранить изменения' : 'Изменить профиль'),
            ),
          ],
        ),
      ),
    );
  }
} 