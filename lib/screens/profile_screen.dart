import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_aloud_front/models/books.model.dart';

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
        email: _emailController.text);
    booksStore.updateProfile(profile);
    _isEditing = false;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Профиль обновлен')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booksStore = Provider.of<BooksStore>(context);
    _nameController.text = booksStore.profile.name;
    _surnameController.text = booksStore.profile.surname;
    _emailController.text = booksStore.profile.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Имя',
                  prefixIcon: Icon(Icons.person_4, color: Colors.black54),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                ),
                enabled: _isEditing,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _surnameController,
                decoration: const InputDecoration(
                  labelText: 'Фамилия',
                  prefixIcon:
                      Icon(Icons.person_4_outlined, color: Colors.black54),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                ),
                enabled: _isEditing,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email, color: Colors.black54),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                ),
                enabled: _isEditing,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_isEditing) {
                    _updateProfile(booksStore);
                  } else {
                    setState(() {
                      _isEditing = true;
                    });
                  }
                },
                child: Text(
                    _isEditing ? 'Сохранить изменения' : 'Изменить профиль'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
