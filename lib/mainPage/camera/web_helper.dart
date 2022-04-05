import 'dart:html';

import 'package:camera/camera.dart';

import 'bloc/camera_bloc.dart';
import 'camera.dart';

XFile convertXfileToFile(XFile file) {
  print("No Implemetation for web for convertXfileToFile");
  return file;
}

Future<int> getNumberOfFaces(XFile image) async {
  return 0;
}

void addEventListener(){
  window.addEventListener('focus', _onFocus);
  window.addEventListener('blur', _onBlur);
}

void removeEventListener(){
  window.removeEventListener('focus', _onFocus);
  window.removeEventListener('blur', _onBlur);
}

void _onFocus(Event e) {
  print("on Focus -------------------------------------------------------");
}

void _onBlur(Event e) {
 print("on Blur -------------------------------------------------------");
}