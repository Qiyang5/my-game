import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_game/game/models/game_event.dart';
import 'package:my_game/game/models/game_result.dart';
import 'package:my_game/game/session/game_session_controller.dart';
import 'package:my_game/results/result_screen.dart';

void main() {
  test('buildResult writes a specific failure summary for missed events', () {
    final controller = GameSessionController(
      schedule: const [
        GameEvent(
          type: GameEventType.bossPatrol,
          triggerSecond: 1,
          deadlineSecond: 2,
          inputType: GameInputType.tap,
          label: '老板来了',
          primaryActionLabel: '切屏',
        ),
      ],
    );

    controller.advanceToSecond(3);
    final result = controller.buildResult(
      isNewHighScore: false,
      bestScore: 42,
    );

    expect(result.title, '工位实习生');
    expect(
      result.summary,
      '你只救回了 0 次工位危机，1 次翻车已经够老板把事故复盘贴满全办公室。',
    );
  });

  testWidgets(
    'shows title, score, summary, and replay CTA as a failure report',
    (tester) async {
      const result = GameResult(
        score: 88,
        survivedSeconds: 45,
        completedEvents: 6,
        title: '摸鱼艺术家',
        summary: '你成功顶住了 6 次工位危机，但最后还是倒在老板回头杀。',
        isNewHighScore: true,
        bestScore: 88,
      );

      await tester.pumpWidget(
        MaterialApp(home: ResultScreen(result: result, onRestart: () {})),
      );

      expect(find.text('职场翻车报告'), findsOneWidget);
      expect(find.text('摸鱼艺术家'), findsOneWidget);
      expect(find.textContaining('工位危机'), findsOneWidget);
      expect(find.text('绩效分数'), findsOneWidget);
      expect(find.text('最高战绩'), findsOneWidget);
      expect(find.text('存活时长'), findsOneWidget);
      expect(find.text('处理危机'), findsOneWidget);
      expect(find.text('再来一局'), findsOneWidget);
    },
  );
}
