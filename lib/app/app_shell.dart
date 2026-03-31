import 'package:flutter/material.dart';
import 'package:my_game/game/engine/event_schedule.dart';
import 'package:my_game/game/models/game_result.dart';
import 'package:my_game/game/screens/game_screen.dart';
import 'package:my_game/game/session/game_session_controller.dart';
import 'package:my_game/results/result_screen.dart';
import 'package:my_game/storage/high_score_store.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final HighScoreStore _highScoreStore = HighScoreStore();
  GameSessionController? _controller;
  GameResult? _lastResult;

  void _startGame() {
    setState(() {
      _controller = GameSessionController(schedule: EventSchedule.buildDefault());
      _lastResult = null;
    });
  }

  Future<void> _finishGame(GameSessionController controller) async {
    final isNewHighScore = await _highScoreStore.writeIfHigher(
      controller.state.score,
    );
    final bestScore = await _highScoreStore.readBestScore();

    if (!mounted) {
      return;
    }

    setState(() {
      _lastResult = controller.buildResult(
        isNewHighScore: isNewHighScore,
        bestScore: bestScore,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_lastResult != null) {
      return ResultScreen(
        result: _lastResult!,
        onRestart: _startGame,
      );
    }

    if (_controller != null) {
      return GameScreen(
        controller: _controller!,
        onFinished: _finishGame,
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '工位求生',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  '45 秒内顶住工位灾难，在一团乱桌面里把老板巡逻、消息轰炸和咖啡翻车全都压回去。',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  '看准提示出手：轻点灭火、长按稳住、拖拽救场。',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _startGame,
                  child: const Text('开始工位求生'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
