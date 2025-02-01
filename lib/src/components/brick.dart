import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../brick_breaker.dart';
import '../config.dart';
import 'ball.dart';
import 'bat.dart';
import 'power_up_ball.dart';

class Brick extends RectangleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  Brick({required super.position, required Color color})
      : super(
          size: Vector2(brickWidth, brickHeight),
          anchor: Anchor.center,
          paint: Paint()
            ..color = color
            ..style = PaintingStyle.fill,
          children: [RectangleHitbox()],
        );

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    // 10% chance to spawn a power-up
    if (Random().nextDouble() < 0.1) {
      final powerUp = PowerUpBall(
        position: position.clone(),
        velocity: Vector2(0, game.height * 0.3), // Move downward
      );
      game.world.add(powerUp);
    }

    removeFromParent();
    game.score.value++;

    final remainingBricks = game.world.children.whereType<Brick>().length;
    if (remainingBricks == 1) {
      game.playState = PlayState.won;
      game.world.removeAll(game.world.children.whereType<Ball>());
      game.world.removeAll(game.world.children.whereType<Bat>());
    }
  }
}
