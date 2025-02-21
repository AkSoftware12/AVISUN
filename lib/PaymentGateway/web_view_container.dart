import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'atom_pay_helper.dart';

class WebViewContainer extends StatefulWidget {
  final mode;
  final payDetails;
  final responsehashKey;
  final responseDecryptionKey;

  WebViewContainer(this.mode, this.payDetails, this.responsehashKey,
      this.responseDecryptionKey);

  @override
  createState() => _WebViewContainerState(this.mode, this.payDetails,
      this.responsehashKey, this.responseDecryptionKey);
}

class _WebViewContainerState extends State<WebViewContainer> {
  final mode;
  final payDetails;
  final _responsehashKey;
  final _responseDecryptionKey;
  final _key = UniqueKey();
  late InAppWebViewController _controller;

  final Completer<InAppWebViewController> _controllerCompleter =
      Completer<InAppWebViewController>();

  @override
  void initState() {
    super.initState();
    // if (Platform.isAndroid) WebView.platform  = SurfaceAndroidViewController();
  }

  _WebViewContainerState(this.mode, this.payDetails, this._responsehashKey,
      this._responseDecryptionKey);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _handleBackButtonAction(context),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          elevation: 0,
          toolbarHeight: 2,
        ),
        body: SafeArea(
            child: InAppWebView(
          // initialUrl: 'about:blank',
          key: UniqueKey(),
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform:
                InAppWebViewOptions(useShouldOverrideUrlLoading: true),
          ),
          onWebViewCreated: (InAppWebViewController inAppWebViewController) {
            _controllerCompleter.future.then((value) => _controller = value);
            _controllerCompleter.complete(inAppWebViewController);

            debugPrint("payDetails from webview $payDetails");
            _loadHtmlFromAssets(mode);
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            debugPrint("shouldOverrideUrlLoading called");
            var uri = navigationAction.request.url!;
            debugPrint(uri.scheme);
            if (["upi"].contains(uri.scheme)) {
              debugPrint("UPI URL detected");
              // Launch the App
              await launchUrl(
                uri,
              );
              // and cancel the request
              return NavigationActionPolicy.CANCEL;
            }
            return NavigationActionPolicy.ALLOW;
          },

          onLoadStop: (controller, url) async {
            debugPrint("onloadstop_url: $url");

            if (url.toString().contains("AIPAYLocalFile")) {
              debugPrint(" AIPAYLocalFile Now url loaded: $url");
              await _controller.evaluateJavascript(
                  source: "openPay('" + payDetails + "')");
            }

            if (url.toString().contains('/mobilesdk/param')) {
              final String response = await _controller.evaluateJavascript(
                  source: "document.getElementsByTagName('h5')[0].innerHTML");
              debugPrint("HTML response : $response");
              var transactionResult = "";
              if (response.trim().contains("cancelTransaction")) {
                transactionResult = "Transaction Cancelled!";
              } else {
                final split = response.trim().split('|');
                final Map<int, String> values = {
                  for (int i = 0; i < split.length; i++) i: split[i]
                };

                final splitTwo = values[1]!.split('=');
                const platform = MethodChannel('flutter.dev/NDPSAESLibrary');

                try {
                  final String result =
                      await platform.invokeMethod('NDPSAESInit', {
                    'AES_Method': 'decrypt',
                    'text': splitTwo[1].toString(),
                    'encKey': _responseDecryptionKey
                  });
                  var respJsonStr = result.toString();
                  Map<String, dynamic> jsonInput = jsonDecode(respJsonStr);
                  debugPrint("read full respone : $jsonInput");

                  //calling validateSignature function from atom_pay_helper file
                  var checkFinalTransaction =
                      validateSignature(jsonInput, _responsehashKey);

                  if (checkFinalTransaction) {
                    if (jsonInput["payInstrument"]["responseDetails"]
                                ["statusCode"] ==
                            'OTS0000' ||
                        jsonInput["payInstrument"]["responseDetails"]
                                ["statusCode"] ==
                            'OTS0551') {
                      debugPrint("Transaction success");
                      transactionResult = "Transaction Success";
                    } else {
                      debugPrint("Transaction failed");
                      transactionResult = "Transaction Failed";
                    }
                  } else {
                    debugPrint("signature mismatched");
                    transactionResult = "failed";
                  }
                  debugPrint("Transaction Response : $jsonInput");
                } on PlatformException catch (e) {
                  debugPrint("Failed to decrypt: '${e.message}'.");
                }
              }
              _closeWebView(context, transactionResult);
            }
          },
        )),
      ),
    );
  }

  _loadHtmlFromAssets(mode) async {
    final localUrl =
        mode == 'uat' ? "assets/aipay_uat.html" : "assets/aipay_prod.html";
    String fileText = await rootBundle.loadString(localUrl);
    _controller.loadUrl(
        urlRequest: URLRequest(
            url: Uri.dataFromString(fileText,
                mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))));
  }

  _closeWebView(context, transactionResult) {
    // ignore: use_build_context_synchronously
    Navigator.pop(context); // Close current window
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Transaction Status = $transactionResult")));
  }

  Future<bool> _handleBackButtonAction(BuildContext context) async {
    debugPrint("_handleBackButtonAction called");
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Do you want to exit the payment ?'),
              actions: <Widget>[
                // ignore: deprecated_member_use
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('No'),
                ),
                // ignore: deprecated_member_use
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).pop(); // Close current window
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            "Transaction Status = Transaction cancelled")));
                  },
                  child: const Text('Yes'),
                ),
              ],
            ));
    return Future.value(true);
  }
}
