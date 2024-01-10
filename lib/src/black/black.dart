import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';


import 'navigation_controls.dart';

class WebViewApp extends StatefulWidget {
  const WebViewApp({Key? key}) : super(key: key);

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    // OneSignal
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    OneSignal.shared.setAppId("");
    OneSignal.shared
        .promptUserForPushNotificationPermission()
        .then((accepted) {});

    getSavedCookies();
    getSavedLink();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print("Started onPageStart");
          },
          onPageFinished: (String url) async {
            final String cookies = await controller
                .runJavaScriptReturningResult('document.cookie') as String;

            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString("cookies", cookies);
          },
          
        ),
      );
  }
  void getSavedLink() async {
    await SharedPreferences.getInstance();
    String link = "";
    try {
      controller.loadRequest(Uri.parse(link));
    } catch (e) {
      
    }
  }

  void getSavedCookies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedCookies = prefs.getString("cookies");
    await controller.runJavaScript('document.cookie = "$savedCookies";');
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text("Saved cookies: $savedCookies"),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        left: false,
        right: false,
        bottom: false,
        child: Stack(
          children: [
            WebViewWidget(controller: controller),
            NavigationControls(controller: controller),
          ],
        ),
      ),
    );
  }
}