import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/camera_bloc.dart';


class Camera extends StatefulWidget {
  const Camera({Key? key}) : super(key: key);

  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<CameraBloc, CameraState>(
        builder: (context, state) {
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
                SizedBox(
                    height: 0,
                    width: 0,
                    child: ElevatedButton(
                        onPressed: () {},
                        child: const SizedBox(
                            child: CircularProgressIndicator()))),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    onPressed: () =>
                        context.read<CameraBloc>().add(CaptureImageEvent()),
                    child: const Icon(Icons.camera),
                  ),
                ),
              ],
            );
          } else if (state is CapturingImageInProgressState) {
            return Stack(
              children: [
                _cameraView(state),
                 Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      height: 20,
                      width: 20,
                      child: const CircularProgressIndicator(
                        color: Colors.red,
                      ),
                    ))
              ],
            );
          } else if (state is AppDefocusdState) {
            return const Center(child: Text("App running in Background"));
          }else if (state is CameraInitial) {
            return  Center(child: Column(
              children: const [
                Text("Loading"),
                CircularProgressIndicator()
              ],
            ));
          }
          return const Text("Something is Wrong");
        },
      ),
    );
  }


  Widget _cameraView(state) {
    return LayoutBuilder(builder: (context, constraints) {
      return kIsWeb
          /* for camera screen web  👇*/
          ? AspectRatio(
              aspectRatio: (constraints.maxWidth / constraints.maxHeight),
              child: CameraPreview(state.controller!))

          /* for camera screen mobile 👇*/
          : CameraPreview(state.controller);
      // Transform.scale(
      //     scale: 1 /
      //         (state.controller!.value.aspectRatio *
      //             (constraints.maxWidth / constraints.maxHeight)),
      //     alignment: Alignment.topCenter,
      //     child: CameraPreview(state.controller));
    });
  }
}
