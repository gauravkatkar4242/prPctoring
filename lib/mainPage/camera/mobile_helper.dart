
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';

File convertXfileToFile(XFile file){

  return File(file.path);

}

Future<int> getNumberOfFaces(XFile image) async {
  // final _faceDetector = GoogleMlKit.vision.faceDetector();
  // final _inputImage = InputImage.fromFile(convertXfileToFile(image));
  //
  // final List<Face> faces = await _faceDetector.processImage(_inputImage);
  //
  // int count = faces.length;
  // print("---------------------------------------------------------------Face Deteceted $count");
  return 0;
}

void addEventListener(AppLifecycleState appLifecycleState){

}

void removeEventListener(){

}