import 'package:my_game/game/models/game_event.dart';
import 'package:my_game/game/models/game_result.dart';
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
    _state = _state.copyWith(remainingSeconds: nextRemaining.clamp(0, 45));

    while (!_state.isGameOver &&
        _state.activeEvent != null &&
        elapsedSecond > _state.activeEvent!.deadlineSecond) {
      _missActiveEvent();
    }

    while (!_state.isGameOver &&
        _state.activeEvent == null &&
        _cursor < _schedule.length) {
      final nextEvent = _schedule[_cursor];
      if (elapsedSecond > nextEvent.deadlineSecond) {
        _cursor += 1;
        _state = _state.copyWith(activeEvent: nextEvent);
        _missActiveEvent();
        continue;
      }

      if (elapsedSecond >= nextEvent.triggerSecond) {
        _state = _state.copyWith(activeEvent: nextEvent);
        _cursor += 1;
      }

      break;
    }

    final isGameOver = nextRemaining <= 0 || _state.survivalValue <= 0;
    _state = _state.copyWith(
      isGameOver: isGameOver,
      clearActiveEvent: isGameOver,
    );
  }

  void submit(GameInputType inputType) {
    if (_state.isGameOver) {
      return;
    }

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

  void submitTap() => submit(GameInputType.tap);
  void submitLongPress() => submit(GameInputType.longPress);
  void submitDrag() => submit(GameInputType.drag);

  GameResult buildResult({
    required bool isNewHighScore,
    required int bestScore,
  }) {
    final survivedSeconds = 45 - _state.remainingSeconds;
    final title = _state.score >= 60
        ? '摸鱼艺术家'
        : (_state.score >= 30 ? '背锅特种兵' : '工位实习生');
    final summary = '你今天成功混过了 ${_state.completedEvents} 次职场危机。';

    return GameResult(
      score: _state.score,
      survivedSeconds: survivedSeconds,
      completedEvents: _state.completedEvents,
      title: title,
      summary: summary,
      isNewHighScore: isNewHighScore,
      bestScore: bestScore,
    );
  }

  void _missActiveEvent() {
    final nextSurvival = (_state.survivalValue - 20).clamp(0, 100);
    _state = _state.copyWith(
      survivalValue: nextSurvival,
      missedEvents: _state.missedEvents + 1,
      clearActiveEvent: true,
      isGameOver: nextSurvival <= 0,
    );
  }
}
