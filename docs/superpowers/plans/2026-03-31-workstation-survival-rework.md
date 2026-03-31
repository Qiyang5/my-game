# Workstation Survival Rework Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild the current MVP into a visually chaotic, semantically clear “desk disaster” game where players interact with concrete actions instead of abstract gesture labels.

**Architecture:** Keep the current Flutter app and pure-Dart game/session core, but replace the UI contract between events and players. The desktop surface becomes the main scene, event presentation becomes object-centric, and end-of-run feedback becomes a punchier office-failure report.

**Tech Stack:** Flutter, Dart, `flutter_test`, current game/session controller, `shared_preferences`

---

## File Structure

- `lib/app/app_shell.dart` — keeps home/game/result routing, updated copy and startup framing
- `lib/game/models/game_event.dart` — may gain display metadata for semantic actions
- `lib/game/screens/game_screen.dart` — reworked desk layout and event placement
- `lib/game/widgets/game_hud.dart` — top HUD, may keep existing layout with styling tweaks
- `lib/game/widgets/event_panel.dart` — likely replaced or heavily refactored into scene-specific affordances
- `lib/game/widgets/desk_scene.dart` — new main “chaotic desk” composition
- `lib/game/widgets/phone_panel.dart` — new phone area for call/message interruptions
- `lib/game/widgets/overlay_alerts.dart` — new boss/meeting/warning overlays
- `lib/results/result_screen.dart` — stronger “office failure report” presentation
- `test/widget/game_screen_test.dart` — validates desk scene and semantic actions
- `test/widget/result_screen_test.dart` — validates stronger result content
- `test/widget/app_shell_test.dart` — validates updated copy and startup screen
- `README.md` — update screenshots/description if needed after redesign

## Task 1: Add semantic event presentation metadata

**Files:**
- Modify: `lib/game/models/game_event.dart`
- Test: `test/unit/event_schedule_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
test('delivery call event exposes a semantic action label', () {
  final event = EventSchedule.buildDefault()
      .firstWhere((item) => item.type == GameEventType.deliveryCall);

  expect(event.primaryActionLabel, '接电话');
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/unit/event_schedule_test.dart`
Expected: FAIL because `primaryActionLabel` does not exist yet.

- [ ] **Step 3: Add minimal semantic metadata**

`lib/game/models/game_event.dart`

```dart
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
```

Update each event in `lib/game/engine/event_schedule.dart` with values like:

```dart
primaryActionLabel: '接电话',
secondaryLabel: '外卖员到了',
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/unit/event_schedule_test.dart`
Expected: PASS with semantic label assertion included.

- [ ] **Step 5: Commit**

```bash
git add lib/game/models/game_event.dart lib/game/engine/event_schedule.dart test/unit/event_schedule_test.dart
git commit -m "feat: add semantic labels for office events"
```

## Task 2: Replace generic event panel with a chaotic desk scene

**Files:**
- Create: `lib/game/widgets/desk_scene.dart`
- Create: `lib/game/widgets/phone_panel.dart`
- Create: `lib/game/widgets/overlay_alerts.dart`
- Modify: `lib/game/screens/game_screen.dart`
- Modify: `test/widget/game_screen_test.dart`

- [ ] **Step 1: Write the failing widget tests**

```dart
testWidgets('shows the desk scene with phone and computer areas', (tester) async {
  final controller = GameSessionController(schedule: EventSchedule.buildDefault());
  controller.advanceToSecond(14);

  await tester.pumpWidget(
    MaterialApp(home: GameScreen(controller: controller, onFinished: (_) {})),
  );

  expect(find.text('工位桌面'), findsOneWidget);
  expect(find.text('手机'), findsOneWidget);
  expect(find.textContaining('外卖骑手'), findsOneWidget);
  expect(find.text('接电话'), findsOneWidget);
});
```

```dart
testWidgets('shows boss warning overlay for boss patrol event', (tester) async {
  final controller = GameSessionController(schedule: EventSchedule.buildDefault());
  controller.advanceToSecond(33);

  await tester.pumpWidget(
    MaterialApp(home: GameScreen(controller: controller, onFinished: (_) {})),
  );

  expect(find.textContaining('老板正在靠近'), findsOneWidget);
  expect(find.text('按住装忙'), findsOneWidget);
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/widget/game_screen_test.dart`
Expected: FAIL because the new scene widgets do not exist yet.

- [ ] **Step 3: Build the minimal chaotic desk UI**

`lib/game/widgets/phone_panel.dart`

```dart
import 'package:flutter/material.dart';

class PhonePanel extends StatelessWidget {
  const PhonePanel({
    super.key,
    required this.title,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('手机', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: onPressed, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
```

`lib/game/widgets/overlay_alerts.dart`

```dart
import 'package:flutter/material.dart';

class OverlayAlerts extends StatelessWidget {
  const OverlayAlerts({
    super.key,
    required this.warningText,
    required this.actionLabel,
    required this.visible,
    required this.onPressed,
  });

  final String warningText;
  final String actionLabel;
  final bool visible;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Positioned(
      top: 24,
      right: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFD92D20),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(warningText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
```

`lib/game/widgets/desk_scene.dart`

```dart
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
              const Text('工位桌面', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                            Text(event!.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                            if (event!.secondaryLabel != null) ...[
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
                  title: isPhoneEvent ? event!.label : '暂无来电',
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
```

