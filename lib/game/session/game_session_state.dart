import 'package:my_game/game/models/game_event.dart';

class GameSessionState {
  const GameSessionState({
    required this.remainingSeconds,
    required this.survivalValue,
    required this.score,
    required this.missedEvents,
    required this.completedEvents,
    this.activeEvent,
    this.isGameOver = false,
  });

  final int remainingSeconds;
  final int survivalValue;
  final int score;
  final int missedEvents;
  final int completedEvents;
  final GameEvent? activeEvent;
  final bool isGameOver;

  GameSessionState copyWith({
    int? remainingSeconds,
    int? survivalValue,
    int? score,
    int? missedEvents,
    int? completedEvents,
    GameEvent? activeEvent,
    bool clearActiveEvent = false,
    bool? isGameOver,
  }) {
    return GameSessionState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      survivalValue: survivalValue ?? this.survivalValue,
      score: score ?? this.score,
      missedEvents: missedEvents ?? this.missedEvents,
      completedEvents: completedEvents ?? this.completedEvents,
      activeEvent: clearActiveEvent ? null : activeEvent ?? this.activeEvent,
      isGameOver: isGameOver ?? this.isGameOver,
    );
  }
}
