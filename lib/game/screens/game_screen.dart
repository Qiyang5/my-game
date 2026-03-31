import 'package:flutter/material.dart';
import 'package:my_game/game/models/game_event.dart';
import 'package:my_game/game/session/game_session_controller.dart';
import 'package:my_game/game/widgets/event_panel.dart';
import 'package:my_game/game/widgets/game_hud.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.controller,
    required this.onFinished,
  });

  final GameSessionController controller;
  final ValueChanged<GameSessionController> onFinished;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  void _submit(GameInputType inputType) {
    setState(() {
      widget.controller.submit(inputType);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;

    return Scaffold(
      appBar: AppBar(title: const Text('今日工位战况')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GameHud(
              remainingSeconds: state.remainingSeconds,
              survivalValue: state.survivalValue,
              score: state.score,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: EventPanel(
                  event: state.activeEvent,
                  onTapAction: () => _submit(GameInputType.tap),
                  onLongPressAction: () => _submit(GameInputType.longPress),
                  onDragAction: () => _submit(GameInputType.drag),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
