import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:webviewx/webviewx.dart';

import 'camera/bloc/camera_bloc.dart';

class DisplayWebView extends StatefulWidget {
  const DisplayWebView({Key? key}) : super(key: key);

  @override
  _DisplayWebViewState createState() => _DisplayWebViewState();
}

class _DisplayWebViewState extends State<DisplayWebView> {
  String url = "";
  TextEditingController nameController = TextEditingController();
  late WebViewXController webViewController;

  @override
  Widget build(BuildContext context) {
    if (url == "") {
      return AlertDialog(
        title: const Text("Enter URL"),
        actions: <Widget>[
          TextField(
              controller: nameController..text = "https://www.google.co.in/",
              onChanged: (v) => nameController.text = v,
              decoration: const InputDecoration(labelText: "Enter URL here")),
          ElevatedButton(
            child: const Text("SUBMIT"),
            onPressed: () {
              setState(() {
                url = nameController.text;
              });
              context.read<CameraBloc>().add(InitCameraEvent());
              context.read<CameraBloc>().add(InitTimerEvent());
            },
          ),
        ],
      );
    } else {
      return LayoutBuilder(builder: (context, constraints) {
        return WebViewX(
          initialContent: url,
          initialSourceType: SourceType.url,
          onWebViewCreated: (controller) => webViewController = controller,
          height: constraints.maxHeight,
          width: constraints.maxWidth,
        );
      });
    }
  }
}
