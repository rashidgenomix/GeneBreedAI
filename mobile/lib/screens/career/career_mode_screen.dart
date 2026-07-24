import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/gamification.dart';
import '../../data/missions.dart';
import '../../state/game_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/icon_map.dart';

class CareerModeScreen extends StatelessWidget {
  const CareerModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final level = game.levelInfo.level;
    final rank = game.rank;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🏆 Career Mode', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Progress from Student to Chief Plant Breeder by earning XP, badges, publications, and grants.', style: TextStyle(fontSize: 13)),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle('Career Ladder'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final r in careerRanks)
                      Container(
                        width: 140,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: rank.id == r.id ? const Color(0x2210B981) : (level >= r.minLevel ? const Color(0x1010B981) : Colors.black.withValues(alpha: 0.04)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: rank.id == r.id ? const Color(0xFF059669) : Colors.black12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            Text('Level ${r.minLevel}+', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 2.6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: [
                    _stat(Icons.emoji_events, 'Level', '$level'),
                    _stat(Icons.military_tech, 'Total XP', '${game.totalXp}'),
                    _stat(Icons.menu_book, 'Publications', '${game.publications}'),
                    _stat(Icons.account_balance, 'Grants', '${game.grants}'),
                  ],
                ),
                const SizedBox(height: 10),
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
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle('Missions'),
                for (final m in missions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: game.completedMissionIds.contains(m.id) ? const Color(0x1210B981) : Colors.black.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Text(m.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                  const SizedBox(width: 6),
                                  Pill(m.type, tone: m.type == 'weekly' ? PillTone.info : PillTone.neutral),
                                ]),
                                Text(m.description, style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle('Badges (${game.unlockedBadgeIds.length}/${badges.length})'),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: badges.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 0.85),
                  itemBuilder: (context, i) {
                    final b = badges[i];
                    final unlocked = game.unlockedBadgeIds.contains(b.id);
                    return Opacity(
                      opacity: unlocked ? 1 : 0.4,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: unlocked ? const Color(0x1210B981) : Colors.black.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: unlocked ? const Color(0xFF059669) : Colors.black12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(iconForName(b.icon), color: unlocked ? const Color(0xFF059669) : Colors.grey, size: 22),
                            const SizedBox(height: 4),
                            Text(b.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF059669)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              Text(value, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}
