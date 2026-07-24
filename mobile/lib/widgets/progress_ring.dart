import 'package:flutter/material.dart';

/// A circular progress indicator with a value/label stacked in its center —
/// used for XP-to-next-level, stat rings on the dashboard, and stage completion.
class ProgressRing extends StatelessWidget {
  final double value; // 0-1
  final Color color;
  final double size;
  final double strokeWidth;
  final Widget? center;

  const ProgressRing({
    super.key,
    required this.value,
    required this.color,
    this.size = 56,
    this.strokeWidth = 6,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: strokeWidth,
              color: color.withValues(alpha: 0.15),
            ),
          ),
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: value.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              color: color,
              strokeCap: StrokeCap.round,
            ),
          ),
          ?center,
        ],
      ),
    );
  }
}
