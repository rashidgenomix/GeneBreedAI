import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/game_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/module_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/stage_node.dart';
import '../../widgets/status_state.dart';

final _accent = moduleTheme(ModuleId.games).color;

/// A "boss level" chaining three quick puzzles into one timed escape: a tap-reveal Punnett
/// square, a trait-matching pick, and a final breeding-method decision — themed as escaping
/// the lab's breeding program before the season ends. Attempts are limited by a shared
/// "seasons remaining" counter so mistakes carry real (if replayable) stakes.
class BreedingEscapeRoomGame extends StatefulWidget {
  final VoidCallback onExit;
  const BreedingEscapeRoomGame({super.key, required this.onExit});

  @override
  State<BreedingEscapeRoomGame> createState() => _BreedingEscapeRoomGameState();
}

class _BreedingEscapeRoomGameState extends State<BreedingEscapeRoomGame> {
  int room = 0;
  int seasonsLeft = 3;
  bool escaped = false;
  bool failed = false;

  final Set<int> revealedCells = {};
  String? punnettAnswer;
  String? traitAnswer;
  String? methodAnswer;

  static const _punnettGenotypes = ['AA', 'Aa', 'Aa', 'aa'];

  void _wrongMove() {
    setState(() {
      seasonsLeft -= 1;
      if (seasonsLeft <= 0) failed = true;
    });
  }

  void _advanceRoom() {
    setState(() {
      if (room >= 2) {
        escaped = true;
        context.read<GameProvider>().addXp(50, 'Escaped the breeding lab');
        context.read<GameProvider>().unlockBadge('game-champion');
      } else {
        room += 1;
      }
    });
  }

  void _restart() {
    setState(() {
      room = 0;
      seasonsLeft = 3;
      escaped = false;
      failed = false;
      revealedCells.clear();
      punnettAnswer = null;
      traitAnswer = null;
      methodAnswer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Breeding Escape Room', style: AppText.sectionTitle)),
              TextButton(onPressed: widget.onExit, child: const Text('← Back to Games')),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                StageNode(
                  label: ['Punnett', 'Trait Match', 'Final Call'][i],
                  accentColor: _accent,
                  size: 40,
                  status: i < room ? StatusState.completed : (i == room ? StatusState.inProgress : StatusState.locked),
                ),
                if (i < 2) StageConnector(completed: i < room, accentColor: _accent, width: 24),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(children: [
            for (var i = 0; i < 3; i++) Icon(i < seasonsLeft ? Icons.eco : Icons.eco_outlined, color: i < seasonsLeft ? _accent : Colors.grey, size: 20),
            const SizedBox(width: 6),
            Text('seasons remaining', style: AppText.caption),
          ]),
          const SizedBox(height: AppSpacing.md),
          if (failed) _resultCard(false),
          if (escaped) _resultCard(true),
          if (!failed && !escaped) ...[
            if (room == 0) _punnettRoom(),
            if (room == 1) _traitRoom(),
            if (room == 2) _finalRoom(),
          ],
        ],
      ),
    );
  }

  Widget _resultCard(bool won) {
    return AppCard(
      accentColor: won ? AppColors.good : AppColors.bad,
      child: Column(
        children: [
          Icon(won ? Icons.emoji_events : Icons.sentiment_dissatisfied, size: 40, color: won ? AppColors.good : AppColors.bad),
          const SizedBox(height: 8),
          Text(won ? '🎉 Escaped! The line is ready before season end.' : 'Out of seasons — the breeding program stalled.', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ElevatedButton.icon(onPressed: _restart, icon: const Icon(Icons.refresh, size: 16), label: const Text('Try Again')),
        ],
      ),
    );
  }

  Widget _punnettRoom() {
    final allRevealed = revealedCells.length == 4;
    return AppCard(
      accentColor: _accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardTitle('Room 1 — Reveal the Punnett Square'),
          Text('Cross Aa × Aa. Tap each cell to reveal its genotype.', style: AppText.body),
          const SizedBox(height: AppSpacing.sm),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.6,
            children: [
              for (var i = 0; i < 4; i++)
                InkWell(
                  onTap: () => setState(() => revealedCells.add(i)),
                  child: Container(
                    decoration: BoxDecoration(color: _accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppRadius.sm), border: Border.all(color: _accent.withValues(alpha: 0.4))),
                    alignment: Alignment.center,
                    child: Text(revealedCells.contains(i) ? _punnettGenotypes[i] : '?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: _accent)),
                  ),
                ),
            ],
          ),
          if (allRevealed) ...[
            const SizedBox(height: AppSpacing.md),
            Text('What phenotypic ratio results (dominant : recessive)?', style: AppText.statLabel),
            const SizedBox(height: 6),
            Wrap(spacing: 8, children: [
              for (final opt in ['3:1', '1:1', '1:2:1'])
                ChoiceChip(label: Text(opt), selected: punnettAnswer == opt, selectedColor: _accent.withValues(alpha: 0.25), onSelected: (_) => setState(() => punnettAnswer = opt)),
            ]),
            const SizedBox(height: AppSpacing.sm),
            ElevatedButton(
              onPressed: punnettAnswer == null
                  ? null
                  : () {
                      if (punnettAnswer == '3:1') {
                        _advanceRoom();
                      } else {
                        _wrongMove();
                      }
                    },
              child: const Text('Submit'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _traitRoom() {
    const options = [
      ('Drought-tolerant deep-rooted line', true),
      ('Tall, late-maturing landrace', false),
      ('Disease-susceptible high-yield line', false),
    ];
    return AppCard(
      accentColor: _accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardTitle('Room 2 — Match the Trait'),
          Text('Your target: a parent suited for a dryland breeding program with terminal drought stress. Pick the best-matching line.', style: AppText.body),
          const SizedBox(height: AppSpacing.sm),
          for (final opt in options)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Card(
                color: traitAnswer != null ? (opt.$2 ? AppColors.good.withValues(alpha: 0.12) : (opt.$1 == traitAnswer ? AppColors.bad.withValues(alpha: 0.12) : null)) : null,
                child: ListTile(
                  title: Text(opt.$1, style: const TextStyle(fontSize: 13)),
                  onTap: traitAnswer == null
                      ? () {
                          setState(() => traitAnswer = opt.$1);
                          if (opt.$2) {
                            _advanceRoom();
                          } else {
                            _wrongMove();
                          }
                        }
                      : null,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _finalRoom() {
    const options = [
      ('Doubled Haploid Technology', true),
      ('Recurrent Selection', false),
      ('Bulk Breeding', false),
    ];
    return AppCard(
      accentColor: _accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardTitle('Room 3 — Final Call'),
          Text('The season ends in weeks, not years. Which method reaches a homozygous, releasable line fastest?', style: AppText.body),
          const SizedBox(height: AppSpacing.sm),
          for (final opt in options)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Card(
                color: methodAnswer != null ? (opt.$2 ? AppColors.good.withValues(alpha: 0.12) : (opt.$1 == methodAnswer ? AppColors.bad.withValues(alpha: 0.12) : null)) : null,
                child: ListTile(
                  title: Text(opt.$1, style: const TextStyle(fontSize: 13)),
                  onTap: methodAnswer == null
                      ? () {
                          setState(() => methodAnswer = opt.$1);
                          if (opt.$2) {
                            _advanceRoom();
                          } else {
                            _wrongMove();
                          }
                        }
                      : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
