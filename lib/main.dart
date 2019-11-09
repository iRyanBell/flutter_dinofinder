import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';

void main() => runApp(MyApp());

Future<List<CameraDescription>> getAvailableCameras() async {
  List<CameraDescription> cameras = await availableCameras();
  return cameras;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MaterialApp(
      title: 'DinoFinder',
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 78, 0, 160),
        secondaryHeaderColor: Color.fromARGB(255, 160, 0, 160),
        brightness: Brightness.dark,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CameraController controller;
  bool isCameraReady = false;
  Map result = {};

  void activateDetector() {
    getAvailableCameras().then((cameras) {
      Tflite.loadModel(
              model: "assets/ssd_mobilenet.tflite",
              labels: "assets/ssd_mobilenet.txt",
              numThreads: 1)
          .then((_) {
        controller = CameraController(cameras[0], ResolutionPreset.medium);
        controller.initialize().then((_) {
          setState(() {
            isCameraReady = true;
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (isCameraReady) {
      controller.startImageStream((CameraImage img) {
        try {
          Tflite.detectObjectOnFrame(
                  model: "SSDMobileNet",
                  bytesList: img.planes.map((plane) => plane.bytes).toList(),
                  imageHeight: img.height,
                  imageWidth: img.width,
                  threshold: 0.5)
              .then((recognitions) {
            if (recognitions.length > 0) {
              print(recognitions[0]);
              setState(() {
                result = recognitions[0];
              });
            }
          });
        } catch (err) {
          print(err);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('DinoFinder'),
      ),
      backgroundColor: Color.fromARGB(255, 25, 25, 27),
      body: Center(
          child: isCameraReady
              ? Stack(
                  children: <Widget>[
                    CameraPreview(controller),
                    result.containsKey('detectedClass')
                        ? Positioned(
                            top: size.height * result['rect']['y'],
                            left: size.width * result['rect']['x'],
                            child: Container(
                              width: size.width * result['rect']['w'],
                              height: size.height * result['rect']['h'],
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 4.0,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor)),
                              child: Center(
                                child: Text(
                                  result['detectedClass'],
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 21.0),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            height: size.height,
                            width: size.width,
                            child: Center(
                              child: Text(
                                'Searching for dinosaurs!',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 21.0),
                              ),
                            ),
                          )
                  ],
                )
              : Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset('assets/images/bkg.png',
                          width: size.width * 0.9, fit: BoxFit.fill),
                      Padding(
                          padding: EdgeInsets.only(
                              top: 32.0, left: 32.0, right: 32.0),
                          child: Text('Dinosaur classification',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold))),
                      Padding(
                          padding: EdgeInsets.only(left: 32.0, right: 32.0),
                          child: Text('Click the Search Button to begin!',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 18.0)))
                    ],
                  ),
                )),
      floatingActionButton: isCameraReady
          ? Container()
          : FloatingActionButton(
              backgroundColor: Theme.of(context).secondaryHeaderColor,
              child: Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () {
                activateDetector();
              },
            ),
    );
  }
}
