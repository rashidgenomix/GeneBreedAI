import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/game_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/module_theme.dart';
import '../../widgets/app_card.dart';

final _accent = moduleTheme(ModuleId.games).color;

class _Individual {
  final bool male;
  final bool affected;
  const _Individual(this.male, this.affected);
}

class _PedigreeCase {
  final List<_Individual> parents;
  final List<_Individual> children;
  final String correctPattern;
  final List<String> distractors;
  final String explanation;
  const _PedigreeCase({required this.parents, required this.children, required this.correctPattern, required this.distractors, required this.explanation});
}

const _cases = [
  _PedigreeCase(
    parents: [_Individual(true, false), _Individual(false, false)],
    children: [_Individual(true, true), _Individual(false, false), _Individual(true, false), _Individual(false, true)],
    correctPattern: 'Autosomal recessive',
    distractors: ['Autosomal dominant', 'X-linked recessive', 'X-linked dominant'],
    explanation: 'Both parents are unaffected yet have affected children of both sexes — the trait must be recessive (masked as carriers) and autosomal (not sex-linked, since both sons and daughters are affected).',
  ),
  _PedigreeCase(
    parents: [_Individual(false, true), _Individual(true, false)],
    children: [_Individual(true, true), _Individual(false, false), _Individual(true, true), _Individual(false, true)],
    correctPattern: 'Autosomal dominant',
    distractors: ['Autosomal recessive', 'X-linked recessive', 'X-linked dominant'],
    explanation: 'An affected parent passes the trait to roughly half of children of both sexes every generation — the hallmark of a dominant autosomal trait (no masking by carriers).',
  ),
  _PedigreeCase(
    parents: [_Individual(false, false), _Individual(true, false)],
    children: [_Individual(true, true), _Individual(false, false), _Individual(true, true), _Individual(false, false)],
    correctPattern: 'X-linked recessive',
    distractors: ['Autosomal recessive', 'Autosomal dominant', 'X-linked dominant'],
    explanation: 'Only sons are affected while daughters are unaffected carriers — classic X-linked recessive inheritance, since sons have only one X (inherited from their unaffected-carrier mother) and no second copy to mask it.',
  ),
];

/// A visual-pedigree-tree game: inspect a rendered family pedigree (squares = male,
/// circles = female, filled = affected) and deduce the underlying inheritance pattern.
class PedigreePuzzleGame extends StatefulWidget {
  final VoidCallback onExit;
  const PedigreePuzzleGame({super.key, required this.onExit});

  @override
  State<PedigreePuzzleGame> createState() => _PedigreePuzzleGameState();
}

class _PedigreePuzzleGameState extends State<PedigreePuzzleGame> {
  int caseIndex = 0;
  String? answer;

  Widget _shape(_Individual ind, {double size = 40}) {
    final color = ind.affected ? _accent : Colors.transparent;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: ind.male ? BoxShape.rectangle : BoxShape.circle,
        border: Border.all(color: _accent, width: 2.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = _cases[caseIndex % _cases.length];
    final options = [c.correctPattern, ...c.distractors];
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Pedigree Puzzle', style: AppText.sectionTitle)),
              TextButton(onPressed: widget.onExit, child: const Text('← Back to Games')),
            ],
          ),
          Text('Inspect the family pedigree (□ = male, ○ = female, filled = affected) and deduce the inheritance pattern.', style: AppText.body),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            accentColor: _accent,
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _shape(c.parents[0]),
                  Container(width: 20, height: 2, color: _accent),
                  _shape(c.parents[1]),
                ]),
                Center(child: Container(width: 2, height: 14, color: _accent)),
                Container(height: 2, color: _accent),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (final child in c.children)
                      Column(children: [Container(width: 2, height: 10, color: _accent), _shape(child, size: 34)]),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('What inheritance pattern best explains this pedigree?', style: AppText.statLabel),
          const SizedBox(height: 6),
          for (final opt in options)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Card(
                color: answer != null ? (opt == c.correctPattern ? AppColors.good.withValues(alpha: 0.12) : (opt == answer ? AppColors.bad.withValues(alpha: 0.12) : null)) : null,
                child: ListTile(
                  title: Text(opt, style: const TextStyle(fontSize: 13)),
                  onTap: answer == null
                      ? () {
                          setState(() => answer = opt);
                          if (opt == c.correctPattern) {
                            context.read<GameProvider>().addXp(20, 'Solved a pedigree puzzle');
                          }
                        }
                      : null,
                ),
              ),
            ),
          if (answer != null) ...[
            AppCard(child: Text(c.explanation, style: AppText.body)),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () => setState(() {
                caseIndex += 1;
                answer = null;
              }),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Next Pedigree'),
            ),
          ],
        ],
      ),
    );
  }
}
