import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:run_and_run/src/white/comps/settings_row.dart';
import 'package:run_and_run/src/white/comps/sound_manager.dart';

import 'comps/cactus.dart';
import 'comps/cloud.dart';
import 'comps/dino.dart';
import 'comps/game_object.dart';
import 'comps/ground.dart';
import 'comps/constants.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {

  
  GamePage({super.key, });
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  Dino dino = Dino();
  double runVelocity = initialVelocity;
  double runDistance = 0;
  int highScore = 0;

  TextEditingController gravityController =
      TextEditingController(text: gravity.toString());
  TextEditingController accelerationController =
      TextEditingController(text: acceleration.toString());
  TextEditingController jumpVelocityController =
      TextEditingController(text: jumpVelocity.toString());
  TextEditingController runVelocityController =
      TextEditingController(text: initialVelocity.toString());

  late AnimationController worldController;
  Duration lastUpdateCall = const Duration();

  SoundManager soundManager=SoundManager();

  List<Cactus> cacti = [Cactus(worldLocation: const Offset(200, 0))];

  List<Ground> ground = [
    Ground(worldLocation: const Offset(0, 0)),
    Ground(worldLocation: Offset(groundSprite.imageWidth / 10, 0))
  ];

  List<Cloud> clouds = [
    Cloud(worldLocation: const Offset(100, 20)),
    Cloud(worldLocation: const Offset(200, 10)),
    Cloud(worldLocation: const Offset(350, -10)),
  ];

  final myNewFontBlack = GoogleFonts.pressStart2p(
    textStyle: TextStyle(color: Colors.black, letterSpacing: 0)
  );

  @override
  void initState() {
    super.initState();
    worldController =
        AnimationController(vsync: this, duration: const Duration(days: 99));
    worldController.addListener(_update);
    _die();
  }
  

  void _die() {
    setState(() {
      worldController.stop();
      dino.die();
    });
  }

  void _newGame() {
    setState(() {
      highScore = max(highScore, runDistance.toInt());
      runDistance = 0;
      runVelocity = initialVelocity;
      dino.state = DinoState.running;
      dino.dispY = 0;
      worldController.reset();
      cacti = [
        Cactus(worldLocation: const Offset(200, 0)),
        Cactus(worldLocation: const Offset(300, 0)),
        Cactus(worldLocation: const Offset(450, 0)),
      ];

      ground = [
        Ground(worldLocation: const Offset(0, 0)),
        Ground(worldLocation: Offset(groundSprite.imageWidth / 10, 0))
      ];

      clouds = [
        Cloud(worldLocation: const Offset(100, 20)),
        Cloud(worldLocation: const Offset(200, 10)),
        Cloud(worldLocation: const Offset(350, -15)),
        Cloud(worldLocation: const Offset(500, 10)),
        Cloud(worldLocation: const Offset(550, -10)),
      ];

      worldController.forward();
    });
  }

  _update() {
    try {
      double elapsedTimeSeconds;
      dino.update(lastUpdateCall, worldController.lastElapsedDuration);
      try {
        elapsedTimeSeconds =
            (worldController.lastElapsedDuration! - lastUpdateCall)
                    .inMilliseconds /
                1000;
      } catch (_) {
        elapsedTimeSeconds = 0;
      }

      runDistance += runVelocity * elapsedTimeSeconds;
      if (runDistance < 0) runDistance = 0;
      runVelocity += acceleration * elapsedTimeSeconds;

      Size screenSize = MediaQuery.of(context).size;

      Rect dinoRect = dino.getRect(screenSize, runDistance);
      for (Cactus cactus in cacti) {
        Rect obstacleRect = cactus.getRect(screenSize, runDistance);
        if (dinoRect.overlaps(obstacleRect.deflate(20))) {
          _die();
        }

        if (obstacleRect.right < 0) {
          setState(() {
            cacti.remove(cactus);
            cacti.add(Cactus(
                worldLocation: Offset(
                    runDistance +
                        Random().nextInt(100) +
                        MediaQuery.of(context).size.width / worlToPixelRatio,
                    0)));
          });
        }
      }

      for (Ground groundlet in ground) {
        if (groundlet.getRect(screenSize, runDistance).right < 0) {
          setState(() {
            ground.remove(groundlet);
            ground.add(
              Ground(
                worldLocation: Offset(
                  ground.last.worldLocation.dx + groundSprite.imageWidth / 10,
                  0,
                ),
              ),
            );
          });
        }
      }

      for (Cloud cloud in clouds) {
        if (cloud.getRect(screenSize, runDistance).right < 0) {
          setState(() {
            clouds.remove(cloud);
            clouds.add(
              Cloud(
                worldLocation: Offset(
                  clouds.last.worldLocation.dx +
                      Random().nextInt(200) +
                      MediaQuery.of(context).size.width / worlToPixelRatio,
                  Random().nextInt(50) - 25.0,
                ),
              ),
            );
          });
        }
      }

      lastUpdateCall = worldController.lastElapsedDuration!;
    } catch (e) {
      //
    }
  }

  @override
  void dispose() {
    gravityController.dispose();
    accelerationController.dispose();
    jumpVelocityController.dispose();
    runVelocityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    List<Widget> children = [];

    for (GameObject object in [...clouds, ...ground, ...cacti, dino]) {
      children.add(
        AnimatedBuilder(
          animation: worldController,
          builder: (context, _) {
            Rect objectRect = object.getRect(screenSize, runDistance);
            return Positioned(
              left: objectRect.left,
              top: objectRect.top,
              width: objectRect.width,
              height: objectRect.height,
              child: object.render(),
            );
          },
        ),
      );
    }

    return Scaffold(
      
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 5000),
        color: Colors.white,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (dino.state != DinoState.dead) {
              dino.jump();
            }
            if (dino.state == DinoState.dead) {
              _newGame();
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              ...children,
              AnimatedBuilder(
                animation: worldController,
                builder: (context, _) {
                  return Positioned(
                    left: screenSize.width / 2-65,
                    top: 100,
                    child: Text(
                      'Score: ' + runDistance.toInt().toString(),
                      style: myNewFontBlack
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: worldController,
                builder: (context, _) {
                  return Positioned(
                    left: screenSize.width / 2 - 85,
                    top: 120,
                    child: Text(
                      'High Score: ' + highScore.toString(),
                      style: myNewFontBlack
                    ),
                  );
                },
              ),
              Positioned(
                right: 20,
                top: 20,
                child: Row(
                  children: [
                    IconButton(
                      color: Colors.black,
                      onPressed: () {setState(() {
                        soundManager.toggleSound();
                      });
                      },
                      icon: Icon(
                        soundManager.isSoundOn ? Icons.volume_up : Icons.volume_off,
                        color: Colors.black,
                        size: 35.0,
                      ),
                    ),
                    SizedBox(width: 2,),
                    IconButton(
                      icon: const Icon(Icons.settings, size: 35,),
                      onPressed: () {
                        _die();
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Settings", style: myNewFontBlack,),
                                ],
                              ),
                              actions: [
                                SettingRow(
                                  text: 'Gravity:', 
                                  controller: gravityController
                                  ),
                                SettingRow(
                                  text: 'Acceleration:', 
                                  controller: accelerationController
                                  ),
                                SettingRow(
                                  text: 'Initial Velocity:', 
                                  controller: runVelocityController
                                  ),
                                SettingRow(
                                  text: 'Jump Velocity:', 
                                  controller: jumpVelocityController
                                  ),
                                TextButton(
                                  onPressed: () {
                                    gravity = int.parse(gravityController.text);
                                    acceleration =
                                        double.parse(accelerationController.text);
                                    initialVelocity =
                                        double.parse(runVelocityController.text);
                                    jumpVelocity =
                                        double.parse(jumpVelocityController.text);
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    "Done",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 30, 249, 1),
                                      fontSize: 20
                                    ),
                                  ),
                                )
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 30,
                child: GestureDetector(
                  onTap: () {
                    _die();
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width*0.5,
                    height: MediaQuery.of(context).size.height*0.04,
                    decoration: BoxDecoration(
                      color:Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.black)
                    ),
                    child: Center(
                        child: Text(
                          "End current game",
                          style: myNewFontBlack.copyWith(color: Colors.red, fontSize: 12),
                        ),                 
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
