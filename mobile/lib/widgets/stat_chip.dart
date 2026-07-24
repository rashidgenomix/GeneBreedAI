import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A compact icon+value stat used in the dashboard's "at a glance" strip and other summary
/// rows — deliberately has no sentence-length label, just an icon, a number, and a 1-word tag.
class StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String tag;
  final Color color;

  const StatChip({super.key, required this.icon, required this.value, required this.tag, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: AppText.statValue.copyWith(fontSize: 14, color: color)),
              Text(tag, style: AppText.statLabel),
            ],
          ),
        ],
      ),
    );
  }
}
