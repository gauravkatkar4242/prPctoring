import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proctoring/camera/bloc/camera_bloc.dart';

class Camera extends StatefulWidget {
  const Camera({Key? key}) : super(key: key);

  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> with WidgetsBindingObserver {
  late CameraBloc bloc;

  @override
  void didChangeDependencies() {
    bloc = context.read<CameraBloc>();
    bloc.add(InitCameraEvent());
    WidgetsBinding.instance!.addObserver(this);
    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive) {
      print("inactive called************");
      context
          .read<CameraBloc>()
          .add(DisposeCameraEvent()); // Free up memory when camera not active
    } else if (state == AppLifecycleState.resumed) {
      print("Resume called************");
      context.read<CameraBloc>().add(
          InitCameraEvent()); // Reinitialize the camera with same properties
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    bloc.add(DisposeCameraEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(
      child: BlocBuilder<CameraBloc, CameraState>(
        builder: (context, state) {
          print(state.toString() + "***************");

          if (state is CameraInitializingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is CameraExceptionState) {
            return Center(
              child: Text(state.errorMsg),
            );
          } else if (state is CameraDisposedState) {
            return const CircularProgressIndicator();
          } else if (state is CameraReadyState) {
            return Stack(
              children: [
                _cameraView(state),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    onPressed: () =>
                        context.read<CameraBloc>().add(CaptureImageEvent()),
                    child: const Icon(Icons.camera),
                  ),
                )
              ],
            );
          }
          else if (state is CapturingImageInProgressState){
            return Stack(
              children: [
                _cameraView(state),
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: CircularProgressIndicator(color: Colors.red,)
                )
              ],
            );

          }
          return const Text("Something is Wrong");
        },
      ),
    ));
  }

  Widget _cameraView(state) {
    return LayoutBuilder(builder: (context, constraints) {
      return kIsWeb
          /* for camera screen web  👇*/
          ? AspectRatio(
              aspectRatio: (constraints.maxWidth / constraints.maxHeight),
              child: CameraPreview(state.controller!))

          /* for camera screen mobile 👇*/
          : Transform.scale(
              scale: 1 /
                  (state.controller!.value.aspectRatio *
                      (constraints.maxWidth / constraints.maxHeight)),
              alignment: Alignment.topCenter,
              child: CameraPreview(state.controller));
    });
  }
}
