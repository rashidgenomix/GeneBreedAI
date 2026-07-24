import 'package:flutter/material.dart';
import 'status_state.dart';

/// A single node in a stage-map progression (Viva topic → stage). Rendered in a row/column
/// by the parent with connecting lines between nodes; the node itself just shows its own
/// locked/available/inProgress/completed state as a colored circle with an icon overlay.
class StageNode extends StatelessWidget {
  final String label;
  final StatusState status;
  final Color accentColor;
  final VoidCallback? onTap;
  final double size;

  const StageNode({
    super.key,
    required this.label,
    required this.status,
    required this.accentColor,
    this.onTap,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = status == StatusState.locked;
    final ringColor = isLocked ? Colors.grey : accentColor;

    return InkWell(
      onTap: isLocked ? null : onTap,
      borderRadius: BorderRadius.circular(999),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: status == StatusState.completed ? ringColor : ringColor.withValues(alpha: 0.12),
              border: Border.all(color: ringColor, width: 2.5),
            ),
            child: Icon(
              isLocked
                  ? Icons.lock
                  : status == StatusState.completed
                      ? Icons.check
                      : Icons.play_arrow,
              color: status == StatusState.completed ? Colors.white : ringColor,
              size: size * 0.4,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: size + 16,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isLocked ? Colors.grey : null),
            ),
          ),
        ],
      ),
    );
  }
}

/// A horizontal connector line drawn between two [StageNode]s in a stage map row.
class StageConnector extends StatelessWidget {
  final bool completed;
  final Color accentColor;
  const StageConnector({super.key, required this.completed, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.only(bottom: 22),
        color: completed ? accentColor : Colors.grey.withValues(alpha: 0.3),
      ),
    );
  }
}
