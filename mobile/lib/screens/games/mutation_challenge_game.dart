import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/game_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/module_theme.dart';
import '../../widgets/app_card.dart';

final _accent = moduleTheme(ModuleId.games).color;

class _MutationCase {
  final String wildType;
  final String mutant;
  final String type;
  final String explanation;
  const _MutationCase({required this.wildType, required this.mutant, required this.type, required this.explanation});
}

const _cases = [
  _MutationCase(wildType: 'ATGCGTACG', mutant: 'ATGCATACG', type: 'Substitution', explanation: 'One base (G→A) is swapped for another at the same position — the sequence length is unchanged.'),
  _MutationCase(wildType: 'ATGCGTACG', mutant: 'ATGCGGTACG', type: 'Insertion', explanation: 'An extra base (G) has been added, making the mutant one base longer than the wild type.'),
  _MutationCase(wildType: 'ATGCGTACG', mutant: 'ATGCTACG', type: 'Deletion', explanation: 'A base (G) is missing, making the mutant one base shorter than the wild type.'),
  _MutationCase(wildType: 'ATGCGTACG', mutant: 'ATGCGTACGACG', type: 'Duplication', explanation: 'A segment ("ACG") is repeated, appearing twice in the mutant.'),
  _MutationCase(wildType: 'ATGCGTACG', mutant: 'ATGTGCACG', type: 'Inversion', explanation: 'A segment ("CGT") has been reversed in place ("TGC") within the sequence.'),
];

const _types = ['Substitution', 'Insertion', 'Deletion', 'Duplication', 'Inversion'];

/// A tap-to-explore diagram game: compare a wild-type and mutant DNA sequence tile-by-tile,
/// then classify which type of mutation produced the difference.
class MutationChallengeGame extends StatefulWidget {
  final VoidCallback onExit;
  const MutationChallengeGame({super.key, required this.onExit});

  @override
  State<MutationChallengeGame> createState() => _MutationChallengeGameState();
}

class _MutationChallengeGameState extends State<MutationChallengeGame> {
  int caseIndex = 0;
  final Set<int> highlightedWild = {};
  final Set<int> highlightedMutant = {};
  String? selectedType;
  bool? correct;

  static const _baseColors = {'A': Color(0xFF16A34A), 'T': Color(0xFFDC2626), 'C': Color(0xFF2563EB), 'G': Color(0xFFCA8A04)};

  void _check() {
    final c = _cases[caseIndex % _cases.length];
    setState(() => correct = selectedType == c.type);
    if (correct == true) {
      context.read<GameProvider>().addXp(15, 'Identified a ${c.type.toLowerCase()} mutation');
    }
  }

  void _next() {
    setState(() {
      caseIndex += 1;
      highlightedWild.clear();
      highlightedMutant.clear();
      selectedType = null;
      correct = null;
    });
  }

  Widget _sequenceRow(String seq, Set<int> highlighted, void Function(int) onTapTile) {
    return Wrap(
      spacing: 3,
      children: [
        for (var i = 0; i < seq.length; i++)
          GestureDetector(
            onTap: () => onTapTile(i),
            child: Container(
              width: 26,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: highlighted.contains(i) ? Colors.amber.withValues(alpha: 0.4) : (_baseColors[seq[i]] ?? Colors.grey).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(4),
                border: highlighted.contains(i) ? Border.all(color: Colors.amber.shade800, width: 2) : null,
              ),
              child: Text(seq[i], style: TextStyle(fontWeight: FontWeight.w800, fontFamily: 'monospace', color: _baseColors[seq[i]])),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = _cases[caseIndex % _cases.length];
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Mutation Challenge', style: AppText.sectionTitle)),
              TextButton(onPressed: widget.onExit, child: const Text('← Back to Games')),
            ],
          ),
          Text('Tap bases to compare the two sequences, then classify the mutation type.', style: AppText.body),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            accentColor: _accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('WILD TYPE', style: AppText.statLabel),
                const SizedBox(height: 4),
                _sequenceRow(c.wildType, highlightedWild, (i) => setState(() => highlightedWild.contains(i) ? highlightedWild.remove(i) : highlightedWild.add(i))),
                const SizedBox(height: AppSpacing.sm),
                Text('MUTANT', style: AppText.statLabel),
                const SizedBox(height: 4),
                _sequenceRow(c.mutant, highlightedMutant, (i) => setState(() => highlightedMutant.contains(i) ? highlightedMutant.remove(i) : highlightedMutant.add(i))),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('What kind of mutation is this?', style: AppText.statLabel),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in _types)
                ChoiceChip(
                  label: Text(t),
                  selected: selectedType == t,
                  selectedColor: _accent.withValues(alpha: 0.25),
                  onSelected: (_) => setState(() => selectedType = t),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(spacing: 8, children: [
            ElevatedButton.icon(onPressed: selectedType != null ? _check : null, icon: const Icon(Icons.check, size: 16), label: const Text('Check Answer')),
            OutlinedButton.icon(onPressed: _next, icon: const Icon(Icons.arrow_forward, size: 16), label: const Text('Next Case')),
          ]),
          if (correct != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(correct! ? Icons.check_circle : Icons.cancel, color: correct! ? AppColors.good : AppColors.bad),
                    const SizedBox(width: 8),
                    Expanded(child: Text(correct! ? 'Correct — ${c.type.toLowerCase()}.' : 'Not quite — this was a ${c.type.toLowerCase()}.', style: const TextStyle(fontWeight: FontWeight.w700))),
                  ]),
                  const SizedBox(height: 6),
                  Text(c.explanation, style: AppText.body),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
