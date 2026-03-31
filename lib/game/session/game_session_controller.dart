import 'package:my_game/game/models/game_event.dart';
import 'package:my_game/game/session/game_session_state.dart';

class GameSessionController {
  GameSessionController({required List<GameEvent> schedule})
      : _schedule = schedule,
        _state = const GameSessionState(
          remainingSeconds: 45,
          survivalValue: 100,
          score: 0,
          missedEvents: 0,
          completedEvents: 0,
        );

  final List<GameEvent> _schedule;
  GameSessionState _state;
  int _cursor = 0;

  GameSessionState get state => _state;

  void advanceToSecond(int elapsedSecond) {
    final nextRemaining = 45 - elapsedSecond;
    _state = _state.copyWith(
      remainingSeconds: nextRemaining.clamp(0, 45),
      isGameOver: nextRemaining <= 0 || _state.survivalValue <= 0,
    );

    if (_state.isGameOver) return;

    if (_state.activeEvent != null &&
        elapsedSecond > _state.activeEvent!.deadlineSecond) {
      _state = _state.copyWith(
        survivalValue: (_state.survivalValue - 20).clamp(0, 100),
        missedEvents: _state.missedEvents + 1,
        clearActiveEvent: true,
        isGameOver: _state.survivalValue - 20 <= 0,
      );
    }

    if (_state.activeEvent == null &&
        _cursor < _schedule.length &&
        elapsedSecond >= _schedule[_cursor].triggerSecond) {
      _state = _state.copyWith(activeEvent: _schedule[_cursor]);
      _cursor += 1;
    }
  }

  void submit(GameInputType inputType) {
    final activeEvent = _state.activeEvent;
    if (activeEvent == null || inputType != activeEvent.inputType) {
      _state = _state.copyWith(
        survivalValue: (_state.survivalValue - 10).clamp(0, 100),
        isGameOver: _state.survivalValue - 10 <= 0,
      );
      return;
    }

    _state = _state.copyWith(
      score: _state.score + (activeEvent.isHighPressure ? 15 : 10),
      completedEvents: _state.completedEvents + 1,
      clearActiveEvent: true,
    );
  }
}
