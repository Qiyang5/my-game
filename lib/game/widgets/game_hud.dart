import 'package:flutter/material.dart';

class GameHud extends StatelessWidget {
  const GameHud({
    super.key,
    required this.remainingSeconds,
    required this.survivalValue,
    required this.score,
  });

  final int remainingSeconds;
  final int survivalValue;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '剩余 $remainingSeconds 秒',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: survivalValue / 100),
        const SizedBox(height: 8),
        Text('分数 $score'),
      ],
    );
  }
}
