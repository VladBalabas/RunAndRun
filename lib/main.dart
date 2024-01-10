import 'package:flutter/material.dart';

import 'package:run_and_run/src/white/my_app.dart';

import 'package:shared_preferences/shared_preferences.dart';



import 'src/checker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String state = prefs.getString("state") ?? "";
  
  Widget initialWidget = state == "black"
    ? MyApp()
    : state == "white"
      ? MyApp()
      : Checker();

  runApp(
    MaterialApp(
      home: initialWidget,
      debugShowCheckedModeBanner: false,
    ),
  );
}

