import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/module_theme.dart';

/// A large, icon-first, tappable dashboard tile for one module — no body copy, just an icon,
/// a short label, and the module's accent color, per the "icon-driven dashboard" requirement.
/// A faded oversized icon sits behind the foreground icon as a subtle decorative pattern.
class ModuleTile extends StatelessWidget {
  final ModuleTheme module;
  final VoidCallback onTap;
  const ModuleTile({super.key, required this.module, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [module.color, Color.lerp(module.color, Colors.black, 0.25)!],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -14,
                bottom: -14,
                child: Icon(module.icon, size: 84, color: Colors.white.withValues(alpha: 0.14)),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.22), borderRadius: BorderRadius.circular(AppRadius.sm)),
                      child: Icon(module.icon, color: Colors.white, size: 20),
                    ),
                    Text(
                      module.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13, height: 1.15),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
