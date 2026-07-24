import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Generic progress state used by cards and stage nodes throughout the app —
/// locked (not yet unlocked), available (unlocked, not started), inProgress,
/// completed. Screens map their own domain state onto this before rendering.
enum StatusState { locked, available, inProgress, completed }

extension StatusStateStyle on StatusState {
  Color get color => switch (this) {
        StatusState.locked => AppColors.locked,
        StatusState.available => AppColors.info,
        StatusState.inProgress => AppColors.warn,
        StatusState.completed => AppColors.good,
      };

  IconData get icon => switch (this) {
        StatusState.locked => Icons.lock,
        StatusState.available => Icons.play_circle_outline,
        StatusState.inProgress => Icons.hourglass_top,
        StatusState.completed => Icons.check_circle,
      };

  String get label => switch (this) {
        StatusState.locked => 'Locked',
        StatusState.available => 'Start',
        StatusState.inProgress => 'In progress',
        StatusState.completed => 'Completed',
      };
}

/// Small colored dot + icon badge conveying a [StatusState] at a glance.
class StatusBadge extends StatelessWidget {
  final StatusState status;
  final bool compact;
  const StatusBadge({super.key, required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(color: status.color.withValues(alpha: 0.15), shape: BoxShape.circle),
        child: Icon(status.icon, size: 13, color: status.color),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: status.color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 12, color: status.color),
          const SizedBox(width: 4),
          Text(status.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: status.color)),
        ],
      ),
    );
  }
}
