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

  @override
  void initState() {
    super.initState();
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
                                  border: Border.all(color: Colors.blueAccent)),
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
                  child: Text('Loading Camera...'),
                )),
    );
  }
}
