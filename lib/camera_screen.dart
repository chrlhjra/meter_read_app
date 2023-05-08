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
      setState(() {
        _imageFiles.add(File(image.path));
      });
    }
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
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: AppBar(
                            title: Text(_imageFiles[index].path),
                            backgroundColor:
                                const Color.fromRGBO(0, 108, 133, 1),
                          ),
                          body: Center(
                            child: Image.file(_imageFiles[index]),
                          ),
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text(_imageFiles[index].path.split('/').last),
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
