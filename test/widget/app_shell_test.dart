import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_game/app/app.dart';

void main() {
  testWidgets('shows title and start button on launch', (tester) async {
    await tester.pumpWidget(const WorkstationSurvivalApp());

    expect(find.text('工位求生'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '开始摸鱼求生'), findsOneWidget);
  });
}
