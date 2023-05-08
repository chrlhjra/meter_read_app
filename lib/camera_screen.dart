import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final List<File> _imageFiles = [];

  Future<void> _getImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final String? imageName = await _getImageName();
      if (imageName != null && imageName.isNotEmpty) {
        final String imagePath = '${image.path.split('/').last}';
        final File newImage = await File(image.path).copy('$imagePath/$imageName');
        setState(() {
          _imageFiles.add(newImage);
        });
      }
    }
  }

  Future<String?> _getImageName() async {
    final nameController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Image Name'),
          content: TextFormField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Enter name'),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, nameController.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera App'),
        backgroundColor: const Color.fromRGBO(0, 108, 133, 1),
      ),
      body: _imageFiles.isEmpty
          ? const Center(child: Text('No images selected.'))
          : ListView.builder(
              itemCount: _imageFiles.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  margin: const EdgeInsets.all(10),
                  color: Colors.orangeAccent,
                  child: ListTile(
                    leading: Image.file(
                      _imageFiles[index],
                      width: 50,
                      height: 50,
                    ),
                    title: Text(_imageFiles[index].path.split('/').last),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(
                              title: Text(_imageFiles[index].path.split('/').last),
                            ),
                            body: Center(
                              child: Image.file(
                                _imageFiles[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImage,
        tooltip: 'Take Photo',
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
