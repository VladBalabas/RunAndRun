import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class NavigationControls extends StatefulWidget {
  NavigationControls({required this.controller, super.key});

  final WebViewController controller;

  @override
  State<NavigationControls> createState() => _NavigationControlsState();
}

class _NavigationControlsState extends State<NavigationControls> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          WillPopScope(
            child: const Text(''),
            onWillPop: () async {
              if (await widget.controller.canGoBack()) {
                _count = 0;
                await widget.controller.goBack();
              } else {
                _count++;
                if (_count == 2) {
                  return true;
                }// ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Press one more time for exit'),
                ));
              }
              return false;
            },
          ),
        ]
    );
  }
}
