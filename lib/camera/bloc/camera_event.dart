part of 'camera_bloc.dart';

abstract class CameraEvent extends Equatable {
  const CameraEvent();
  @override
  List<Object?> get props => [];
}

class InitCameraEvent extends CameraEvent{}

class TimerTickedEvent extends CameraEvent{
  final int duration;
  const TimerTickedEvent({required this.duration});
}
class CaptureImageEvent extends CameraEvent{}
class DisposeCameraEvent extends CameraEvent{}