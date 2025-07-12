import 'dart:math';
import 'package:flutter/material.dart';

class BlueSnail extends StatelessWidget {
  final int snailSpriteCount;
  final String snailDirection;
  final bool isAlive;
  final int deathTimer;
  final String snailType;
  final bool isAngry;

  BlueSnail({
    required this.snailSpriteCount,
    required this.snailDirection,
    this.isAlive = true,
    this.deathTimer = 0,
    this.snailType = 'normal',
    this.isAngry = false,
  });

  @override
  Widget build(BuildContext context) {
    String imagePath;
    Color? overlayColor;

    // Determine which sprite to show
    if (!isAlive && deathTimer > 0) {
      // Show death animation sprites
      imagePath = 'assets/images/snaildie${deathTimer}.png';
    } else {
      // Show normal snail animation
      imagePath = 'assets/images/snail${snailSpriteCount}.png';

      // Apply visual effects based on type
      if (snailType == 'fast') {
        overlayColor = Colors.yellow.withOpacity(0.3);
      } else if (snailType == 'strong') {
        overlayColor = Colors.red.withOpacity(0.3);
      } else if (isAngry) {
        overlayColor = Colors.orange.withOpacity(0.4);
      }
    }

    Widget snailWidget = Container(
      alignment: Alignment.bottomCenter,
      height: 50,
      width: 50,
      child: Stack(
        children: [
          Image.asset(
            imagePath,
            // Add error handling
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(Icons.pets, color: Colors.white),
              );
            },
          ),
          if (overlayColor != null)
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: overlayColor,
                borderRadius: BorderRadius.circular(25),
              ),
            ),
        ],
      ),
    );

    // Add glow effect for special snails
    if (snailType != 'normal') {
      snailWidget = Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: snailType == 'fast' ? Colors.yellow : Colors.red,
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: snailWidget,
      );
    }

    // Apply directional transform
    if (snailDirection == 'left') {
      return snailWidget;
    } else {
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(pi),
        child: snailWidget,
      );
    }
  }
}

// Alternative snail types for variety
class RedSnail extends StatelessWidget {
  final int snailSpriteCount;
  final String snailDirection;
  final bool isAlive;
  final int deathTimer;

  RedSnail({
    required this.snailSpriteCount,
    required this.snailDirection,
    this.isAlive = true,
    this.deathTimer = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.6),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: BlueSnail(
        snailSpriteCount: snailSpriteCount,
        snailDirection: snailDirection,
        isAlive: isAlive,
        deathTimer: deathTimer,
        snailType: 'strong',
      ),
    );
  }
}

class YellowSnail extends StatelessWidget {
  final int snailSpriteCount;
  final String snailDirection;
  final bool isAlive;
  final int deathTimer;

  YellowSnail({
    required this.snailSpriteCount,
    required this.snailDirection,
    this.isAlive = true,
    this.deathTimer = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.yellow.withOpacity(0.6),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: BlueSnail(
        snailSpriteCount: snailSpriteCount,
        snailDirection: snailDirection,
        isAlive: isAlive,
        deathTimer: deathTimer,
        snailType: 'fast',
      ),
    );
  }
}