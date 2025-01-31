import 'package:flutter/material.dart';                         // Add this import

const brickColors = [
  Colors.red,
  Colors.red,
  Colors.red,
  Colors.red,
  Colors.red,
  Colors.red,
];

const numBrickRows = 6;
const verticalBrickGutter = gameHeight * 0.03;
const gameWidth = 1000.0;
const gameHeight = 1800.0;
const ballRadius = gameWidth * 0.035;
const batWidth = gameWidth * 0.25;
const batHeight = ballRadius * 1;
const batStep = gameWidth * 0.05;
const brickGutter = gameWidth * 0.010;                          // Add from here...
final brickWidth =
    (gameWidth - (brickGutter * (brickColors.length + 1)))
    / brickColors.length;
const brickHeight = gameHeight * 0.01;
const difficultyModifier = 1.03;       
const backgroundMusicVolume = 0.5;
const gameStartVolume = 0.2;                         // To here.