Update `lib/game/screens/game_screen.dart` to render `DeskScene` instead of the generic event panel.

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/widget/game_screen_test.dart`
Expected: PASS with the new desk-scene assertions.

- [ ] **Step 5: Commit**

```bash
git add lib/game/widgets/desk_scene.dart lib/game/widgets/phone_panel.dart lib/game/widgets/overlay_alerts.dart lib/game/screens/game_screen.dart test/widget/game_screen_test.dart
git commit -m "feat: redesign game screen as chaotic desk scene"
```

## Task 3: Strengthen failure feedback and finish reliability

**Files:**
- Modify: `lib/game/screens/game_screen.dart`
- Modify: `lib/game/widgets/game_hud.dart`
- Modify: `test/widget/game_screen_test.dart`

- [ ] **Step 1: Write the failing widget tests**

```dart
testWidgets('shows a red danger treatment when boss patrol is active', (tester) async {
  final controller = GameSessionController(schedule: EventSchedule.buildDefault());
  controller.advanceToSecond(33);

  await tester.pumpWidget(
    MaterialApp(home: GameScreen(controller: controller, onFinished: (_) {})),
  );

  expect(find.textContaining('老板正在靠近'), findsOneWidget);
  expect(find.textContaining('按住装忙'), findsOneWidget);
});
```

```dart
testWidgets('timer-driven run still calls onFinished exactly once', (tester) async {
  final controller = GameSessionController(schedule: EventSchedule.buildDefault());
  var finishCount = 0;

  await tester.pumpWidget(
    MaterialApp(
      home: GameScreen(
        controller: controller,
        onFinished: (_) => finishCount += 1,
      ),
    ),
  );

  await tester.pump(const Duration(seconds: 46));

  expect(finishCount, 1);
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/widget/game_screen_test.dart`
Expected: FAIL until the stronger visual feedback and one-shot flow are in place.

- [ ] **Step 3: Add minimal feedback polish**

Update `lib/game/widgets/game_hud.dart` to tint the progress indicator red/orange when survival is below 40, and update `GameScreen` / `DeskScene` styling so high-pressure events show a visible warning treatment.

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/widget/game_screen_test.dart`
Expected: PASS with danger feedback and one-shot finish behavior covered.

- [ ] **Step 5: Commit**

```bash
git add lib/game/screens/game_screen.dart lib/game/widgets/game_hud.dart test/widget/game_screen_test.dart
git commit -m "feat: add stronger failure feedback"
```

## Task 4: Make result screen feel like an office failure report

**Files:**
- Modify: `lib/results/result_screen.dart`
- Modify: `lib/game/session/game_session_controller.dart`
- Modify: `test/widget/result_screen_test.dart`

- [ ] **Step 1: Write the failing widget test**

```dart
testWidgets('shows title, score, summary, and replay CTA as a failure report', (tester) async {
  const result = GameResult(
    score: 88,
    survivedSeconds: 45,
    completedEvents: 6,
    title: '摸鱼艺术家',
    summary: '你成功顶住了 6 次工位危机，但最后还是倒在老板回头杀。',
    isNewHighScore: true,
    bestScore: 88,
  );

  await tester.pumpWidget(
    MaterialApp(home: ResultScreen(result: result, onRestart: () {})),
  );

  expect(find.text('摸鱼艺术家'), findsOneWidget);
  expect(find.textContaining('工位危机'), findsOneWidget);
  expect(find.text('再来一局'), findsOneWidget);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widget/result_screen_test.dart`
Expected: FAIL until the updated result copy and layout are in place.

- [ ] **Step 3: Update result modeling and UI**

Update `GameSessionController.buildResult()` so it produces punchier summary lines based on score/missed events, then update `ResultScreen` to show:

- title
- score
- best score
- survived seconds
- completed events
- summary line
- replay button

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widget/result_screen_test.dart`
Expected: PASS with the new result-report presentation.

- [ ] **Step 5: Commit**

```bash
git add lib/results/result_screen.dart lib/game/session/game_session_controller.dart test/widget/result_screen_test.dart
git commit -m "feat: upgrade result screen into failure report"
```

## Task 5: Refresh startup copy and document the redesign

**Files:**
- Modify: `lib/app/app_shell.dart`
- Modify: `test/widget/app_shell_test.dart`
- Modify: `README.md`

- [ ] **Step 1: Write the failing assertions**

```dart
expect(find.textContaining('45 秒内顶住工位灾难'), findsOneWidget);
expect(find.textContaining('开始工位求生'), findsOneWidget);
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widget/app_shell_test.dart`
Expected: FAIL until the startup copy is updated.

- [ ] **Step 3: Update startup copy and README**

Update home screen copy to match the redesign and update `README.md` so it describes:

- chaotic desk scene
- semantic actions
- 45-second survival run
- how to run/test

- [ ] **Step 4: Run full test suite**

Run: `flutter test`
Expected: PASS with all updated unit and widget tests green.

- [ ] **Step 5: Commit**

```bash
git add lib/app/app_shell.dart test/widget/app_shell_test.dart README.md
git commit -m "docs: refresh startup copy for reworked gameplay"
```

## Self-Review

- Spec coverage check: the plan covers semantic actions, chaotic desk UI, stronger failure feedback, reworked result presentation, and startup copy/docs refresh.
- Placeholder scan: no `TODO`, `TBD`, or vague “fix later” wording remains.
- Type consistency check: `GameEvent`, `GameSessionController`, `GameResult`, and the new widget names stay consistent across tasks.
