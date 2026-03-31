import 'dart:async';

import 'package:flutter/material.dart';
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
  Timer? _timer;
  int _elapsed = 0;
  bool _didFinish = false;

  @override
  void initState() {
    super.initState();
    _scheduleFinishCheck();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed += 1;
        widget.controller.advanceToSecond(_elapsed);
      });
      _emitResultIfNeeded();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _emitResultIfNeeded() {
    if (_didFinish || !widget.controller.state.isGameOver) {
      return;
    }

    _didFinish = true;
    _timer?.cancel();
    _timer = null;
    widget.onFinished(widget.controller);
  }

  void _scheduleFinishCheck() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didFinish) {
        return;
      }

      _emitResultIfNeeded();
      if (!_didFinish) {
        _scheduleFinishCheck();
      }
    });
  }

  void _submitTap() {
    setState(widget.controller.submitTap);
    _emitResultIfNeeded();
  }

  void _submitLongPress() {
    setState(widget.controller.submitLongPress);
    _emitResultIfNeeded();
  }

  void _submitDrag() {
    setState(widget.controller.submitDrag);
    _emitResultIfNeeded();
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
                  onTapAction: _submitTap,
                  onLongPressAction: _submitLongPress,
                  onDragAction: _submitDrag,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
