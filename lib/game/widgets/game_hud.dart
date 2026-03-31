import 'package:flutter/material.dart';

class GameHud extends StatelessWidget {
  static const Color _dangerColor = Color(0xFFD92D20);
  static const Color _warningColor = Color(0xFFF79009);

  const GameHud({
    super.key,
    required this.remainingSeconds,
    required this.survivalValue,
    required this.score,
    this.isDangerMode = false,
  });

  final int remainingSeconds;
  final int survivalValue;
  final int score;
  final bool isDangerMode;

  @override
  Widget build(BuildContext context) {
    final progressColor = isDangerMode || survivalValue < 40
        ? _dangerColor
        : survivalValue < 60
            ? _warningColor
            : null;
    final statusLabel = isDangerMode
        ? '老板贴脸中'
        : survivalValue < 40
            ? '工位快炸了'
            : '还能顶住';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '剩余 $remainingSeconds 秒',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (progressColor ?? const Color(0xFF667085)).withValues(
                  alpha: 0.14,
                ),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  color: progressColor ?? const Color(0xFF475467),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: survivalValue / 100,
          color: progressColor,
          backgroundColor: const Color(0xFFF2F4F7),
          minHeight: 10,
          borderRadius: BorderRadius.circular(999),
        ),
        const SizedBox(height: 8),
        Text(
          '分数 $score',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
