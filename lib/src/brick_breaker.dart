import 'dart:async';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame_audio/flame_audio.dart';

import 'components/components.dart';
import 'config.dart';

enum PlayState { welcome, playing, gameOver, won }

class BrickBreaker extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapDetector {
  BrickBreaker()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: gameWidth,
            height: gameHeight,
          ),
        );

  final ValueNotifier<int> score = ValueNotifier(0);
  final ValueNotifier<int> lives = ValueNotifier(3);
  final rand = math.Random();
  
  AudioPlayer? backgroundMusic;
  bool isBackgroundMusicPlaying = false;
  
  double get width => size.x;
  double get height => size.y;

  bool _hasUserInteracted = false;
  late PlayState _playState;
  
  PlayState get playState => _playState;
  set playState(PlayState playState) {
    _playState = playState;
    switch (playState) {
      case PlayState.welcome:
      case PlayState.gameOver:
      case PlayState.won:
        overlays.add(playState.name);
      case PlayState.playing:
        overlays.remove(PlayState.welcome.name);
        overlays.remove(PlayState.gameOver.name);
        overlays.remove(PlayState.won.name);
    }
  }

  @override
FutureOr<void> onLoad() async {
  await FlameAudio.audioCache.loadAll([
    'fast-chiptune-for-gaming-videos-253097.mp3',
    'explosion.wav',
    'jump.wav',
    'hit_bat.wav',
    'pickupCoin.wav',
    'powerUp.wav',
  ]);
  
  camera.viewfinder.anchor = Anchor.topLeft;
  world.add(PlayArea());
  _initializeGameComponents(isInitializingWelcome: true);
  playState = PlayState.welcome;
  
  _playBackgroundMusic(); // Start music on load
  
  return super.onLoad();
}

  Future<void> _playBackgroundMusic() async {
    if (!isBackgroundMusicPlaying) {
      // Using FlameAudio.bgm instead of loop for background music
      await FlameAudio.bgm.play(
        'fast-chiptune-for-gaming-videos-253097.mp3',
        volume: backgroundMusicVolume,
      );
      isBackgroundMusicPlaying = true;
    }
  }

  Future<void> _adjustBackgroundMusic() async {
    if (isBackgroundMusicPlaying) {
      // Using FlameAudio.bgm for volume control
      await FlameAudio.bgm.audioPlayer.setVolume(gameStartVolume);
    }
    await FlameAudio.play('powerUp.wav');
  }

  void startGame() {
  if (playState == PlayState.playing) return;
  
  if (!_hasUserInteracted) {
    _hasUserInteracted = true;
    _adjustBackgroundMusic(); // Lower volume on first interaction
  }

  world.removeAll(world.children.query<Ball>());
  world.removeAll(world.children.query<Bat>());
  world.removeAll(world.children.query<Brick>());

  playState = PlayState.playing;
  score.value = 0;
  lives.value = 3;

  _initializeGameComponents(isInitializingWelcome: false);
}

  void _initializeGameComponents({required bool isInitializingWelcome}) {
    Vector2 ballVelocity = isInitializingWelcome
        ? Vector2.zero()
        : Vector2(0, -height / 3).normalized()..scale(height / 4);

    world.add(Ball(
      difficultyModifier: difficultyModifier,
      radius: ballRadius,
      position: Vector2(width / 2, height * 0.8 - 2 * ballRadius),
      velocity: ballVelocity,
    ));

    world.add(Bat(
      size: Vector2(batWidth, batHeight),
      cornerRadius: const Radius.circular(ballRadius / 2),
      position: Vector2(width / 2, height * 0.8),
    ));

    for (var row = 0; row < numBrickRows; row++) {
      for (var i = 0; i < brickColors.length; i++) {
        final brick = Brick(
          position: Vector2(
            brickGutter + (brickWidth / 2) + (i * (brickWidth + brickGutter)),
            height * 0.2 + row * (brickHeight + verticalBrickGutter),
          ),
          color: brickColors[row % brickColors.length],
        );
        world.add(brick);
      }
    }
  }

  void onBallMissed() {
    lives.value--;
    if (lives.value <= 0) {
      playState = PlayState.gameOver;
    } else {
      world.removeAll(world.children.query<Ball>());
      world.removeAll(world.children.query<Bat>());
      _initializeBallAndBat();
    }
  }

  void _initializeBallAndBat() {
    world.add(Ball(
      difficultyModifier: difficultyModifier,
      radius: ballRadius,
      position: Vector2(width / 2, height * 0.8 - 2 * ballRadius),
      velocity: Vector2(0, -height / 3).normalized()..scale(height / 4),
    ));

    world.add(Bat(
      size: Vector2(batWidth, batHeight),
      cornerRadius: const Radius.circular(ballRadius / 2),
      position: Vector2(width / 2, height * 0.8),
    ));
  }

  void playCollisionSound(String sound) {
    FlameAudio.play(sound);
  }

  @override
  void onRemove() {
    FlameAudio.bgm.stop(); // Stop background music properly
    super.onRemove();
  }

  @override
  void onTap() {
    super.onTap();
    startGame();
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    super.onKeyEvent(event, keysPressed);
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        world.children.query<Bat>().first.moveBy(-batStep);
      case LogicalKeyboardKey.arrowRight:
        world.children.query<Bat>().first.moveBy(batStep);
      case LogicalKeyboardKey.space:
      case LogicalKeyboardKey.enter:
        startGame();
    }
    return KeyEventResult.handled;
  }

  @override
  Color backgroundColor() => const Color(0xfff2e8cf);
}