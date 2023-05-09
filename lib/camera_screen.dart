import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  final List<File> _imageFiles = [];
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  Future<void> _getImage() async {
    try {
      await _initializeControllerFuture;

      final XFile image = await _controller.takePicture();

      final String? imageName = await _getImageName();
      if (imageName != null) {
        final File newImage = await File(image.path).copy(
          '${(await getApplicationDocumentsDirectory()).path}/$imageName.jpg',
        );
        setState(() {
          _imageFiles.add(newImage);
        });
      }
    } catch (e) {
      print(e);
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!(_controller.value.isInitialized)) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera App'),
        backgroundColor: const Color.fromRGBO(0, 108, 133, 1),
      ),
      body: Stack(
        children: [
          CameraPreview(
            _controller,
          ),
          Center(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2.0),
              ),
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.5,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImage,
        tooltip: 'Take Photo',
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

class ImageList extends StatelessWidget {
  final List<File> _imageFiles;
  final void Function(int) _onDelete;

  const ImageList({
    Key? key,
    required List<File> imageFiles,
    required void Function(int) onDelete,
  }) : _imageFiles = imageFiles,
       _onDelete = onDelete,
       super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _imageFiles.length,
      itemBuilder: (context, index) {
        final file = _imageFiles[index];
        return ListTile(
          title: Text(file.path.split('/').last),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _onDelete(index),
          ),
        );
      },
    );
  }
}

class DocumentCaptureGuide extends StatefulWidget {
  const DocumentCaptureGuide({Key? key}) : super(key: key);

  @override
  _DocumentCaptureGuideState createState() => _DocumentCaptureGuideState();
}

class _DocumentCaptureGuideState extends State<DocumentCaptureGuide> {
  final _imagePicker = ImagePicker();
  final _imageFiles = <File>[];

  Future<void> _getImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _imageFiles.add(File(image.path));
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _showImageSourceModal(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _onDelete(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Capture Guide'),
        backgroundColor: const Color.fromRGBO(0, 108, 133, 1),
      ),
      body: Column(
        children: [
          Expanded(
            child: _imageFiles.isNotEmpty
              ? ImageList(
                  imageFiles: _imageFiles,
                  onDelete: _onDelete,
                )
              : const Center(
                  child: Text('No images captured'),
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showImageSourceModal(context),
        tooltip: 'Add Image',
        child: const Icon(Icons.add),
      ),
    );
  }
}
