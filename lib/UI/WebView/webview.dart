import 'package:avi/constants.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class WebViewExample extends StatefulWidget {
  final String title;
  final String url;
  const WebViewExample({super.key, required this.title, required this.url});

  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  late WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(widget.title,style: TextStyle(color: Colors.white),),
      ),
      body: WebView(
        initialUrl: widget.url, // Your URL here
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller = webViewController;
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     _controller.reload(); // Reload the web view
      //   },
      //   child: Icon(Icons.refresh),
      // ),
    );
  }
}
