import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'constants.dart';
import 'game_object.dart';
import 'sprite.dart';

List<Sprite> dino = [
  Sprite()
    ..imagePath = "assets/images/dino/man1.png"
    ..imageWidth = 88
    ..imageHeight = 94,
  Sprite()
    ..imagePath = "assets/images/dino/man3.png"
    ..imageWidth = 88
    ..imageHeight = 94,
  Sprite()
    ..imagePath = "assets/images/dino/man4.png"
    ..imageWidth = 88
    ..imageHeight = 94,
  Sprite()
    ..imagePath = "assets/images/dino/man5.png"
    ..imageWidth = 88
    ..imageHeight = 94,
  Sprite()
    ..imagePath = "assets/images/dino/man6.png"
    ..imageWidth = 88
    ..imageHeight = 94,
  Sprite()
    ..imagePath = "assets/images/dino/man7.png"
    ..imageWidth = 88
    ..imageHeight = 94,
  Sprite()
    ..imagePath = "assets/images/dino/man8.png"
    ..imageWidth = 88
    ..imageHeight = 94,
  Sprite()
    ..imagePath = "assets/images/dino/man9.png"
    ..imageWidth = 88
    ..imageHeight = 94,
];

enum DinoState {
  jumping,
  running,
  dead,
}

class Dino extends GameObject {
  Sprite currentSprite = dino[0];
  double dispY = 0;
  double velY = 0;
  DinoState state = DinoState.running;

  @override
  Widget render() {
    return Image.asset(currentSprite.imagePath);
  }

  @override
  Rect getRect(Size screenSize, double runDistance) {
    return Rect.fromLTWH(
      screenSize.width / 10,
      screenSize.height / 1.75 - currentSprite.imageHeight - dispY,
      currentSprite.imageWidth.toDouble(),
      currentSprite.imageHeight.toDouble(),
    );
  }

  @override
  void update(Duration lastUpdate, Duration? elapsedTime) {
    double elapsedTimeSeconds;
    try {
      currentSprite = dino[(elapsedTime!.inMilliseconds / 100).floor() % 7 + 1];
    } catch (_) {
      currentSprite = dino[0];
    }
    try{
      elapsedTimeSeconds = (elapsedTime! - lastUpdate).inMilliseconds / 1000;
    }
    catch(_){
      elapsedTimeSeconds = 0;
    }
    

    dispY += velY * elapsedTimeSeconds;
    if (dispY <= 0) {
      dispY = 0;
      velY = 0;
      state = DinoState.running;
    } else {
      velY -= gravity * elapsedTimeSeconds;
    }
  }

  void jump() {
    if (state != DinoState.jumping) {
      state = DinoState.jumping;
      velY = jumpVelocity;
    }
  }

  void die() {
    currentSprite = dino[3];
    state = DinoState.dead;
  }
}
