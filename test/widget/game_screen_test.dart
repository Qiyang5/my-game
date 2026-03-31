import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_game/game/engine/event_schedule.dart';
import 'package:my_game/game/screens/game_screen.dart';
import 'package:my_game/game/session/game_session_controller.dart';

void main() {
  testWidgets('renders timer, score, and active event label', (tester) async {
    final controller = GameSessionController(schedule: EventSchedule.buildDefault());
    controller.advanceToSecond(3);

    await tester.pumpWidget(
      MaterialApp(home: GameScreen(controller: controller, onFinished: (_) {})),
    );

    expect(find.text('剩余 42 秒'), findsOneWidget);
    expect(find.textContaining('群里突然有人'), findsOneWidget);
    expect(find.text('分数 0'), findsOneWidget);
  });
}
