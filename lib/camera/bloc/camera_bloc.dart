import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:palette_generator/palette_generator.dart';
// import 'package:gallery_saver/gallery_saver.dart';
import 'package:proctoring/timer.dart';

part 'camera_event.dart';

part 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraController? _controller;
  final Timer _timer = const Timer();
  StreamSubscription<int>? _timerSubscription;
  int totalRecordingTime = 20;

  CameraBloc() : super(CameraInitial()) {
    on<CameraEvent>((event, emit) {});
    on<InitCameraEvent>(_initCamera);
    on<TimerTickedEvent>(_onTimerTicked);
    on<CaptureImageEvent>(_captureImage);
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
      CameraDescription cameraDescription;
      if (cameraList.length == 1) {
        cameraDescription = cameraList[0]; // for desktop
      } else {
        cameraDescription = cameraList[1]; // for mobile select front camera
      }

      final CameraController cameraController = CameraController(
        cameraDescription,
        ResolutionPreset.max,
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

  Future<void> _captureImage(
      CaptureImageEvent event, Emitter<CameraState> emit) async {
    debugPrint("--- Event :- _captureImage :: CurrentState :- $state");
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    if (_controller!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return;
    }
    try {
      // emit(CapturingImageInProgressState(_controller));
      final XFile file = await _controller!.takePicture();
      print(file.name);
      print(file.path);
      Image img = Image.file(File(file.path));
      // emit(CameraReadyState(_controller));
      if (kIsWeb) {
        file.saveTo("path");
      } else {
        // GallerySaver.saveImage(file.path);
      }
      List<String> l = ["white.png", "black.jpeg", "blue.jpg", "green.png", "red.jpeg", "o1.jpeg"];
      for (var name in l) {
        String img_path = "assets/" + name;
        PaletteGenerator color = await PaletteGenerator.fromImageProvider(AssetImage(img_path));
        print(name +" : " + color.dominantColor.toString());
        print("*******************************");
      }


      // file.saveTo("path");
    } on CameraException catch (e) {
      //will set state to CameraExceptionState state
      emit(CameraExceptionState(e.description.toString()));
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
