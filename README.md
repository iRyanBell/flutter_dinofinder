# DinoFinder

A machine learning model for native mobile devices to perform dinosaur image classification using TensorFlow Lite and Flutter.

![Sample image](https://user-images.githubusercontent.com/25379378/68825509-31729f80-064f-11ea-9adf-3f4e627f5aa9.png)

## Install dependencies:

```bash
flutter pub get
```

## Run:

```bash
flutter run
```

## Limitations:

We aim to perform dinosaur classification across a range of artist renderings for a small set of well-known species of dinosaurs. Acquiring the training data, filtering out the best-representational imagery, and generalizing the features between results is not a simple task. Our current model was trained on just a few hundred samples for each label type, limiting the accuracy of the model. We hope to expand our dataset to improve the model accuracy using a wider collection of publicly available renderings on the web.
