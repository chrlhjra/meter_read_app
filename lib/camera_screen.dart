import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

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
      if (imageName != null) {
        final File newImage = await File(image.path).copy(
          '${(await getApplicationDocumentsDirectory()).path}/$imageName.jpg',
        );
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
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, nameController.text),
                child: const Text('Save'),
              ),
            ],
          );
        });
  }

  Future<void> _deleteImage(int index) async {
    await _imageFiles[index].delete();
    setState(() {
      _imageFiles.removeAt(index);
    });
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
                    leading: const Icon(Icons.image),
                    title: Text(_imageFiles[index].path.split('/').last),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteImage(index),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageScreen(
                            imageFile: _imageFiles[index],
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

class ImageScreen extends StatelessWidget {
  const ImageScreen({required this.imageFile, Key? key}) : super(key: key);

  final File imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image'),
        backgroundColor: const Color.fromRGBO(0, 108, 133, 1),
      ),
      body: Center(
        child: Image.file(imageFile),
      ),
    );
  }
}