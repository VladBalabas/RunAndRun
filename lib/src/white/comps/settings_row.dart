import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingRow extends StatelessWidget {
  final String text;
  final TextEditingController controller;
  SettingRow({super.key, required this.text,required this.controller});
  final myNewFontBlack = GoogleFonts.pressStart2p(
    textStyle: TextStyle(color: Colors.black, letterSpacing: 0)
  );
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 25,
        width: 280,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: myNewFontBlack.copyWith(fontSize: 12,),),
            SizedBox(
              height: 25,
              width: 75,
              child: TextField(
                controller:controller,
                key: UniqueKey(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
