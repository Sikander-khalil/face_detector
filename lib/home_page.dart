import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final GlobalKey<ScaffoldMessengerState> _scaffoldMKey = GlobalKey<ScaffoldMessengerState>();
  bool faceDetectorChecking = false;
  XFile? imageFile;
  String faceSmiling = "";
  String headRotation = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text("Home Page"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(

        child: Container(
          margin: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              if(faceDetectorChecking)
                CircularProgressIndicator.adaptive(),
              if(!faceDetectorChecking && imageFile == null)
                Container(
                  width: 300,
                  height: 300,
                  color: Colors.grey[400],
                  child: Center(
                    child: Text("Pick a Image of a Person Face"),
                  ),
                ),
              if(imageFile != null && !faceDetectorChecking)
                Image.file(
                  File(imageFile!.path),
                  width: 350,
                  height: 450,
                  fit: BoxFit.contain,

                ),
              Row(
                children: [
                  Expanded(
                      child: Padding(padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: ElevatedButton.icon(

                      onPressed: (){
                    onPickBtnImgSelected(btnName: 'Camera');
                      },
                      icon: Icon(Icons.camera_alt),
                      label: Text("Camera"))

                  )),
                  Expanded(
                      child: Padding(padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: ElevatedButton.icon(

                              onPressed: (){
                                onPickBtnImgSelected(btnName: 'Gallery');
                              },
                              icon: Icon(Icons.image_rounded),
                              label: Text("Gallery"))

                      )
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.all(20.0),
              child: Center(
                child: Text(faceSmiling, style: TextStyle(fontSize: 20),),
              ),

              ),



          ],),
        ),
      ),
    );


  }
  void onPickBtnImgSelected({required String btnName}) async{

    ImageSource imageSource;
    if(btnName == "Camera"){
      imageSource = ImageSource.camera;

    }else{
      imageSource = ImageSource.gallery;

    }
    final scaffoldState = _scaffoldMKey.currentState;
    try{
      XFile? file = await ImagePicker().pickImage(source: imageSource);
      if(file != null){

        faceDetectorChecking = true;
        imageFile = file;
        setState(() {

        });
        getImageFaceDetection(file);
      }

    }catch(e){

      faceDetectorChecking = false;
      imageFile = null;
      faceSmiling = "Error Occurred while gettimg image";
      scaffoldState?.showSnackBar(SnackBar(content: Text(e.toString()),
      duration: Duration(seconds: 4),


      ));
      setState(() {

      });

    }


  }

  void getImageFaceDetection(XFile source) async{
    final faceDetector = GoogleMlKit.vision.faceDetector(FaceDetectorOptions(

      enableClassification: true,
      enableLandmarks: true,
      enableContours: true,
      enableTracking: true,
    ));
    final InputImage inputImage = InputImage.fromFilePath(source.path);

    final List<Face> faces = await faceDetector.processImage(inputImage);
    double? smileProb = 0.0;
    for(Face face in faces){
      if(face.smilingProbability != null){

        smileProb = face.smilingProbability;
        print("This is smile prob $smileProb");

        if(smileProb != null && smileProb < 0.45){
          faceSmiling = "You are 😒";


        }
        if(smileProb != null && smileProb >= 0.45){
          faceSmiling = "You are 😊";


        }

        if(smileProb != null && smileProb >= 0.75){
          faceSmiling = "You are 😁";


        }

        if(smileProb != null && smileProb >= 0.86){
          faceSmiling = "You are 🤣";


        }
      }

    }
    faceDetector.close();
    faceDetectorChecking = false;
    setState(() {

    });


  }
}
