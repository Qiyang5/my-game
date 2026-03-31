# Workstation Survival MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a portrait Flutter MVP for `Workstation Survival`, a 45-second single-player office survival mini-game with five event types, a result screen, and local high-score persistence.

**Architecture:** Start from an empty repo with a standard Flutter app, then keep gameplay logic in pure Dart classes that can be tested without pumping timers. The widget layer should remain thin: screens render `GameSessionState`, dispatch player actions, and show transitions between home, game, and result states.

**Tech Stack:** Flutter, Dart, `flutter_test`, `shared_preferences`

---

## File Structure

- `pubspec.yaml` — project metadata and dependencies
- `lib/main.dart` — Flutter entrypoint
- `lib/app/app.dart` — root `MaterialApp`
- `lib/app/app_shell.dart` — stateful shell that swaps home/game/result views
- `lib/game/models/game_event.dart` — event types, timing, and input requirements
- `lib/game/models/game_result.dart` — summary object for result screen
- `lib/game/engine/event_schedule.dart` — deterministic event schedule builder
- `lib/game/session/game_session_controller.dart` — pure Dart gameplay state machine
- `lib/game/session/game_session_state.dart` — immutable game session snapshot
- `lib/game/widgets/game_hud.dart` — timer, score, and survival UI
- `lib/game/widgets/event_panel.dart` — renders active event and input affordances
- `lib/game/screens/game_screen.dart` — binds controller state to widgets
- `lib/results/result_screen.dart` — result UI with title, score, and CTA
- `lib/storage/high_score_store.dart` — local persistence wrapper
- `test/widget/app_shell_test.dart` — app shell smoke test
- `test/unit/event_schedule_test.dart` — schedule rules tests
- `test/unit/game_session_controller_test.dart` — scoring, timeout, and fail state tests
- `test/widget/game_screen_test.dart` — HUD and active event rendering tests
- `test/widget/result_screen_test.dart` — result and high-score presentation tests

## Task 1: Bootstrap the Flutter app shell

**Files:**
- Create: `pubspec.yaml`
- Create: `lib/main.dart`
- Create: `lib/app/app.dart`
- Create: `lib/app/app_shell.dart`
- Test: `test/widget/app_shell_test.dart`

- [ ] **Step 1: Write the failing widget test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_game/app/app.dart';

void main() {
  testWidgets('shows title and start button on launch', (tester) async {
    await tester.pumpWidget(const WorkstationSurvivalApp());

    expect(find.text('工位求生'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '开始摸鱼求生'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widget/app_shell_test.dart`
Expected: FAIL with import errors because `lib/app/app.dart` does not exist yet.

- [ ] **Step 3: Create the minimal app shell**

`pubspec.yaml`

```yaml
name: my_game
description: Workstation Survival Flutter MVP
publish_to: none
version: 0.1.0+1

environment:
  sdk: ">=3.6.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.5.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
```

`lib/main.dart`

```dart
import 'package:flutter/widgets.dart';
import 'package:my_game/app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WorkstationSurvivalApp());
}
```

`lib/app/app.dart`

```dart
import 'package:flutter/material.dart';
import 'package:my_game/app/app_shell.dart';

class WorkstationSurvivalApp extends StatelessWidget {
  const WorkstationSurvivalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '工位求生',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B4BFF)),
        scaffoldBackgroundColor: const Color(0xFFF6F3FF),
      ),
      home: const AppShell(),
    );
  }
}
```

`lib/app/app_shell.dart`

```dart
import 'package:flutter/material.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '工位求生',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  '45 秒内活过老板巡逻、群消息轰炸和临时会议。',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('开始摸鱼求生'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widget/app_shell_test.dart`
Expected: PASS with `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml lib/main.dart lib/app/app.dart lib/app/app_shell.dart test/widget/app_shell_test.dart
git commit -m "feat: bootstrap workstation survival app shell"
```

## Task 2: Add event models and deterministic schedule

**Files:**
- Create: `lib/game/models/game_event.dart`
- Create: `lib/game/engine/event_schedule.dart`
- Test: `test/unit/event_schedule_test.dart`

- [ ] **Step 1: Write the failing schedule tests**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:my_game/game/engine/event_schedule.dart';
import 'package:my_game/game/models/game_event.dart';

