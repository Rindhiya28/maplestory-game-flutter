import 'dart:math';
import 'package:flutter/material.dart';

class MyBoy extends StatelessWidget {
  final int boySpriteCount;
  final String boyDirection;
  final int attackBoySpriteCount;
  final bool isAttacking;
  final bool isInvincible;
  final bool isDamaged;

  MyBoy({
    required this.boySpriteCount,
    required this.boyDirection,
    required this.attackBoySpriteCount,
    required this.isAttacking,
    this.isInvincible = false,
    this.isDamaged = false,
  });

  @override
  Widget build(BuildContext context) {
    String imagePath;

    // Determine which sprite to show
    if (isAttacking && attackBoySpriteCount > 0) {
      // Show attack animation
      imagePath = 'assets/images/attackboy${attackBoySpriteCount}.png';
    } else {
      // Show walking animation
      imagePath = 'assets/images/walkboy${boySpriteCount}.png';
    }

    Widget boyWidget = Container(
      alignment: Alignment.bottomCenter,
      height: 50,
      width: 50,
      child: Image.asset(
        imagePath,
        // Add error handling
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 50,
            width: 50,
            color: Colors.blue,
            child: Icon(Icons.person, color: Colors.white),
          );
        },
      ),
    );

    // Apply visual effects
    if (isInvincible) {
      boyWidget = AnimatedOpacity(
        opacity: 0.5,
        duration: Duration(milliseconds: 200),
        child: boyWidget,
      );
    }

    if (isDamaged) {
      boyWidget = Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: boyWidget,
      );
    }

    // Apply directional transform
    if (boyDirection == 'left') {
      return boyWidget;
    } else {
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(pi),
        child: boyWidget,
      );
    }
  }
}