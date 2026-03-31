import 'package:my_game/game/models/game_event.dart';

class EventSchedule {
  static List<GameEvent> buildDefault() {
    return const [
      GameEvent(
        type: GameEventType.groupSpam,
        triggerSecond: 3,
        deadlineSecond: 6,
        inputType: GameInputType.tap,
        label: '群里突然有人@全体成员',
      ),
      GameEvent(
        type: GameEventType.blameChat,
        triggerSecond: 8,
        deadlineSecond: 12,
        inputType: GameInputType.tap,
        label: '同事发来一句：这个你顺手做了吧？',
      ),
      GameEvent(
        type: GameEventType.deliveryCall,
        triggerSecond: 14,
        deadlineSecond: 17,
        inputType: GameInputType.tap,
        label: '外卖骑手开始夺命连环 call',
      ),
      GameEvent(
        type: GameEventType.systemError,
        triggerSecond: 22,
        deadlineSecond: 26,
        inputType: GameInputType.longPress,
        label: '电脑报错：是否立即重试？',
        isHighPressure: true,
      ),
      GameEvent(
        type: GameEventType.bossPatrol,
        triggerSecond: 33,
        deadlineSecond: 36,
        inputType: GameInputType.drag,
        label: '老板正在靠近你的工位',
        isHighPressure: true,
      ),
    ];
  }
}
