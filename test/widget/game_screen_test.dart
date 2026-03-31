import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_game/game/engine/event_schedule.dart';
import 'package:my_game/game/screens/game_screen.dart';
import 'package:my_game/game/session/game_session_controller.dart';

void main() {
  testWidgets('shows the desk scene with phone and computer areas', (tester) async {
    final controller = GameSessionController(schedule: EventSchedule.buildDefault());
    controller.advanceToSecond(14);

    await tester.pumpWidget(
      MaterialApp(home: GameScreen(controller: controller, onFinished: (_) {})),
    );

    expect(find.text('工位桌面'), findsOneWidget);
    expect(find.text('手机'), findsOneWidget);
    expect(find.textContaining('外卖骑手'), findsOneWidget);
    expect(find.text('接电话'), findsOneWidget);
  });

  testWidgets('shows boss warning overlay for boss patrol event', (tester) async {
    final controller = GameSessionController(schedule: EventSchedule.buildDefault());
    controller.advanceToSecond(33);

    await tester.pumpWidget(
      MaterialApp(home: GameScreen(controller: controller, onFinished: (_) {})),
    );

    expect(find.textContaining('老板正在靠近'), findsOneWidget);
    expect(find.text('按住装忙'), findsOneWidget);
  });

  testWidgets('calls onFinished when the timer-driven session ends', (
    tester,
  ) async {
    final controller = GameSessionController(schedule: EventSchedule.buildDefault());
    GameSessionController? finishedController;

    await tester.pumpWidget(
      MaterialApp(
        home: GameScreen(
          controller: controller,
          onFinished: (value) => finishedController = value,
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 45));

    expect(finishedController, same(controller));
  });
}
