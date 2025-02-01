import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../brick_breaker.dart';
import 'bat.dart';
import 'ball.dart';

class PowerUpBall extends CircleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  PowerUpBall({
    required super.position,
    required this.velocity,
  }) : super(
          radius: 20,
          anchor: Anchor.center,
          paint: Paint()
            ..color = const Color(0xff90be6d)
            ..style = PaintingStyle.fill,
          children: [CircleHitbox()],
        );

  final Vector2 velocity;

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;

    // Remove if falls below screen
    if (position.y > game.height) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Bat) {
      // Get original ball
      final ball = game.world.children.query<Ball>().firstOrNull;

      if (ball != null && ball.isLaunched) {
        // Create new ball with the same properties but different angle
        final newBall = Ball(
          difficultyModifier: ball.difficultyModifier,
          radius: ball.radius,
          position: Vector2(other.position.x, game.height * 0.85),
          velocity: Vector2(0, -game.height * 0.5),
        );

        // Add to world first
        game.world.add(newBall);

        // Launch the ball after adding to world
        Future.microtask(() => newBall.launch());
      }

      // Play jump sound
      game.audioManager.playSfx('jump.wav');

      // Remove the power-up
      removeFromParent();
    }
  }
}
