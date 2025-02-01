// ball.dart
import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../brick_breaker.dart';
import '../config.dart';
import 'bat.dart';
import 'brick.dart';
import 'play_area.dart';

class Ball extends CircleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  Ball({
    required this.velocity,
    required super.position,
    required double radius,
    required this.difficultyModifier,
  }) : super(
          radius: radius,
          anchor: Anchor.center,
          paint: Paint()
            ..color = const Color(0xff1e6091)
            ..style = PaintingStyle.fill,
          children: [CircleHitbox()],
        );

  final Vector2 velocity;
  final double difficultyModifier;
  bool _isLaunched = false;
  bool get isLaunched => _isLaunched;

  @override
  void update(double dt) {
    super.update(dt);

    if (_isLaunched) {
      position += velocity * dt;
    } else {
      // Follow bat position if not launched
      final bat = game.world.children.query<Bat>().firstOrNull;
      if (bat != null) {
        position.x = bat.position.x;
        position.y = game.height * 0.85;
      }
    }
  }

  void launch() {
    if (!_isLaunched) {
      _isLaunched = true;
      // Set initial velocity upward with slight angle
      final angle = (game.rand.nextDouble() - 0.5) * 1.5;
      final speed = game.height * 0.5;
      velocity.setValues(
        speed * math.sin(angle),
        -speed * math.cos(angle),
      );
    }
  }

  void reset() {
    _isLaunched = false;
    velocity.setZero();
    final bat = game.world.children.query<Bat>().firstOrNull;
    if (bat != null) {
      position.x = bat.position.x;
      position.y = game.height * 0.85;
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is PlayArea) {
      if (intersectionPoints.first.y <= 0) {
        velocity.y = -velocity.y;
        _playCollisionSound('jump.wav');
      } else if (intersectionPoints.first.x <= 0) {
        velocity.x = -velocity.x;
        _playCollisionSound('jump.wav');
      } else if (intersectionPoints.first.x >= game.width) {
        velocity.x = -velocity.x;
        _playCollisionSound('jump.wav');
      } else if (intersectionPoints.first.y >= game.height) {
        // Ball hit the bottom - lose a life
        game.lives.value--;
        if (game.lives.value <= 0) {
          add(RemoveEffect(
            delay: 0.35,
            onComplete: () {
              game.playState = PlayState.gameOver;
            },
          ));
        } else {
          removeFromParent();
          game.world.add(Ball(
            difficultyModifier: difficultyModifier,
            radius: ballRadius,
            position: Vector2(game.width / 2, game.height * 0.85),
            velocity: Vector2.zero(),
          ));
        }
      }
    } else if (other is Bat && _isLaunched) {
      velocity.y = -velocity.y.abs();
      velocity.x =
          (position.x - other.position.x) / other.size.x * game.width * 0.5;
      _playCollisionSound('jump.wav');
    } else if (other is Brick) {
      final brickCenter = other.position.clone();
      final ballCenter = position.clone();
      final collisionVector = ballCenter - brickCenter;

      if (collisionVector.y.abs() > collisionVector.x.abs()) {
        velocity.y = -velocity.y;
      } else {
        velocity.x = -velocity.x;
      }

      velocity.setFrom(velocity * difficultyModifier);
      _playCollisionSound('explosion.wav');
    }
  }

  // Add this helper method to handle sound effects with a small delay
  DateTime _lastSoundTime = DateTime.now();
  void _playCollisionSound(String soundFile) {
    final now = DateTime.now();
    // Add a small delay between sound effects to prevent overlapping
    if (now.difference(_lastSoundTime).inMilliseconds > 50) {
      game.audioManager.playSfx(soundFile);
      _lastSoundTime = now;
    }
  }
}
