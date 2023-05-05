import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Camera App',
      home: CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late final ImagePicker picker;

  File? _imageFile;

  @override
  void initState() {
    super.initState();
    picker = ImagePicker();
    _getImage();
  }

  Future<void> _getImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _imageFile == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Image.file(_imageFile!),
            ),
    );
  }
}
