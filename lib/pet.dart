import 'dart:math';
import 'package:flutter/material.dart';

class MyTeddy extends StatelessWidget {
  final int petSpriteCount;
  final String petDirection;
  final bool isHappy;
  final bool isAttacking;
  final String petType;

  MyTeddy({
    required this.petSpriteCount,
    required this.petDirection,
    this.isHappy = false,
    this.isAttacking = false,
    this.petType = 'normal',
  });

  @override
  Widget build(BuildContext context) {
    String imagePath = 'assets/images/pet${petSpriteCount}.png';

    Widget petWidget = Container(
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
            decoration: BoxDecoration(
              color: Colors.brown,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(Icons.pets, color: Colors.white),
          );
        },
      ),
    );

    // Add visual effects
    if (isHappy) {
      petWidget = Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.4),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: petWidget,
      );
    }

    if (isAttacking) {
      petWidget = Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.6),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: petWidget,
      );
    }

    // Apply directional transform
    if (petDirection == 'left') {
      return petWidget;
    } else {
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(pi),
        child: petWidget,
      );
    }
  }
}

// Enhanced pet with special abilities
class MagicPet extends StatelessWidget {
  final int petSpriteCount;
  final String petDirection;
  final bool isCharging;

  MagicPet({
    required this.petSpriteCount,
    required this.petDirection,
    this.isCharging = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget petWidget = MyTeddy(
      petSpriteCount: petSpriteCount,
      petDirection: petDirection,
      petType: 'magic',
    );

    if (isCharging) {
      petWidget = Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.8),
              blurRadius: 12,
              spreadRadius: 3,
            ),
            BoxShadow(
              color: Colors.purple.withOpacity(0.6),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: petWidget,
      );
    }

    return petWidget;
  }
}

// Pet with healing abilities
class HealerPet extends StatelessWidget {
  final int petSpriteCount;
  final String petDirection;
  final bool isHealing;

  HealerPet({
    required this.petSpriteCount,
    required this.petDirection,
    this.isHealing = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget petWidget = MyTeddy(
      petSpriteCount: petSpriteCount,
      petDirection: petDirection,
      petType: 'healer',
    );

    if (isHealing) {
      petWidget = Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.8),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: petWidget,
      );
    }

    return petWidget;
  }
}