import 'package:flutter/material.dart';
import 'package:my_game/game/models/game_event.dart';

class EventPanel extends StatelessWidget {
  const EventPanel({
    super.key,
    required this.event,
    required this.onTapAction,
    required this.onLongPressAction,
    required this.onDragAction,
  });

  final GameEvent? event;
  final VoidCallback onTapAction;
  final VoidCallback onLongPressAction;
  final VoidCallback onDragAction;

  @override
  Widget build(BuildContext context) {
    if (event == null) {
      return const Center(child: Text('工位暂时安全，先深呼吸一下。'));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(event!.label, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onTapAction,
              child: const Text('点击处理'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onLongPressAction,
              child: const Text('长按处理'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onDragAction,
              child: const Text('拖拽处理'),
            ),
          ],
        ),
      ),
    );
  }
}
