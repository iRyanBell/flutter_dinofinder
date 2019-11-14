import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as im;
import 'package:tflite/tflite.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

Future<List<CameraDescription>> getAvailableCameras() async {
  List<CameraDescription> cameras = await availableCameras();
  return cameras;
}

Uint8List imageToByteListFloat32(
    im.Image image, int inputSize, double mean, double std) {
  Float32List convertedBytes = Float32List(1 * inputSize * inputSize * 3);
  Float32List buffer = Float32List.view(convertedBytes.buffer);
  int pixelIndex = 0;
  for (int i = 0; i < inputSize; i++) {
    for (int j = 0; j < inputSize; j++) {
      int pixel = image.getPixel(j, i);
      buffer[pixelIndex++] = (im.getRed(pixel) - mean) / std;
      buffer[pixelIndex++] = (im.getGreen(pixel) - mean) / std;
      buffer[pixelIndex++] = (im.getBlue(pixel) - mean) / std;
    }
  }
  return convertedBytes.buffer.asUint8List();
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
  String result = '';

  void activateDetector() {
    getAvailableCameras().then((cameras) {
      Tflite.loadModel(
              model: "assets/dinofinder.tflite",
              labels: "assets/dinofinder.txt",
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

  Future<void> captureImage() async {
    // Clear previous result
    setState(() {
      result = '';
    });

    final path = join(
      // Store the picture in the temp directory.
      // Find the temp directory using the `path_provider` plugin.
      (await getTemporaryDirectory()).path,
      '${DateTime.now()}.png',
    );
    await controller.takePicture(path);

    im.Image image = im.decodeImage(File(path).readAsBytesSync());
    int cropSize = min(image.width, image.height);
    int offsetX = (image.width - min(image.width, image.height)) ~/ 2;
    int offsetY = (image.height - min(image.width, image.height)) ~/ 2;

    im.Image imageSquare =
        im.copyCrop(image, offsetX, offsetY, cropSize, cropSize);

    int imgSize = 224;
    im.Image imageResized = im.copyResize(imageSquare,
        width: imgSize, height: imgSize, interpolation: im.Interpolation.cubic);
    Tflite.runModelOnBinary(
            binary: imageToByteListFloat32(imageResized, imgSize, 127.5, 127.5))
        .then((recognitions) {
      if (recognitions.length > 0) {
        print(recognitions.first);

        // Display new result
        setState(() {
          result = recognitions.first['label'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('DinoFinder'),
      ),
      backgroundColor: Color.fromARGB(255, 25, 25, 27),
      body: Center(
          child: isCameraReady
              ? Stack(
                  children: <Widget>[
                    Image.asset('assets/images/bkg.jpg',
                        width: size.width,
                        height: size.height,
                        fit: BoxFit.cover),
                    Center(
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.green.withAlpha(64),
                                  offset: Offset(0.0, 0.0),
                                  blurRadius: 64.0)
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: ClipRect(
                                child: Transform.scale(
                                  scale: 1 / controller.value.aspectRatio,
                                  child: Center(
                                    child: AspectRatio(
                                      aspectRatio: controller.value.aspectRatio,
                                      child: CameraPreview(controller),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )),
                    ),
                    Center(
                      child: result.length > 0
                          ? Container(
                              decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .secondaryHeaderColor
                                      .withAlpha(127),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4))),
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(result,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 32.0)),
                              ),
                            )
                          : Container(),
                    )
                  ],
                )
              : Container(
                  child: Stack(
                  children: <Widget>[
                    Image.asset('assets/images/bkg.jpg',
                        width: size.width,
                        height: size.height,
                        fit: BoxFit.cover),
                    Center(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 32.0),
                            child: Image.asset('assets/images/logo.png',
                                width: size.width * 0.9, fit: BoxFit.fill),
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                                  top: 8.0, left: 32.0, right: 32.0),
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
                    )
                  ],
                ))),
      floatingActionButton: Container(
          height: 96,
          width: 96,
          child: FittedBox(
              child: FloatingActionButton(
            backgroundColor: Colors.green.shade800,
            child: Icon(
              isCameraReady ? Icons.camera_alt : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              isCameraReady ? captureImage() : activateDetector();
            },
          ))),
    );
  }
}
