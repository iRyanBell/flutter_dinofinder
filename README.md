# DinoFinder

A machine learning model for native mobile devices to perform dinosaur image classification using TensorFlow Lite and Flutter.

**Supported species**:

- Ankylosaurus
- Brachiosaurus
- Dilophosaurus
- Dimetrodon
- Iguanodon
- Protoceratops
- Pteranodon
- Spinosaurus
- Stegosaurus
- Triceratops
- Tyrannosaurus
- Velociraptor

![Screenshot](https://user-images.githubusercontent.com/25379378/68976451-a1e20380-07aa-11ea-8955-b745dafc445e.png)

[View Demo](https://github.com/iRyanBell/flutter_dinofinder/raw/master/demo.mp4)

## Install dependencies:

```bash
flutter pub get
```

## Run:

```bash
flutter run
```

## Methods:

The camera from a user's mobile device is used to capture a square, center-cropped image. This image is rescaled with bicubic interpolation down to a 224x224px image. The pretrained model performs a prediction on this data as a standarized 3-channel RGB matrix. The prediction result with the highest confidence score is then overlaid onto the user interface.

## Image scraper:

To collect training data-set for dinosaur image classification, the image scraper that efficiently collects image data is implemented. The image scraper link is as follows:
[Google Image Scraper](https://github.com/parang17/Google_image_downloader)

## Machine Learning(ML) model 
The ML model uses mobilenet provided by Tensorflow. The following link has the ML model.
[Dinosaur classification model](https://github.com/parang17/dinosaur_classification)


## Limitations:

We aim to perform dinosaur classification across a range of artist renderings for a small set of well-known species of dinosaurs. Acquiring the training data, filtering out the best-representational imagery, and generalizing the features between results is not a simple task. Our current model was trained on just a few hundred samples for each label type, limiting the accuracy of the model. We hope to expand our dataset over the coming months to improve the model accuracy using a wider collection of publicly available renderings on the web, then publish the application as a free download for iOS and Android devices.

## Credits:

This work was completed by [Youngjun Choi](https://www.linkedin.com/in/dr-youngjun-choi/) and [Ryan Bell](https://www.linkedin.com/in/iryanbell/).
