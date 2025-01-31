import 'package:flutter/material.dart';

class LifeCounter extends StatelessWidget {
  const LifeCounter({
    super.key,
    required this.lives,
  });

  final ValueNotifier<int> lives;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: lives,
      builder: (context, lives, child) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  index < lives ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red[800],
                  size: 30,
                ),
              );
            }),
          ),
        );
      },
    );
  }
}