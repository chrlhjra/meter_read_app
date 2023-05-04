import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();
  
  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();
  
  // Get the first camera from the list.
  final firstCamera = cameras.first;
  
  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatefulWidget {
  final CameraDescription camera;

  const MyApp({Key? key, required this.camera}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late File _imageFile;

  @override
  void initState() {
    super.initState();
    
    // To display the current output from the camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 0, 108, 133),
          title: const Text('Meter Reader'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // Take a picture and save it to the temporary directory.
            try {
              // Ensure that the camera is initialized.
              await _initializeControllerFuture;

              // Construct the path where the image should be saved using the
              // path provider package.
              final directory = await getTemporaryDirectory();
              final imagePath = '${directory.path}/${DateTime.now()}.png';

              // Attempt to take a picture and log where it's been saved.
              await _controller.takePicture();

              // If the picture was taken successfully, set the image file and
              // update the UI to display the new image.
              setState(() {
                _imageFile = File(imagePath);
              });
            } catch (e) {
              // If an error occurs, log the error to the console.
              print(e);
            }
          },
          child: const Icon(Icons.camera_alt),
        ),
        body: Center(
          // ignore: unnecessary_null_comparison
          child: _imageFile == null ? const Text('No image taken') : Image.file(_imageFile),
        ),
      ),
    );
  }
}
