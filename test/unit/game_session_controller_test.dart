import 'package:flutter_test/flutter_test.dart';
import 'package:my_game/game/engine/event_schedule.dart';
import 'package:my_game/game/models/game_event.dart';
import 'package:my_game/game/session/game_session_controller.dart';

void main() {
  test('starts at 45 seconds with full survival', () {
    final controller = GameSessionController(schedule: EventSchedule.buildDefault());

    expect(controller.state.remainingSeconds, 45);
    expect(controller.state.survivalValue, 100);
    expect(controller.state.score, 0);
  });

  test('successful action increases score and clears active event', () {
    final controller = GameSessionController(schedule: EventSchedule.buildDefault());

    controller.advanceToSecond(3);
    controller.submit(GameInputType.tap);

    expect(controller.state.score, 10);
    expect(controller.state.activeEvent, isNull);
  });

  test('expired event removes survival value', () {
    final controller = GameSessionController(schedule: EventSchedule.buildDefault());

    controller.advanceToSecond(3);
    controller.advanceToSecond(7);

    expect(controller.state.survivalValue, 80);
    expect(controller.state.missedEvents, 1);
  });

  test('jumping forward skips missed events and activates the current one', () {
    final controller = GameSessionController(schedule: EventSchedule.buildDefault());

    controller.advanceToSecond(14);

    expect(controller.state.missedEvents, 2);
    expect(controller.state.survivalValue, 60);
    expect(controller.state.activeEvent?.type, GameEventType.deliveryCall);
  });

  test('submit does not mutate state after game over', () {
    final controller = GameSessionController(schedule: EventSchedule.buildDefault());

    controller.advanceToSecond(3);
    controller.advanceToSecond(45);
    controller.submit(GameInputType.tap);

    expect(controller.state.isGameOver, isTrue);
    expect(controller.state.score, 0);
    expect(controller.state.completedEvents, 0);
    expect(controller.state.activeEvent, isNull);
  });

  test('game is over after 45 seconds elapsed', () {
    final controller = GameSessionController(schedule: EventSchedule.buildDefault());

    controller.advanceToSecond(45);

    expect(controller.state.isGameOver, isTrue);
    expect(controller.state.remainingSeconds, 0);
  });
}
