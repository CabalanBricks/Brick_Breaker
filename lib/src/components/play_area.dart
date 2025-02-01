import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../brick_breaker.dart';

class PlayArea extends RectangleComponent with HasGameReference<BrickBreaker> {
  PlayArea()
      : super(
          paint: Paint()
            ..color = const Color(0xfff2e8cf)
            ..style = PaintingStyle.fill,
          children: [RectangleHitbox()], // Main play area hitbox
        );

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    size = Vector2(game.width, game.height);

    // Remove position offset (was causing misalignment)
    position = Vector2.zero();

    // Add border as separate component
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
      children: [RectangleHitbox()], // Border hitbox
    ));
  }
}
