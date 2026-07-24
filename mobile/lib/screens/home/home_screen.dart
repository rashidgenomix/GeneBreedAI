import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/gamification.dart';
import '../../state/game_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/module_theme.dart';
import '../../widgets/module_tile.dart';
import '../../widgets/stat_chip.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final level = game.levelInfo.level;
    final rank = game.rank;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Reflow the grid rather than clipping/shrinking on larger screens (Goal 5).
        final crossAxisCount = constraints.maxWidth >= 700 ? 4 : (constraints.maxWidth >= 480 ? 3 : 2);

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg + MediaQuery.of(context).padding.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('${rank.title} · Level $level', style: AppText.pageTitle, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  StatChip(icon: Icons.bolt, value: '${game.totalXp}', tag: 'XP', color: AppColors.amber500),
                  StatChip(icon: Icons.local_fire_department, value: '${game.dailyStreak}', tag: 'Streak', color: AppColors.bad),
                  StatChip(icon: Icons.workspace_premium, value: '${game.unlockedBadgeIds.length}/${badges.length}', tag: 'Badges', color: AppColors.info),
                  StatChip(icon: Icons.military_tech, value: '${game.publications + game.grants}', tag: 'Awards', color: moduleTheme(ModuleId.career).color),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Modules', style: AppText.sectionTitle),
              const SizedBox(height: AppSpacing.sm),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: moduleThemes.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.05,
                ),
                itemBuilder: (context, i) {
                  final m = moduleThemes.values.elementAt(i);
                  return ModuleTile(module: m, onTap: () => context.go(m.route));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
