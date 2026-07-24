import 'package:flutter/material.dart';
import '../models/types.dart';
import '../engine/genetics.dart';

class TraitBarWidget extends StatelessWidget {
  final Trait trait;
  final double value;
  final double? compareValue;

  const TraitBarWidget({super.key, required this.trait, required this.value, this.compareValue});

  @override
  Widget build(BuildContext context) {
    final pct = value.clamp(0.0, 1.0);
    bool? better;
    if (compareValue != null) {
      better = trait.direction == TraitDirection.lowerBetter ? value < compareValue! : value > compareValue!;
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color valueColor = isDark ? Colors.white70 : Colors.black54;
    if (better == true) valueColor = const Color(0xFF059669);
    if (better == false && compareValue != null && compareValue != value) valueColor = const Color(0xFFF43F5E);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(trait.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
              Text(displayTraitValue(trait, value), style: TextStyle(fontSize: 12, fontFamily: 'monospace', color: valueColor)),
            ],
          ),
          const SizedBox(height: 3),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 7,
                  backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF10B981)),
                ),
              ),
              if (compareValue != null)
                Positioned(
                  left: compareValue!.clamp(0.0, 1.0) * (MediaQuery.of(context).size.width - 64),
                  child: Container(width: 2, height: 7, color: const Color(0xFFF43F5E)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
