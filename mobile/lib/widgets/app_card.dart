import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(padding: padding, child: child),
    );
  }
}

class CardTitle extends StatelessWidget {
  final String text;
  const CardTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
    );
  }
}

enum PillTone { neutral, good, warn, bad, info }

class Pill extends StatelessWidget {
  final String text;
  final PillTone tone;
  const Pill(this.text, {super.key, this.tone = PillTone.neutral});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = <PillTone, Color>{
      PillTone.neutral: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
      PillTone.good: const Color(0xFF10B981).withValues(alpha: 0.15),
      PillTone.warn: const Color(0xFFF59E0B).withValues(alpha: 0.15),
      PillTone.bad: const Color(0xFFF43F5E).withValues(alpha: 0.15),
      PillTone.info: const Color(0xFF0EA5E9).withValues(alpha: 0.15),
    };
    final textColors = <PillTone, Color>{
      PillTone.neutral: isDark ? Colors.white70 : Colors.black87,
      PillTone.good: const Color(0xFF059669),
      PillTone.warn: const Color(0xFFB45309),
      PillTone.bad: const Color(0xFFE11D48),
      PillTone.info: const Color(0xFF0284C7),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: colors[tone], borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColors[tone])),
    );
  }
}