void main() {
  test('builds only single-pressure events in first 10 seconds', () {
    final schedule = EventSchedule.buildDefault();
    final earlyEvents = schedule.where((event) => event.triggerSecond < 10).toList();

    expect(earlyEvents, isNotEmpty);
    expect(earlyEvents.every((event) => !event.isHighPressure), isTrue);
  });

  test('contains exactly five event types', () {
    final schedule = EventSchedule.buildDefault();
    final types = schedule.map((event) => event.type).toSet();

    expect(types, {
      GameEventType.bossPatrol,
      GameEventType.blameChat,
      GameEventType.groupSpam,
      GameEventType.deliveryCall,
      GameEventType.systemError,
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/unit/event_schedule_test.dart`
Expected: FAIL because `EventSchedule` and `GameEvent` do not exist yet.

- [ ] **Step 3: Implement the event model and schedule**

`lib/game/models/game_event.dart`

```dart
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
```

`lib/game/engine/event_schedule.dart`

```dart
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
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/unit/event_schedule_test.dart`
Expected: PASS with `2 passed`

- [ ] **Step 5: Commit**

```bash
git add lib/game/models/game_event.dart lib/game/engine/event_schedule.dart test/unit/event_schedule_test.dart
git commit -m "feat: add deterministic office event schedule"
```

## Task 3: Implement the pure Dart game session controller

**Files:**
- Create: `lib/game/session/game_session_state.dart`
- Create: `lib/game/session/game_session_controller.dart`
- Test: `test/unit/game_session_controller_test.dart`

- [ ] **Step 1: Write the failing controller tests**

```dart
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

    controller.advanceToSecond(14);
    controller.advanceToSecond(18);

    expect(controller.state.survivalValue, lessThan(100));
    expect(controller.state.missedEvents, 1);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/unit/game_session_controller_test.dart`
Expected: FAIL because session files do not exist yet.

- [ ] **Step 3: Implement immutable state and controller**

`lib/game/session/game_session_state.dart`

```dart
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
```

`lib/game/session/game_session_controller.dart`

```dart
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
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/unit/game_session_controller_test.dart`
Expected: PASS with `3 passed`

- [ ] **Step 5: Commit**

```bash
git add lib/game/session/game_session_state.dart lib/game/session/game_session_controller.dart test/unit/game_session_controller_test.dart
git commit -m "feat: add pure dart game session controller"
```

## Task 4: Render the gameplay HUD and active event panel

**Files:**
- Create: `lib/game/widgets/game_hud.dart`
- Create: `lib/game/widgets/event_panel.dart`
- Create: `lib/game/screens/game_screen.dart`
- Modify: `lib/app/app_shell.dart`
- Test: `test/widget/game_screen_test.dart`

- [ ] **Step 1: Write the failing widget test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_game/game/engine/event_schedule.dart';
import 'package:my_game/game/screens/game_screen.dart';
import 'package:my_game/game/session/game_session_controller.dart';

void main() {
  testWidgets('renders timer, score, and active event label', (tester) async {
    final controller = GameSessionController(schedule: EventSchedule.buildDefault());
    controller.advanceToSecond(3);

    await tester.pumpWidget(
      MaterialApp(home: GameScreen(controller: controller, onFinished: (_) {})),
    );

    expect(find.text('剩余 42 秒'), findsOneWidget);
    expect(find.textContaining('群里突然有人'), findsOneWidget);
    expect(find.text('分数 0'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widget/game_screen_test.dart`
Expected: FAIL because `GameScreen` widgets do not exist yet.

- [ ] **Step 3: Implement the HUD, event panel, and game screen**

`lib/game/widgets/game_hud.dart`

```dart
import 'package:flutter/material.dart';

class GameHud extends StatelessWidget {
  const GameHud({
    super.key,
    required this.remainingSeconds,
    required this.survivalValue,
    required this.score,
  });

  final int remainingSeconds;
  final int survivalValue;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('剩余 $remainingSeconds 秒', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: survivalValue / 100),
        const SizedBox(height: 8),
        Text('分数 $score'),
      ],
    );
  }
}
```

`lib/game/widgets/event_panel.dart`

```dart
import 'package:flutter/material.dart';
import 'package:my_game/game/models/game_event.dart';

class EventPanel extends StatelessWidget {
  const EventPanel({
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
    if (event == null) {
      return const Center(child: Text('工位暂时安全，先深呼吸一下。'));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(event!.label, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onTapAction, child: const Text('点击处理')),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: onLongPressAction, child: const Text('长按处理')),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: onDragAction, child: const Text('拖拽处理')),
          ],
        ),
      ),
    );
  }
}
```

`lib/game/screens/game_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:my_game/game/session/game_session_controller.dart';
import 'package:my_game/game/widgets/event_panel.dart';
import 'package:my_game/game/widgets/game_hud.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.controller,
    required this.onFinished,
  });

  final GameSessionController controller;
  final ValueChanged<GameSessionController> onFinished;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  void _submitTap() {
    setState(() {
      widget.controller.submitTap();
    });
  }

  void _submitLongPress() {
    setState(() {
      widget.controller.submitLongPress();
    });
  }

  void _submitDrag() {
    setState(() {
      widget.controller.submitDrag();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;

    return Scaffold(
      appBar: AppBar(title: const Text('今日工位战况')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GameHud(
              remainingSeconds: state.remainingSeconds,
              survivalValue: state.survivalValue,
              score: state.score,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: EventPanel(
                  event: state.activeEvent,
                  onTapAction: _submitTap,
                  onLongPressAction: _submitLongPress,
                  onDragAction: _submitDrag,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

`lib/app/app_shell.dart`

```dart
import 'package:flutter/material.dart';
import 'package:my_game/game/engine/event_schedule.dart';
import 'package:my_game/game/screens/game_screen.dart';
import 'package:my_game/game/session/game_session_controller.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _inGame = false;
  GameSessionController? _controller;

  void _startGame() {
    setState(() {
      _controller = GameSessionController(schedule: EventSchedule.buildDefault());
      _inGame = true;
    });
  }

  void _finishGame(GameSessionController _) {
    setState(() {
      _inGame = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_inGame && _controller != null) {
      return GameScreen(
        controller: _controller!,
        onFinished: _finishGame,
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('工位求生', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text('45 秒内活过老板巡逻、群消息轰炸和临时会议。', textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: _startGame, child: const Text('开始摸鱼求生')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widget/game_screen_test.dart`
Expected: PASS with `1 passed`

- [ ] **Step 5: Commit**

```bash
git add lib/game/widgets/game_hud.dart lib/game/widgets/event_panel.dart lib/game/screens/game_screen.dart lib/app/app_shell.dart test/widget/game_screen_test.dart
git commit -m "feat: add gameplay hud and event panel"
```

## Task 5: Add result model, end-of-game flow, and local high score

**Files:**
- Create: `lib/game/models/game_result.dart`
- Create: `lib/results/result_screen.dart`
- Create: `lib/storage/high_score_store.dart`
- Modify: `lib/app/app_shell.dart`
- Modify: `lib/game/session/game_session_controller.dart`
- Test: `test/widget/result_screen_test.dart`

- [ ] **Step 1: Write the failing result screen test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_game/game/models/game_result.dart';
import 'package:my_game/results/result_screen.dart';

void main() {
  testWidgets('shows title, score, and nickname', (tester) async {
    const result = GameResult(
      score: 88,
      survivedSeconds: 45,
      completedEvents: 6,
      title: '摸鱼艺术家',
      summary: '你今天成功混过了 6 次职场危机。',
      isNewHighScore: true,
      bestScore: 88,
    );

    await tester.pumpWidget(
      MaterialApp(home: ResultScreen(result: result, onRestart: () {})),
    );

    expect(find.text('摸鱼艺术家'), findsOneWidget);
    expect(find.text('本局得分 88'), findsOneWidget);
    expect(find.textContaining('新纪录'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widget/result_screen_test.dart`
Expected: FAIL because result files do not exist yet.

- [ ] **Step 3: Implement result model, persistence, and result screen**

`lib/game/models/game_result.dart`

```dart
class GameResult {
  const GameResult({
    required this.score,
    required this.survivedSeconds,
    required this.completedEvents,
    required this.title,
    required this.summary,
    required this.isNewHighScore,
    required this.bestScore,
  });

  final int score;
  final int survivedSeconds;
  final int completedEvents;
  final String title;
  final String summary;
  final bool isNewHighScore;
  final int bestScore;
}
```

`lib/storage/high_score_store.dart`

```dart
import 'package:shared_preferences/shared_preferences.dart';

class HighScoreStore {
  static const _key = 'best_score';

  Future<int> readBestScore() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt(_key) ?? 0;
  }

  Future<bool> writeIfHigher(int score) async {
    final preferences = await SharedPreferences.getInstance();
    final current = preferences.getInt(_key) ?? 0;
    if (score <= current) return false;
    await preferences.setInt(_key, score);
    return true;
  }
}
```

`lib/results/result_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:my_game/game/models/game_result.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.result,
    required this.onRestart,
  });

  final GameResult result;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(result.title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('本局得分 ${result.score}'),
              const SizedBox(height: 8),
              Text('最高分 ${result.bestScore}'),
              const SizedBox(height: 8),
              if (result.isNewHighScore) const Text('新纪录！今天的工位属于你。'),
              const SizedBox(height: 16),
              Text(result.summary, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: onRestart, child: const Text('再来一局')),
            ],
          ),
        ),
      ),
    );
  }
}
```

`lib/game/session/game_session_controller.dart`

```dart
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
    _state = _state.copyWith(
      remainingSeconds: nextRemaining.clamp(0, 45),
      isGameOver: nextRemaining <= 0 || _state.survivalValue <= 0,
    );

    if (_state.isGameOver) return;

    if (_state.activeEvent != null &&
        elapsedSecond > _state.activeEvent!.deadlineSecond) {
      final nextSurvival = (_state.survivalValue - 20).clamp(0, 100);
      _state = _state.copyWith(
        survivalValue: nextSurvival,
        missedEvents: _state.missedEvents + 1,
        clearActiveEvent: true,
        isGameOver: nextSurvival <= 0,
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
      final nextSurvival = (_state.survivalValue - 10).clamp(0, 100);
      _state = _state.copyWith(
        survivalValue: nextSurvival,
        isGameOver: nextSurvival <= 0,
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

  GameResult buildResult({required bool isNewHighScore, required int bestScore}) {
    final survivedSeconds = 45 - _state.remainingSeconds;
    final title = _state.score >= 60 ? '摸鱼艺术家' : (_state.score >= 30 ? '背锅特种兵' : '工位实习生');
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
}
```

`lib/app/app_shell.dart`

```dart
import 'package:flutter/material.dart';
import 'package:my_game/game/engine/event_schedule.dart';
import 'package:my_game/game/models/game_result.dart';
import 'package:my_game/game/screens/game_screen.dart';
import 'package:my_game/game/session/game_session_controller.dart';
import 'package:my_game/results/result_screen.dart';
import 'package:my_game/storage/high_score_store.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final HighScoreStore _highScoreStore = HighScoreStore();
  GameSessionController? _controller;
  GameResult? _lastResult;

  void _startGame() {
    setState(() {
      _controller = GameSessionController(schedule: EventSchedule.buildDefault());
      _lastResult = null;
    });
  }

  Future<void> _finishGame(GameSessionController controller) async {
    final isNewHighScore = await _highScoreStore.writeIfHigher(controller.state.score);
    final bestScore = await _highScoreStore.readBestScore();

    setState(() {
      _lastResult = controller.buildResult(
        isNewHighScore: isNewHighScore,
        bestScore: bestScore,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_lastResult != null) {
      return ResultScreen(
        result: _lastResult!,
        onRestart: _startGame,
      );
    }

    if (_controller != null) {
      return GameScreen(
        controller: _controller!,
        onFinished: _finishGame,
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('工位求生', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text('45 秒内活过老板巡逻、群消息轰炸和临时会议。', textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: _startGame, child: const Text('开始摸鱼求生')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widget/result_screen_test.dart`
Expected: PASS with `1 passed`

- [ ] **Step 5: Commit**

```bash
git add lib/game/models/game_result.dart lib/results/result_screen.dart lib/storage/high_score_store.dart lib/game/session/game_session_controller.dart lib/app/app_shell.dart test/widget/result_screen_test.dart
git commit -m "feat: add results flow and local high score"
```

## Task 6: Wire live countdown and finish conditions

**Files:**
- Modify: `lib/game/screens/game_screen.dart`
- Modify: `lib/game/session/game_session_controller.dart`
- Modify: `test/unit/game_session_controller_test.dart`
- Modify: `test/widget/game_screen_test.dart`

- [ ] **Step 1: Write failing tests for countdown completion**

```dart
test('game is over after 45 seconds elapsed', () {
  final controller = GameSessionController(schedule: EventSchedule.buildDefault());

  controller.advanceToSecond(45);

  expect(controller.state.isGameOver, isTrue);
  expect(controller.state.remainingSeconds, 0);
});
```

```dart
testWidgets('calls onFinished when the session ends', (tester) async {
  final controller = GameSessionController(schedule: EventSchedule.buildDefault());
  GameSessionController? finishedController;

  await tester.pumpWidget(
    MaterialApp(
      home: GameScreen(
        controller: controller,
        onFinished: (value) => finishedController = value,
      ),
    ),
  );

  controller.advanceToSecond(45);
  await tester.pump();

  expect(finishedController, same(controller));
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/unit/game_session_controller_test.dart test/widget/game_screen_test.dart`
Expected: FAIL because `GameScreen` does not yet observe session end.

- [ ] **Step 3: Add ticker-driven countdown and finish callback**

`lib/game/screens/game_screen.dart`

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_game/game/session/game_session_controller.dart';
import 'package:my_game/game/widgets/event_panel.dart';
import 'package:my_game/game/widgets/game_hud.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.controller,
    required this.onFinished,
  });

  final GameSessionController controller;
  final ValueChanged<GameSessionController> onFinished;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Timer? _timer;
  int _elapsed = 0;
  bool _didFinish = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed += 1;
        widget.controller.advanceToSecond(_elapsed);
      });
      _emitResultIfNeeded();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _emitResultIfNeeded() {
    if (_didFinish || !widget.controller.state.isGameOver) return;
    _didFinish = true;
    widget.onFinished(widget.controller);
  }

  void _submitTap() {
    setState(() => widget.controller.submitTap());
    _emitResultIfNeeded();
  }

  void _submitLongPress() {
    setState(() => widget.controller.submitLongPress());
    _emitResultIfNeeded();
  }

  void _submitDrag() {
    setState(() => widget.controller.submitDrag());
    _emitResultIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;

    return Scaffold(
      appBar: AppBar(title: const Text('今日工位战况')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GameHud(
              remainingSeconds: state.remainingSeconds,
              survivalValue: state.survivalValue,
              score: state.score,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: EventPanel(
                  event: state.activeEvent,
                  onTapAction: _submitTap,
                  onLongPressAction: _submitLongPress,
                  onDragAction: _submitDrag,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/unit/game_session_controller_test.dart test/widget/game_screen_test.dart`
Expected: PASS with countdown and finish callback covered

- [ ] **Step 5: Commit**

```bash
git add lib/game/screens/game_screen.dart lib/game/session/game_session_controller.dart test/unit/game_session_controller_test.dart test/widget/game_screen_test.dart
git commit -m "feat: wire countdown and end-of-run flow"
```

## Task 7: Polish copy and verify the MVP end to end

**Files:**
- Modify: `lib/app/app_shell.dart`
- Modify: `lib/results/result_screen.dart`
- Modify: `test/widget/app_shell_test.dart`
- Modify: `test/widget/result_screen_test.dart`
- Create: `README.md`

- [ ] **Step 1: Write failing assertions for polished copy**

```dart
expect(find.textContaining('45 秒内活过老板巡逻'), findsOneWidget);
expect(find.textContaining('再来一局'), findsOneWidget);
```

- [ ] **Step 2: Run the full test suite**

Run: `flutter test`
Expected: FAIL until the final copy and README are aligned.

- [ ] **Step 3: Update final copy and basic project README**

`README.md`

````md
# 工位求生

一个用 Flutter 制作的移动端职场魔性小游戏原型。

## MVP 内容

- 45 秒单局求生
- 5 类职场危机事件
- 点击 / 长按 / 拖拽操作
- 本地最高分和称号结算

## 本地运行

```bash
flutter pub get
flutter run
```

## 测试

```bash
flutter test
```
````

- [ ] **Step 4: Run the full test suite again**

Run: `flutter test`
Expected: PASS with all unit and widget tests green

- [ ] **Step 5: Commit**

```bash
git add README.md lib/app/app_shell.dart lib/results/result_screen.dart test/widget/app_shell_test.dart test/widget/result_screen_test.dart
git commit -m "docs: polish copy and add project readme"
```

## Self-Review

- Spec coverage check: the plan covers app shell, five event types, 45-second loop, score/survival logic, result screen, and local high score.
- Placeholder scan: no `TODO`, `TBD`, or vague “handle later” steps remain.
- Type consistency check: the plan uses `GameSessionController`, `GameSessionState`, `GameEvent`, and `GameResult` consistently across all tasks.
