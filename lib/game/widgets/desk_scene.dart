import 'package:flutter/material.dart';
import 'package:my_game/game/models/game_event.dart';
import 'package:my_game/game/widgets/overlay_alerts.dart';
import 'package:my_game/game/widgets/phone_panel.dart';

class DeskScene extends StatelessWidget {
  const DeskScene({
    super.key,
    required this.event,
    required this.onTapAction,
    required this.onLongPressAction,
    required this.onDragAction,
  });

  final GameEvent? event;
  final VoidCallback onTapAction;
  final VoidCallback onLongPressAction;
  final VoidCallback onDragAction;

  @override
  Widget build(BuildContext context) {
    final isPhoneEvent = event?.type == GameEventType.deliveryCall;
    final isBossEvent = event?.type == GameEventType.bossPatrol;
    final deskTitle = isBossEvent ? '危险窗口还挂在桌面上' : event?.label;
    final phoneTitle = isPhoneEvent
        ? (event?.secondaryLabel ?? event?.label ?? '暂无来电')
        : '暂无来电';

    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF4E8D8),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '工位桌面',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCFCFD),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFD0D5DD)),
                  ),
                  child: event == null
                      ? const Text('暂时安全，但你知道这只是暴风雨前的宁静。')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (deskTitle != null)
                              Text(
                                deskTitle,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            if (event!.secondaryLabel != null && !isPhoneEvent) ...[
                              const SizedBox(height: 8),
                              Text(event!.secondaryLabel!),
                            ],
                            const Spacer(),
                            if (!isPhoneEvent && !isBossEvent)
                              ElevatedButton(
                                onPressed: event!.inputType == GameInputType.tap
                                    ? onTapAction
                                    : event!.inputType == GameInputType.longPress
                                        ? onLongPressAction
                                        : onDragAction,
                                child: Text(event!.primaryActionLabel),
                              ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.bottomLeft,
                child: PhonePanel(
                  title: phoneTitle,
                  actionLabel: isPhoneEvent ? event!.primaryActionLabel : '保持静音',
                  onPressed: isPhoneEvent ? onTapAction : () {},
                ),
              ),
            ],
          ),
        ),
        OverlayAlerts(
          warningText: isBossEvent ? event!.label : '',
          actionLabel: isBossEvent ? event!.primaryActionLabel : '',
          visible: isBossEvent,
          onPressed: onLongPressAction,
        ),
      ],
    );
  }
}
