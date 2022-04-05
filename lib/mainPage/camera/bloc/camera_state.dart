part of 'camera_bloc.dart';

abstract class CameraState extends Equatable {
  const CameraState();
  @override
  List<Object> get props => [];
}
class CameraInitial extends CameraState {
}
class CameraInitializingState extends CameraState{
  final CameraController? controller;
  const CameraInitializingState(this.controller);
}
class CameraReadyState extends CameraState{
  final CameraController? controller;
  const CameraReadyState(this.controller);
}
class CapturingImageInProgressState extends CameraState{
  final CameraController? controller;
  const CapturingImageInProgressState(this.controller);
}
class CameraExceptionState extends CameraState{
  final String errorMsg;
  const CameraExceptionState(this.errorMsg);
}

class AppDefocusdState extends CameraState{
  final CameraController? controller;
  const AppDefocusdState(this.controller);
}
class CameraDisposedState extends CameraState{}