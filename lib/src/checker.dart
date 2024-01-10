import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:run_and_run/src/white/my_app.dart';

import 'package:shared_preferences/shared_preferences.dart';


class Checker extends StatelessWidget {
  const Checker({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<void>(
          future: _checkPage(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return PageChecker(initialPage: MyApp());
            } else {
              return PageChecker(initialPage: MyApp());
            }
          },
        ),
      ),
    );
  }

  Future<void> _checkPage() async {
    const url = '';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        prefs.setString("state", "black");
      } else {
        throw Exception();
      }
    } catch (e) {
      print(e);
      prefs.setString("state", "white");
    }
  }
}

class PageChecker extends StatelessWidget {
  final Widget initialPage;

  const PageChecker({required this.initialPage});

  @override
  Widget build(BuildContext context) {
    return initialPage;
  }
}
