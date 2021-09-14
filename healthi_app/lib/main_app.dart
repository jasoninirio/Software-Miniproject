// Home page screen

import 'package:flutter/material.dart';

// final controller = PageController(
//   initialPage: 1,
// );

// final pageView = PageView(
//   controller: controller,
//   children: [
//     CameraPage(),
//     HomePage(),
//     ProfilePage(),
//   ],
// );

class App_PageView extends StatefulWidget {
  @override
  _App_PageViewState createState() => _App_PageViewState();
}

class _App_PageViewState extends State<App_PageView> {
  PageController _controller = PageController(initialPage: 1);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      children: [
        CameraPage(),
        HomePage(),
        ProfilePage(),
      ],
    );
  }
}

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.green,
//         centerTitle: true,
//         title: Text("Healthi"),
//       ),
//     );
//   }
// }

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('healthi'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            // Camera Button
            // ElevatedButton(
            //     onPressed: () {
            //       Navigator.pushNamed(context, '/camera');
            //     },
            //     child: Text('Camera')),

            // // Profile Button
            // ElevatedButton(
            //     onPressed: () {
            //       Navigator.pushNamed(context, '/profile');
            //     },
            //     child: Text('Profile')),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('profile'),
        centerTitle: true,
        backgroundColor: Colors.yellow,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            // Camera Button
            // ElevatedButton(
            //     onPressed: () {
            //       Navigator.pushNamed(context, '/camera');
            //     },
            //     child: Text('Camera')),

            // // Profile Button
            // ElevatedButton(
            //     onPressed: () {
            //       Navigator.pushNamed(context, '/profile');
            //     },
            //     child: Text('Profile')),
          ],
        ),
      ),
    );
  }
}

class CameraPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('camera'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            // Camera Button
            // ElevatedButton(
            //     onPressed: () {
            //       Navigator.pushNamed(context, '/camera');
            //     },
            //     child: Text('Camera')),

            // // Profile Button
            // ElevatedButton(
            //     onPressed: () {
            //       Navigator.pushNamed(context, '/profile');
            //     },
            //     child: Text('Profile')),
          ],
        ),
      ),
    );
  }
}
