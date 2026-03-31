import 'package:flutter_test/flutter_test.dart';
import 'package:my_game/game/engine/event_schedule.dart';
import 'package:my_game/game/models/game_event.dart';

void main() {
  test('builds only single-pressure events in first 10 seconds', () {
    final schedule = EventSchedule.buildDefault();
    final earlyEvents =
        schedule.where((event) => event.triggerSecond < 10).toList();

    expect(earlyEvents, isNotEmpty);
    expect(earlyEvents.every((event) => !event.isHighPressure), isTrue);
  });

  test('contains exactly five event types', () {
    final schedule = EventSchedule.buildDefault();
    final types = schedule.map((event) => event.type).toSet();

    expect(types, {
      GameEventType.bossPatrol,
      GameEventType.blameChat,
      GameEventType.groupSpam,
      GameEventType.deliveryCall,
      GameEventType.systemError,
    });
  });
}
