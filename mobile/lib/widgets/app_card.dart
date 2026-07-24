import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'status_state.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? accentColor;
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.accentColor});

  @override
  Widget build(BuildContext context) {
    final card = Card(
      margin: EdgeInsets.zero,
      shape: accentColor != null
          ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg), side: BorderSide(color: accentColor!.withValues(alpha: 0.25)))
          : null,
      child: Padding(padding: padding, child: child),
    );
    return card;
  }
}

class CardTitle extends StatelessWidget {
  final String text;
  const CardTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: AppText.sectionTitle),
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
      PillTone.good: AppColors.good.withValues(alpha: 0.15),
      PillTone.warn: AppColors.warn.withValues(alpha: 0.15),
      PillTone.bad: AppColors.bad.withValues(alpha: 0.15),
      PillTone.info: AppColors.info.withValues(alpha: 0.15),
    };
    final textColors = <PillTone, Color>{
      PillTone.neutral: isDark ? Colors.white70 : Colors.black87,
      PillTone.good: AppColors.good,
      PillTone.warn: AppColors.warn,
      PillTone.bad: AppColors.bad,
      PillTone.info: AppColors.info,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: colors[tone], borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColors[tone])),
    );
  }
}

/// The core browsing-card widget (Goal 1): an icon in an accent-tinted roundel, a title, one
/// line of description, a status indicator, and an optional "View Details" tap target that
/// opens a [showDetailSheet] with the fuller content. Used for modules, crops, genes, missions,
/// question topics/stages, games, and analyses so every list in the app shares one visual language.
class EntityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final Color accentColor;
  final StatusState? status;
  final double? progress;
  final String? progressLabel;
  final VoidCallback? onTap;
  final VoidCallback? onViewDetails;
  final bool dimmed;
  final Widget? trailing;

  const EntityCard({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    required this.accentColor,
    this.status,
    this.progress,
    this.progressLabel,
    this.onTap,
    this.onViewDetails,
    this.dimmed = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final content = Opacity(
      opacity: dimmed ? 0.55 : 1,
      child: AppCard(
        accentColor: accentColor,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppRadius.sm)),
                  child: Icon(icon, color: accentColor, size: 20),
                ),
                const Spacer(),
                if (trailing != null) trailing!
                else if (progress != null)
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: Stack(alignment: Alignment.center, children: [
                      CircularProgressIndicator(value: progress, strokeWidth: 3, color: accentColor, backgroundColor: accentColor.withValues(alpha: 0.15)),
                      if (progressLabel != null) Text(progressLabel!, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800)),
                    ]),
                  )
                else if (status != null)
                  StatusBadge(status: status!, compact: true),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(title, style: AppText.cardTitle, maxLines: 2, overflow: TextOverflow.ellipsis),
            if (description != null) ...[
              const SizedBox(height: 2),
              Text(description!, style: AppText.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
            if (onViewDetails != null) ...[
              const SizedBox(height: AppSpacing.sm),
              InkWell(
                onTap: onViewDetails,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'View details',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: accentColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 14, color: accentColor),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (onTap == null) return content;
    return InkWell(borderRadius: BorderRadius.circular(AppRadius.lg), onTap: onTap, child: content);
  }
}
