import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_game/game/session/game_session_controller.dart';
import 'package:my_game/game/widgets/desk_scene.dart';
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
  static const Color _dangerColor = Color(0xFFD92D20);

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
    final activeEvent = state.activeEvent;
    final isHighPressure = activeEvent?.isHighPressure ?? false;

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
              isDangerMode: isHighPressure,
            ),
            if (isHighPressure) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _dangerColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _dangerColor, width: 2),
                ),
                child: Text(
                  '高压警报：立即处理当前危机',
                  style: const TextStyle(
                    color: _dangerColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isHighPressure
                        ? _dangerColor
                        : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: isHighPressure
                      ? [
                          BoxShadow(
                            color: _dangerColor.withValues(alpha: 0.16),
                            blurRadius: 28,
                            spreadRadius: 2,
                          ),
                        ]
                      : const [],
                ),
                child: Center(
                  child: DeskScene(
                    event: activeEvent,
                    onTapAction: _submitTap,
                    onLongPressAction: _submitLongPress,
                    onDragAction: _submitDrag,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
