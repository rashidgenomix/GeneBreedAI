import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Opens a consistent, module-tinted bottom sheet for the fuller text content that browsing
/// cards deliberately omit (Goal 1) — descriptions, advantages/limitations, pathway details,
/// explanations, etc. Scrolls internally so long content never overflows.
Future<void> showDetailSheet(
  BuildContext context, {
  required String title,
  required Color accentColor,
  IconData? icon,
  String? subtitle,
  required List<Widget> children,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.62,
        minChildSize: 0.35,
        maxChildSize: 0.94,
        expand: false,
        builder: (context, scrollController) {
          final theme = Theme.of(context);
          final bg = theme.brightness == Brightness.dark ? AppColors.darkSurface : Colors.white;
          return Container(
            decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg))),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4))),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
                  child: Row(
                    children: [
                      if (icon != null)
                        Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.only(right: AppSpacing.md),
                          decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppRadius.sm)),
                          child: Icon(icon, color: accentColor),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: AppText.sectionTitle),
                            if (subtitle != null) Text(subtitle, style: AppText.caption),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                    ],
                  ),
                ),
                const Divider(height: AppSpacing.lg),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl),
                    children: children,
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

/// A labeled block of body text for use inside a detail sheet.
class DetailSection extends StatelessWidget {
  final String label;
  final String text;
  const DetailSection({super.key, required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppText.statLabel),
          const SizedBox(height: 4),
          Text(text, style: AppText.body),
        ],
      ),
    );
  }
}

/// A labeled bullet list for use inside a detail sheet (advantages/limitations, clues, etc.).
class DetailBulletList extends StatelessWidget {
  final String label;
  final List<String> items;
  final Color? bulletColor;
  const DetailBulletList({super.key, required this.label, required this.items, this.bulletColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppText.statLabel.copyWith(color: bulletColor)),
          const SizedBox(height: 4),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.circle, size: 5, color: bulletColor ?? Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item, style: AppText.body)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
