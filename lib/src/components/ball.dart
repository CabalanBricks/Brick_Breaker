import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';


import '../brick_breaker.dart';
import 'bat.dart';
import 'brick.dart';
import 'play_area.dart';

class Ball extends SpriteComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  Ball({
  required this.velocity,
  required super.position,
  required double radius,
  required this.difficultyModifier,
}) : super(
        size: Vector2(radius * 2, radius * 2), // Use size instead of radius
        anchor: Anchor.center,
        paint: Paint()
          ..color = const Color(0xff1e6091)
          ..style = PaintingStyle.fill,
        children: [CircleHitbox()],
      );

  Vector2 velocity;
  final double difficultyModifier;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Load the image and set it as the sprite
    sprite = await Sprite.load('ball.png'); // Ensure this path is correct
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Dynamically adjust velocity based on the score
    final double speedMultiplier = 1 + (game.score.value / 10);
    const double maxSpeed = 800; // Use const instead of final
    velocity = velocity.normalized() * (velocity.length * speedMultiplier).clamp(200, maxSpeed);

    // Update position
    position += velocity * dt;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);



    if (other is PlayArea) {
      if (intersectionPoints.first.y <= 0) {
        velocity.y = -velocity.y;
        game.playCollisionSound('jump.wav');
      } else if (intersectionPoints.first.x <= 0) {
        velocity.x = -velocity.x;
        game.playCollisionSound('jump.wav');
      } else if (intersectionPoints.first.x >= game.width) {
        velocity.x = -velocity.x;
        game.playCollisionSound('jump.wav');
      } else if (intersectionPoints.first.y >= game.height) {
        add(RemoveEffect(
          delay: 0.35,
          onComplete: () {
            game.playState = PlayState.gameOver;
            game.playCollisionSound('explosion.wav');
          },
        ));
      }
    } else if (other is Bat) {
      velocity.y = -velocity.y;
      velocity.x += (position.x - other.position.x) / other.size.x * game.width * 0.3;
      game.playCollisionSound('jump.wav');
} else if (other is Brick) {
  Vector2 delta = position - other.position;
  if (delta.x.abs() > delta.y.abs()) {
    velocity.x = -velocity.x;
  } else {
    velocity.y = -velocity.y;
  }
  game.playCollisionSound('explosion.wav');
  velocity.setFrom(velocity * difficultyModifier);
}
  }
}