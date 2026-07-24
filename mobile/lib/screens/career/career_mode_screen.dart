import 'package:flutter/material.dart' hide Badge;
import 'package:provider/provider.dart';

import '../../data/gamification.dart';
import '../../data/missions.dart';
import '../../state/game_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/module_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/detail_sheet.dart';
import '../../widgets/icon_map.dart';
import '../../widgets/stage_node.dart';
import '../../widgets/status_state.dart';

final _accent = moduleTheme(ModuleId.career).color;

class CareerModeScreen extends StatelessWidget {
  const CareerModeScreen({super.key});

  void _showBadgeDetails(BuildContext context, Badge b, bool unlocked) {
    showDetailSheet(
      context,
      title: b.name,
      subtitle: unlocked ? 'Unlocked' : 'Locked',
      icon: iconForName(b.icon),
      accentColor: _accent,
      children: [DetailSection(label: 'How to earn it', text: b.description)],
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final level = game.levelInfo.level;
    final rank = game.rank;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Progress from Student to Chief Plant Breeder by earning XP, badges, publications, and grants.', style: AppText.body),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            accentColor: _accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle('Career Ladder'),
                SizedBox(
                  height: 90,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (var i = 0; i < careerRanks.length; i++) ...[
                        StageNode(
                          label: careerRanks[i].title,
                          accentColor: _accent,
                          size: 52,
                          status: rank.id == careerRanks[i].id
                              ? StatusState.inProgress
                              : (level >= careerRanks[i].minLevel ? StatusState.completed : StatusState.locked),
                        ),
                        if (i < careerRanks.length - 1) StageConnector(completed: level >= careerRanks[i + 1].minLevel, accentColor: _accent),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 2.6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: [
                    _statTile(Icons.emoji_events, 'Level', '$level'),
                    _statTile(Icons.military_tech, 'Total XP', '${game.totalXp}'),
                    _statTile(Icons.menu_book, 'Publications', '${game.publications}'),
                    _statTile(Icons.account_balance, 'Grants', '${game.grants}'),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      game.addPublication();
                      game.addXp(40, 'Published a research finding');
                    },
                    icon: const Icon(Icons.menu_book, size: 16),
                    label: const Text('Submit Publication (+40 XP)'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      game.addGrant();
                      game.addXp(30, 'Awarded a research grant');
                    },
                    icon: const Icon(Icons.account_balance, size: 16),
                    label: const Text('Apply for Grant (+30 XP)'),
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Missions', style: AppText.sectionTitle),
          const SizedBox(height: AppSpacing.sm),
          for (final m in missions)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                accentColor: game.completedMissionIds.contains(m.id) ? _accent : null,
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    StatusBadge(status: game.completedMissionIds.contains(m.id) ? StatusState.completed : StatusState.available, compact: true),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(child: Text(m.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                            const SizedBox(width: 6),
                            Pill(m.type, tone: m.type == 'weekly' ? PillTone.info : PillTone.neutral),
                          ]),
                          Text(m.description, style: AppText.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: game.completedMissionIds.contains(m.id) ? null : () => game.completeMission(m.id),
                      child: Text(game.completedMissionIds.contains(m.id) ? 'Done' : '+${m.xp} XP'),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Text('Badges (${game.unlockedBadgeIds.length}/${badges.length})', style: AppText.sectionTitle),
          const SizedBox(height: AppSpacing.sm),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: badges.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 0.85),
            itemBuilder: (context, i) {
              final b = badges[i];
              final unlocked = game.unlockedBadgeIds.contains(b.id);
              return Opacity(
                opacity: unlocked ? 1 : 0.45,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  onTap: () => _showBadgeDetails(context, b, unlocked),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: unlocked ? _accent.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: unlocked ? _accent : Colors.black12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(iconForName(b.icon), color: unlocked ? _accent : Colors.grey, size: 22),
                        const SizedBox(height: 4),
                        Text(b.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _statTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: _accent.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.sm)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _accent),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppText.statLabel),
              Text(value, style: AppText.statValue),
            ],
          ),
        ],
      ),
    );
  }
}
