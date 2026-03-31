enum GameEventType {
  bossPatrol,
  blameChat,
  groupSpam,
  deliveryCall,
  systemError,
}

enum GameInputType {
  tap,
  longPress,
  drag,
}

class GameEvent {
  const GameEvent({
    required this.type,
    required this.triggerSecond,
    required this.deadlineSecond,
    required this.inputType,
    required this.label,
    this.isHighPressure = false,
  });

  final GameEventType type;
  final int triggerSecond;
  final int deadlineSecond;
  final GameInputType inputType;
  final String label;
  final bool isHighPressure;
}
