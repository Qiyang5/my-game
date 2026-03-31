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
    required this.primaryActionLabel,
    this.secondaryLabel,
    this.isHighPressure = false,
  });

  final GameEventType type;
  final int triggerSecond;
  final int deadlineSecond;
  final GameInputType inputType;
  final String label;
  final String primaryActionLabel;
  final String? secondaryLabel;
  final bool isHighPressure;
}
