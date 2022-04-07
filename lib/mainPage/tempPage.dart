import 'package:flutter/material.dart';
import 'package:proctoring/mainPage/dispWebView.dart';
import 'package:provider/src/provider.dart';
import "package:universal_html/html.dart" as html;
import 'package:webviewx/webviewx.dart';

import 'camera/bloc/camera_bloc.dart';
import 'camera/camera.dart';

class TempPage extends StatefulWidget {
  const TempPage({Key? key}) : super(key: key);

  @override
  _TempPageState createState() => _TempPageState();
}

class _TempPageState extends State<TempPage> with WidgetsBindingObserver {
  late CameraBloc bloc;

  @override
  void didChangeDependencies() {
    bloc = context.read<CameraBloc>();
    WidgetsBinding.instance!.addObserver(this);
    addEventListener();
    super.didChangeDependencies();
  }

  void addEventListener() {
    html.window.addEventListener('focus', _onFocus);
    html.window.addEventListener('blur', _onBlur);
  }

  void removeEventListener() {
    html.window.removeEventListener('focus', _onFocus);
    html.window.removeEventListener('blur', _onBlur);
  }

  void _onFocus(html.Event e) {
    didChangeAppLifecycleState(AppLifecycleState.resumed);
    print("on Focus -------------------------------------------------------");
  }

  void _onBlur(html.Event e) {
    didChangeAppLifecycleState(AppLifecycleState.inactive);
    print("on Blur -------------------------------------------------------");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive) {
      if (context.read<CameraBloc>().state is! CameraInitializingState ||
          context.read<CameraBloc>().state is! AppDefocusdState) {
        context.read<CameraBloc>().add(AppDefocusEvent());
        _showDialog(context);
      }
    }
    if (state == AppLifecycleState.resumed){
      context.read<CameraBloc>().add(InitCameraEvent());
    }

    if (state == AppLifecycleState.resumed) {}
  }

  @override
  void dispose() {
    removeEventListener();
    bloc.add(DisposeCameraEvent());
    super.dispose();
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WebViewAware(
          child: AlertDialog(
            title: const Text("Alert!!"),
            content: const Text("Don't run app in background"),
            actions: <Widget>[
              ElevatedButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                  bloc.add(AppFocusEvent());
                },
              ),
            ],
          ),
        );
      },
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: const EdgeInsets.all(5),
                  height: 200,
                  width: 150,
                  child: const Camera(),
                  color: Colors.black38,
                ),
              ],
            ),
            const Expanded(child: DisplayWebView())
          ],
        ),
      ),
    );
  }
}
