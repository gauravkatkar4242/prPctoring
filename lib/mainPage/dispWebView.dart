import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webviewx/webviewx.dart';

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
              controller: nameController..text = "https://jombay.com/",
              onChanged: (v) => nameController.text = v,
              decoration: const InputDecoration(labelText: "Enter URL here")),
          ElevatedButton(
            child: const Text("SUBMIT"),
            onPressed: () {
              setState(() {
                url = nameController.text;
              });
            },
          ),
        ],
      );
    } else {
      return LayoutBuilder(builder: (context, constraints) {
        return Stack(
          children: [
            WebViewX(
              initialContent: url,
              initialSourceType: SourceType.url,
              onWebViewCreated: (controller) => webViewController = controller,
              height: constraints.maxHeight,
              width: constraints.maxWidth,
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    var canGoBack = await webViewController.canGoBack();
                    if (canGoBack) {
                      webViewController.goBack();
                    }
                  },
                  child: const Icon(Icons.arrow_back),
                ),
                ElevatedButton(
                  onPressed: () async {
                    var canGoBack = await webViewController.canGoForward();
                    if (canGoBack) {
                      webViewController.goForward();
                    }
                  },
                  child: const Icon(Icons.arrow_forward),
                )
              ],
            ),
          ],
        );
      });
    }
  }
}
