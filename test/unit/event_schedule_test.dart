import 'package:flutter_test/flutter_test.dart';
import 'package:my_game/game/engine/event_schedule.dart';
import 'package:my_game/game/models/game_event.dart';

void main() {
  test('builds the exact default schedule in the expected order', () {
    final schedule = EventSchedule.buildDefault();

    expect(schedule, hasLength(5));

    expect(schedule[0].type, GameEventType.groupSpam);
    expect(schedule[0].triggerSecond, 3);
    expect(schedule[0].deadlineSecond, 6);
    expect(schedule[0].inputType, GameInputType.tap);
    expect(schedule[0].isHighPressure, isFalse);

    expect(schedule[1].type, GameEventType.blameChat);
    expect(schedule[1].triggerSecond, 8);
    expect(schedule[1].deadlineSecond, 12);
    expect(schedule[1].inputType, GameInputType.tap);
    expect(schedule[1].isHighPressure, isFalse);

    expect(schedule[2].type, GameEventType.deliveryCall);
    expect(schedule[2].triggerSecond, 14);
    expect(schedule[2].deadlineSecond, 17);
    expect(schedule[2].inputType, GameInputType.tap);
    expect(schedule[2].isHighPressure, isFalse);

    expect(schedule[3].type, GameEventType.systemError);
    expect(schedule[3].triggerSecond, 22);
    expect(schedule[3].deadlineSecond, 26);
    expect(schedule[3].inputType, GameInputType.longPress);
    expect(schedule[3].isHighPressure, isTrue);

    expect(schedule[4].type, GameEventType.bossPatrol);
    expect(schedule[4].triggerSecond, 33);
    expect(schedule[4].deadlineSecond, 36);
    expect(schedule[4].inputType, GameInputType.drag);
    expect(schedule[4].isHighPressure, isTrue);
  });
}
