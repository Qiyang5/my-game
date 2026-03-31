import 'package:flutter/material.dart';
import 'package:my_game/game/engine/event_schedule.dart';
import 'package:my_game/game/screens/game_screen.dart';
import 'package:my_game/game/session/game_session_controller.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _inGame = false;
  GameSessionController? _controller;

  void _startGame() {
    setState(() {
      _controller = GameSessionController(schedule: EventSchedule.buildDefault());
      _inGame = true;
    });
  }

  void _finishGame(GameSessionController _) {
    setState(() {
      _inGame = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_inGame && _controller != null) {
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
                  '45 秒内活过老板巡逻、群消息轰炸和临时会议。',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _startGame,
                  child: const Text('开始摸鱼求生'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
