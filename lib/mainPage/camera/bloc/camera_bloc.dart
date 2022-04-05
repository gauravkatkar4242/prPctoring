import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:proctoring/timer.dart';

import '../mobile_helper.dart' if (dart.library.html) '../web_helper.dart' as helper;

part 'camera_event.dart';

part 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraController? _controller;
  final Timer _timer = const Timer();
  StreamSubscription<int>? _timerSubscription;
  int totalRecordingTime = 10;

  CameraBloc() : super(CameraInitial()) {
    on<CameraEvent>((event, emit) {});
    on<InitCameraEvent>(_initCamera);
    on<TimerTickedEvent>(_onTimerTicked);
    on<CaptureImageEvent>(_captureImage);
    on<AppDefocusEvent>(_onDefocused);
    on<AppFocusEvent>(_onFocused);
    on<DisposeCameraEvent>(_disposeCamera);
  }

  Future<void> _initCamera(
      InitCameraEvent event, Emitter<CameraState> emit) async {
    debugPrint("--- Event :- _initCamera :: Current State :- $state");
    emit(const CameraInitializingState(null));
    try {
      var cameraList =
          await availableCameras(); // gets all available cameras from device

      if (_controller != null) {
        _timerSubscription?.cancel();
        await _controller!.dispose();
      }
      CameraDescription? cameraDescription;
        for (var camera in cameraList) {
          if (camera.lensDirection == CameraLensDirection.external || camera.lensDirection == CameraLensDirection.front){
            cameraDescription = camera;
            break;
          }
        }

      if (cameraDescription == null){
        emit(const CameraExceptionState("No Camera Found!!!"));
        return;
      }
    final CameraController cameraController = CameraController(
        cameraDescription,
        ResolutionPreset.medium,
        enableAudio: true,
      );
      _controller = cameraController;
      if (cameraController.value.hasError) {
        emit(CameraExceptionState(
            cameraController.value.errorDescription.toString()));
      }
      await cameraController.initialize();
      emit(CameraReadyState(cameraController));
      _timerSubscription?.cancel();
      _timerSubscription = _timer
          .countDownTimer(timeRemaining: totalRecordingTime)
          .listen((duration) => add(TimerTickedEvent(duration: duration)));
    } on CameraException catch (e) {
      emit(CameraExceptionState(e.description.toString()));
    }
  }

  void _onTimerTicked(TimerTickedEvent event, Emitter<CameraState> emit) {
    debugPrint("_timerTicked ${event.duration}");
    if (event.duration % 5 == 0) {
      add(CaptureImageEvent());
    }
  }

  void _onDefocused(AppDefocusEvent event, Emitter<CameraState> emit){
    emit(AppDefocusdState(_controller));
  }
  void _onFocused(AppFocusEvent event, Emitter<CameraState> emit){
    emit(CameraReadyState(_controller));
  }
  Future<void> _captureImage(
      CaptureImageEvent event, Emitter<CameraState> emit) async {
    debugPrint("--- Event :- _captureImage :: CurrentState :- $state");
    var beforeCapturingState = state;
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    if (_controller!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return;
    }
    try {
      emit(CapturingImageInProgressState(_controller));
      final XFile capturedImage = await _controller!.takePicture();
      await saveImage(capturedImage);
      if (beforeCapturingState is AppDefocusdState){
        emit(AppDefocusdState(_controller));
      }
      else{
        emit(CameraReadyState(_controller));
      }

    } on CameraException catch (e) {
      //will set state to CameraExceptionState state
      emit(CameraExceptionState(e.description.toString()));
    }
  }

  Future<void> saveImage(XFile image) async {
    // Image img = Image.file(File(file.path));
    // io.File image = io.File(file.path);
    if (kIsWeb) {
      image.saveTo("path");
    } else {
      await GallerySaver.saveImage(image.path,albumName: '/');
      print(image.name);
      Image a;
      var faces = await helper.getNumberOfFaces(image);
    }
  }



  Future<void> paletteGenerator() async {
    List<String> l = [
      "white.png",
      "black.jpeg",
      "blue.jpg",
      "green.png",
      "red.jpeg",
      "o1.jpeg"
    ];
    for (var name in l) {
      String imgPath = "assets/" + name;
      PaletteGenerator color =
          await PaletteGenerator.fromImageProvider(AssetImage(imgPath));
      print(name + " : " + color.dominantColor.toString());
      print("*******************************");
    }
  }

  Future<void> _disposeCamera(
      DisposeCameraEvent event, Emitter<CameraState> emit) async {
    debugPrint("--- Event :- _disposeCamera :: CurrentState :- $state");
    if (_controller != null) {
      await _controller?.dispose();
      debugPrint("Camera Disposed");
    }
    _timerSubscription?.cancel();
    emit(CameraDisposedState());
  }
}
