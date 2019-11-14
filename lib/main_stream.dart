import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as im;
import 'package:tflite/tflite.dart';

void main() => runApp(MyApp());

Future<List<int>> convertImagetoPng(CameraImage image) async {
  try {
    im.Image img;
    if (image.format.group == ImageFormatGroup.yuv420) {
      img = _convertYUV420(image);
    } else if (image.format.group == ImageFormatGroup.bgra8888) {
      img = _convertBGRA8888(image);
    }

    im.PngEncoder pngEncoder = new im.PngEncoder();

    // Convert to png
    List<int> png = pngEncoder.encodeImage(img);
    return png;
  } catch (e) {
    print(">>>>>>>>>>>> ERROR:" + e.toString());
  }
  return null;
}

// CameraImage BGRA8888 -> PNG
// Color
im.Image _convertBGRA8888(CameraImage image) {
  var img = im.Image.fromBytes(
    image.width,
    image.height,
    image.planes[0].bytes,
    format: im.Format.bgra,
  );
  return im.copyResize(img, width: 300, height: 300);
}

// CameraImage YUV420_888 -> PNG -> Image (compresion:0, filter: none)
// Black
im.Image _convertYUV420(CameraImage image) {
  var img = im.Image(image.width, image.height); // Create Image buffer

  Plane plane = image.planes[0];
  const int shift = (0xFF << 24);

  // Fill image buffer with plane[0] from YUV420_888
  for (int x = 0; x < image.width; x++) {
    for (int planeOffset = 0;
        planeOffset < image.height * image.width;
        planeOffset += image.width) {
      final pixelColor = plane.bytes[planeOffset + x];
      // color: 0x FF  FF  FF  FF
      //           A   B   G   R
      // Calculate pixel color
      var newVal = shift | (pixelColor << 16) | (pixelColor << 8) | pixelColor;

      img.data[planeOffset + x] = newVal;
    }
  }

  return im.copyResize(img, width: 300, height: 300);
}

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
              model: "assets/dinofinder.tflite",
              labels: "assets/dinofinder.txt",
              numThreads: 1)
          .then((_) {
        controller = CameraController(cameras[0], ResolutionPreset.low);
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
      controller.startImageStream((CameraImage img) async {
        try {
          List<int> imgData = await convertImagetoPng(img);
          Tflite.runModelOnBinary(binary: imgData).then((recognitions) {
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
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          color: Colors.black,
                          width: size.width,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              result.containsKey('label')
                                  ? result['label']
                                  : 'Searching for dinosaurs!',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 21.0),
                            ),
                          ),
                        ),
                      ],
                    ),
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
