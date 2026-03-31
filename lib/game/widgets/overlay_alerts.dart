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
    if (!visible) {
      return const SizedBox.shrink();
    }

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
            Text(
              warningText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
