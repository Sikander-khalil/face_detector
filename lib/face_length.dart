import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class FaceDetectorPage extends StatefulWidget {
  @override
  _FaceDetectorPageState createState() => _FaceDetectorPageState();
}

class _FaceDetectorPageState extends State<FaceDetectorPage> {
  FaceDetector faceDetector = GoogleMlKit.vision.faceDetector();
  XFile? imageFile;

  @override
  void dispose() {
    faceDetector.close();
    super.dispose();
  }

  Future<void> _pickImage() async {
    XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        imageFile = file;
      });
    }
  }

  Future<void> _detectFaces() async {
    if (imageFile != null) {
      InputImage inputImage = InputImage.fromFilePath(imageFile!.path);
      List<Face> faces = await faceDetector.processImage(inputImage);

      print('Number of faces detected: ${faces.length}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Face Detector"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (imageFile != null)
              Image.file(
                File(imageFile!.path),
                width: 350,
                height: 450,
                fit: BoxFit.contain,
              ),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text("Pick an Image"),
            ),
            ElevatedButton(
              onPressed: _detectFaces,
              child: Text("Detect Faces"),
            ),
          ],
        ),
      ),
    );
  }
}
