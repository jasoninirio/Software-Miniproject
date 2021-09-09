// import 'dart:js'
// import 'dart:html';
import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => HomePage(),
      '/camera': (context) => HostCameraPage(camera: firstCamera),
      '/profile': (context) => ProfilePage(),
    },
  ));
}

// Home Page - hosts some neat things like a calorie tracker (?)
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('healthi'),
        centerTitle: true,
        backgroundColor: Colors.yellow,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            // Camera Button
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/camera');
                },
                child: Text('Camera')),

            // Profile Button
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/profile');
                },
                child: Text('Profile')),
          ],
        ),
      ),
    );
  }
}

class HostCameraPage extends StatelessWidget {
  const HostCameraPage({
    Key? key,
    required this.camera,
  }) : super(key: key);

  final CameraDescription camera;

  @override
  // MaterialApp(
  //   home: CameraPage(
  //     // Pass the appropriate camera to the TakePictureScreen widget.
  //     camera: firstCamera,
  //   ),
  // );

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('camera'),
        backgroundColor: Colors.orange,
      ),
      body: CameraPage(
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: camera,
      ),
      // body: Center(
      //   child: Column(
      //     children: <Widget>[
      //       // Back Button
      //       ElevatedButton(
      //           onPressed: () {
      //             Navigator.pop(context);
      //           },
      //           child: Text('Go Back')),
      //     ],
      //   ),
      // ),
    );
  }
}

// Camera Page - hosts the camera and a search bar to add food items to User's food tracker
class CameraPage extends StatefulWidget {
  const CameraPage({
    Key? key,
    required this.camera,
  }) : super(key: key);

  final CameraDescription camera;

  @override
  CameraPageState createState() => CameraPageState();

  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('camera'),
  //       backgroundColor: Colors.orange,
  //     ),
  //     body: Center(
  //       child: Column(
  //         children: <Widget>[
  //           // Back Button
  //           ElevatedButton(
  //               onPressed: () {
  //                 Navigator.pop(context);
  //               },
  //               child: Text('Go Back')),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

class CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    //CameraController displays current output of camera
    _controller = CameraController(
      widget.camera, //Gets camera from available cameras
      ResolutionPreset.medium, //Resolution to use
    );

    _initializeControllerFuture = _controller
        .initialize(); //Initializes the controller and returns a Future
  }

  @override
  void dispose() {
    //Disposes of the CameraController when widget is disposed
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      //Using a FutureBuilder to wait until controller is initialzed before displaying camera preview
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            //Future is complete, so display the preview
            return CameraPreview(_controller);
          } else {
            //Future is not complete, so display loading
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          //Take the picture
          try {
            await _initializeControllerFuture; //Wait and make sure camera is initialized

            final image =
                await _controller.takePicture(); //Attempt to take a picture

            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  imagePath: image
                      .path, //Pass the image path to DisplayPictureScreen widget
                ),
              ),
            );
          } catch (e) {
            print(e); //Prints error if an error occurs trying to take picture
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

// Widget to display the picture taken by user
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Picture')),
      body: Image.file(File(
          imagePath)), //Image has been stored as Image.file on the device. Use the image path to display the image
    );
  }
}

// Profile Page - Shows first and last name, recipes, and history stats of User's food items (?)
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('profile'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            // Back Button
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Go Back')),
          ],
        ),
      ),
    );
  }
}
