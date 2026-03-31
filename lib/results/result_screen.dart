import 'package:flutter/material.dart';
import 'package:my_game/game/models/game_result.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.result,
    required this.onRestart,
  });

  final GameResult result;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                result.title,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text('本局得分 ${result.score}'),
              const SizedBox(height: 8),
              Text('最高分 ${result.bestScore}'),
              const SizedBox(height: 8),
              if (result.isNewHighScore) const Text('新纪录！今天的工位属于你。'),
              const SizedBox(height: 16),
              Text(result.summary, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRestart,
                child: const Text('再来一局'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
