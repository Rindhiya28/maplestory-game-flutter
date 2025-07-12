import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:maplestory/button.dart';
import 'package:maplestory/pet.dart';
import 'package:maplestory/snail.dart';
import 'boy.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget{
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // Game state
  bool gameOver = false;
  bool gameStarted = false;
  int score = 0;
  int lives = 3;
  int level = 1;

  // Player stats
  int playerExp = 0;
  int playerLevel = 1;
  int playerMaxExp = 100;
  double playerHealth = 100.0;
  double playerMaxHealth = 100.0;

  // Snail variables
  int snailSpriteCount = 1;
  double snailPosX = 0.5;
  String snailDirection = 'left';
  bool isSnailAlive = true;
  int snailDeathTimer = 0;
  double snailSpeed = 0.01;

  // Multiple snails for higher difficulty
  List<Map<String, dynamic>> snails = [];

  // Pet variables
  int petSpriteCount = 1;
  double petPosX = 0;
  String petDirection = 'right';

  // Boy variables
  int boySpriteCount = 2;
  double boyPosX = -0.5;
  double boyPosY = 1;
  String boyDirection = 'right';
  int attackBoySpriteCount = 0;
  bool isAttacking = false;
  bool isJumping = false;

  // Power-ups
  List<Map<String, dynamic>> powerUps = [];

  // Loading screen
  var loadingScreenColor = Colors.pink[300];
  var loadingScreenTextColor = Colors.black;
  int loadingTime = 3;

  // Timers
  Timer? snailTimer;
  Timer? petTimer;
  Timer? gameTimer;
  Timer? powerUpTimer;

  // Animations
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_backgroundController);

    initializeSnails();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _disposeTimers();
    super.dispose();
  }

  void _disposeTimers() {
    snailTimer?.cancel();
    petTimer?.cancel();
    gameTimer?.cancel();
    powerUpTimer?.cancel();
  }

  void initializeSnails() {
    snails.clear();
    int snailCount = level;
    for (int i = 0; i < snailCount; i++) {
      snails.add({
        'x': 0.3 + (i * 0.2),
        'y': 1.0,
        'direction': Random().nextBool() ? 'left' : 'right',
        'spriteCount': 1,
        'isAlive': true,
        'deathTimer': 0,
        'speed': snailSpeed + (Random().nextDouble() * 0.005),
      });
    }
  }

  void playNow() {
    if (gameOver) {
      // Reset game
      setState(() {
        gameOver = false;
        gameStarted = false;
        score = 0;
        lives = 3;
        level = 1;
        playerExp = 0;
        playerLevel = 1;
        playerHealth = playerMaxHealth;
        boyPosX = -0.5;
        boyPosY = 1;
        petPosX = 0;
        isAttacking = false;
        isJumping = false;
        boyDirection = 'right';
        powerUps.clear();
      });
      initializeSnails();
    }

    setState(() {
      gameStarted = true;
    });

    startGameTimer();
    moveSnails();
    moveTeddy();
    checkCollision();
    spawnPowerUps();
    startGameLoop();
  }

  void startGameTimer() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        loadingTime--;
      });
      if (loadingTime == 0) {
        setState(() {
          loadingScreenColor = Colors.transparent;
          loadingTime = 3;
          loadingScreenTextColor = Colors.transparent;
        });
        timer.cancel();
      }
    });
  }

  void startGameLoop() {
    gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (gameOver) {
        timer.cancel();
        return;
      }

      // Increase difficulty every 30 seconds
      if (timer.tick % 30 == 0) {
        increaseLevel();
      }

      // Regenerate health slowly
      if (playerHealth < playerMaxHealth) {
        setState(() {
          playerHealth = (playerHealth + 1).clamp(0, playerMaxHealth);
        });
      }
    });
  }

  void increaseLevel() {
    setState(() {
      level++;
      snailSpeed += 0.002;
    });

    // Add more snails
    for (int i = 0; i < 1; i++) {
      snails.add({
        'x': Random().nextDouble() * 0.8 + 0.1,
        'y': 1.0,
        'direction': Random().nextBool() ? 'left' : 'right',
        'spriteCount': 1,
        'isAlive': true,
        'deathTimer': 0,
        'speed': snailSpeed + (Random().nextDouble() * 0.005),
      });
    }
  }

  void spawnPowerUps() {
    powerUpTimer = Timer.periodic(Duration(seconds: 15), (timer) {
      if (gameOver || !gameStarted) {
        timer.cancel();
        return;
      }

      // Spawn power-up at random location
      setState(() {
        powerUps.add({
          'x': Random().nextDouble() * 1.4 - 0.7,
          'y': 0.8,
          'type': Random().nextInt(3), // 0: health, 1: exp, 2: invincibility
          'timer': 0,
        });
      });
    });
  }

  void attack() {
    if (isAttacking || gameOver || !gameStarted) return;

    setState(() {
      isAttacking = true;
      attackBoySpriteCount = 1;
    });

    Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        attackBoySpriteCount++;
      });
      if (attackBoySpriteCount >= 6) {
        // Check for hits on all snails
        for (var snail in snails) {
          if (snail['isAlive']) {
            bool hitSnail = false;
            if (boyDirection == 'right' && boyPosX + 0.15 > snail['x'] && boyPosX < snail['x'] + 0.1) {
              hitSnail = true;
            } else if (boyDirection == 'left' && boyPosX - 0.15 < snail['x'] && boyPosX > snail['x'] - 0.1) {
              hitSnail = true;
            }

            if (hitSnail) {
              killSnail(snail);
              gainExp(25);
              setState(() {
                score += 100;
              });
            }
          }
        }

        setState(() {
          attackBoySpriteCount = 0;
          isAttacking = false;
        });
        timer.cancel();
      }
    });
  }

  void gainExp(int amount) {
    setState(() {
      playerExp += amount;
      if (playerExp >= playerMaxExp) {
        playerLevel++;
        playerExp = 0;
        playerMaxExp = (playerMaxExp * 1.5).round();
        playerMaxHealth += 20;
        playerHealth = playerMaxHealth;
        score += 500; // Level up bonus
      }
    });
  }

  void moveTeddy() {
    petTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (gameOver || !gameStarted) {
        timer.cancel();
        return;
      }

      setState(() {
        petSpriteCount++;
        if (petSpriteCount == 6) {
          petSpriteCount = 1;
        }
        if ((petPosX - boyPosX).abs() > 0.2) {
          if (boyDirection == 'right') {
            petPosX = boyPosX - 0.2;
          } else if (boyDirection == 'left') {
            petPosX = boyPosX + 0.2;
          }
        }

        if (petPosX - boyPosX > 0) {
          petDirection = 'left';
        } else {
          petDirection = 'right';
        }
      });
    });
  }

  void moveSnails() {
    snailTimer = Timer.periodic(Duration(milliseconds: 150), (timer) {
      if (gameOver || !gameStarted) {
        timer.cancel();
        return;
      }

      setState(() {
        for (var snail in snails) {
          if (snail['isAlive']) {
            snail['spriteCount']++;
            if (snail['spriteCount'] == 5) {
              snail['spriteCount'] = 1;
            }

            if (snail['direction'] == 'left') {
              snail['x'] -= snail['speed'];
            } else {
              snail['x'] += snail['speed'];
            }

            if (snail['x'] <= -0.7) {
              snail['direction'] = 'right';
            } else if (snail['x'] >= 0.7) {
              snail['direction'] = 'left';
            }
          }
        }
      });
    });
  }

  void moveleft() {
    if (isAttacking || isJumping || gameOver || !gameStarted) return;

    setState(() {
      boyPosX -= 0.03;
      if (boyPosX < -0.7) boyPosX = -0.7; // Boundary check
      boySpriteCount++;
      if (boySpriteCount > 3) {
        boySpriteCount = 1;
      }
      boyDirection = 'left';
    });
  }

  void moveright() {
    if (isAttacking || isJumping || gameOver || !gameStarted) return;

    setState(() {
      boyPosX += 0.03;
      if (boyPosX > 0.7) boyPosX = 0.7; // Boundary check
      boySpriteCount++;
      if (boySpriteCount > 3) {
        boySpriteCount = 1;
      }
      boyDirection = 'right';
    });
  }

  void jump() {
    if (isJumping || isAttacking || gameOver || !gameStarted) return;

    setState(() {
      isJumping = true;
    });

    Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        boyPosY -= 0.08;
      });

      if (boyPosY <= 0.5) {
        timer.cancel();
        Timer.periodic(Duration(milliseconds: 50), (fallTimer) {
          setState(() {
            boyPosY += 0.08;
          });

          if (boyPosY >= 1) {
            setState(() {
              boyPosY = 1;
              isJumping = false;
            });
            fallTimer.cancel();
          }
        });
      }
    });
  }

  void killSnail(Map<String, dynamic> snail) {
    snail['isAlive'] = false;
    snail['deathTimer'] = 1;

    Timer.periodic(Duration(milliseconds: 150), (timer) {
      snail['deathTimer']++;
      if (snail['deathTimer'] > 4) {
        timer.cancel();
        Timer(Duration(seconds: 5), () {
          snail['isAlive'] = true;
          snail['deathTimer'] = 0;
          snail['x'] = Random().nextDouble() * 1.4 - 0.7;
          snail['direction'] = Random().nextBool() ? 'left' : 'right';
        });
      }
    });
  }

  void checkCollision() {
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (gameOver || !gameStarted) {
        timer.cancel();
        return;
      }

      // Check snail collisions
      for (var snail in snails) {
        if (snail['isAlive'] && (boyPosX - snail['x']).abs() < 0.1 && boyPosY > 0.8) {
          takeDamage(20);
          break;
        }
      }

      // Check power-up collisions
      powerUps.removeWhere((powerUp) {
        if ((boyPosX - powerUp['x']).abs() < 0.1 && boyPosY > 0.8) {
          collectPowerUp(powerUp);
          return true;
        }
        return false;
      });
    });
  }

  void takeDamage(double damage) {
    setState(() {
      playerHealth -= damage;
      if (playerHealth <= 0) {
        lives--;
        if (lives <= 0) {
          gameOver = true;
          _disposeTimers();
        } else {
          playerHealth = playerMaxHealth;
        }
      }
    });
  }

  void collectPowerUp(Map<String, dynamic> powerUp) {
    setState(() {
      switch (powerUp['type']) {
        case 0: // Health
          playerHealth = (playerHealth + 50).clamp(0, playerMaxHealth);
          break;
        case 1: // Experience
          gainExp(50);
          break;
        case 2: // Score bonus
          score += 200;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Game stats bar
          Container(
            height: 60,
            color: Colors.brown[800],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Score: $score', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('Lives: $lives', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('Level: $level', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('Player Lv: $playerLevel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Health and EXP bars
          Container(
            height: 30,
            color: Colors.brown[600],
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: LinearProgressIndicator(
                      value: playerHealth / playerMaxHealth,
                      backgroundColor: Colors.red[200],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: LinearProgressIndicator(
                      value: playerExp / playerMaxExp,
                      backgroundColor: Colors.blue[200],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Game area
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.lightBlue[200]!, Colors.lightBlue[400]!],
                ),
              ),
              child: Stack(
                children: [
                  // Animated background
                  AnimatedBuilder(
                    animation: _backgroundAnimation,
                    builder: (context, child) {
                      return Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.lightBlue[300]!.withOpacity(0.3),
                                Colors.lightBlue[400]!.withOpacity(0.3),
                              ],
                              stops: [_backgroundAnimation.value, _backgroundAnimation.value + 0.5],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Snails
                  ...snails.map((snail) {
                    if (snail['isAlive'] || snail['deathTimer'] > 0) {
                      return Container(
                        alignment: Alignment(snail['x'], snail['y']),
                        child: BlueSnail(
                          snailDirection: snail['direction'],
                          snailSpriteCount: snail['spriteCount'],
                          isAlive: snail['isAlive'],
                          deathTimer: snail['deathTimer'],
                        ),
                      );
                    }
                    return Container();
                  }).toList(),

                  // Power-ups
                  ...powerUps.map((powerUp) {
                    return Container(
                      alignment: Alignment(powerUp['x'], powerUp['y']),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: powerUp['type'] == 0 ? Colors.red :
                          powerUp['type'] == 1 ? Colors.blue : Color(0xFFFFD700),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          powerUp['type'] == 0 ? Icons.favorite :
                          powerUp['type'] == 1 ? Icons.star : Icons.attach_money,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    );
                  }).toList(),

                  // Pet
                  Container(
                    alignment: Alignment(petPosX, 1),
                    child: MyTeddy(
                      petDirection: petDirection,
                      petSpriteCount: petSpriteCount,
                    ),
                  ),

                  // Player
                  Container(
                    alignment: Alignment(boyPosX, boyPosY),
                    child: MyBoy(
                      boyDirection: boyDirection,
                      boySpriteCount: boySpriteCount,
                      attackBoySpriteCount: attackBoySpriteCount,
                      isAttacking: isAttacking,
                    ),
                  ),

                  // Loading screen
                  Container(
                    color: loadingScreenColor,
                    child: Center(
                      child: Text(
                        loadingTime.toString(),
                        style: TextStyle(color: loadingScreenTextColor),
                      ),
                    ),
                  ),

                  // Game Over Screen
                  if (gameOver)
                    Container(
                      color: Colors.black.withOpacity(0.7),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'GAME OVER',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Final Score: $score',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Level Reached: $level',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Press RESTART to play again',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Ground
          Container(
            height: 10,
            color: Colors.green[600],
          ),

          // Controls
          Expanded(
            child: Container(
              color: Colors.grey[800],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'M A P L E S T O R Y',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyButton(
                        text: gameOver ? 'RESTART' : 'PLAY',
                        function: () {
                          playNow();
                        },
                      ),
                      MyButton(
                        text: 'ATTACK',
                        function: attack,
                      ),
                      MyButton(
                        text: '←',
                        function: () {
                          moveleft();
                        },
                      ),
                      MyButton(
                        text: '↑',
                        function: () {
                          jump();
                        },
                      ),
                      MyButton(
                        text: '→',
                        function: () {
                          moveright();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}