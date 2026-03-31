import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_game/game/models/game_result.dart';
import 'package:my_game/results/result_screen.dart';

void main() {
  testWidgets('shows title, score, and nickname', (tester) async {
    const result = GameResult(
      score: 88,
      survivedSeconds: 45,
      completedEvents: 6,
      title: '摸鱼艺术家',
      summary: '你今天成功混过了 6 次职场危机。',
      isNewHighScore: true,
      bestScore: 88,
    );

    await tester.pumpWidget(
      MaterialApp(home: ResultScreen(result: result, onRestart: () {})),
    );

    expect(find.text('摸鱼艺术家'), findsOneWidget);
    expect(find.text('本局得分 88'), findsOneWidget);
    expect(find.textContaining('新纪录'), findsOneWidget);
    expect(find.textContaining('再来一局'), findsOneWidget);
  });
}
