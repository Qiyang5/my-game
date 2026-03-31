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
        primaryActionLabel: '点关键消息',
        secondaryLabel: '先回最危险的那条',
      ),
      GameEvent(
        type: GameEventType.blameChat,
        triggerSecond: 8,
        deadlineSecond: 12,
        inputType: GameInputType.tap,
        label: '同事发来一句：这个你顺手做了吧？',
        primaryActionLabel: '回一句收到',
        secondaryLabel: '先稳住再说',
      ),
      GameEvent(
        type: GameEventType.deliveryCall,
        triggerSecond: 14,
        deadlineSecond: 17,
        inputType: GameInputType.tap,
        label: '外卖骑手开始夺命连环 call',
        primaryActionLabel: '接电话',
        secondaryLabel: '外卖员到了',
      ),
      GameEvent(
        type: GameEventType.systemError,
        triggerSecond: 22,
        deadlineSecond: 26,
        inputType: GameInputType.longPress,
        label: '电脑报错：是否立即重试？',
        primaryActionLabel: '按住重试',
        secondaryLabel: '先别让系统彻底卡死',
        isHighPressure: true,
      ),
      GameEvent(
        type: GameEventType.bossPatrol,
        triggerSecond: 33,
        deadlineSecond: 36,
        inputType: GameInputType.drag,
        label: '老板正在靠近你的工位',
        primaryActionLabel: '拖走摸鱼页',
        secondaryLabel: '把危险窗口藏起来',
        isHighPressure: true,
      ),
    ];
  }
}
