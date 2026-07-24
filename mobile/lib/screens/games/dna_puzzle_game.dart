import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/game_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/module_theme.dart';
import '../../widgets/app_card.dart';

final _accent = moduleTheme(ModuleId.games).color;

class _DnaPuzzle {
  final List<String> fragments; // in scrambled display order handled by caller
  final List<int> correctOrder; // indices into fragments giving the correct assembly order
  final String assembled;
  const _DnaPuzzle({required this.fragments, required this.correctOrder, required this.assembled});
}

const _puzzles = [
  _DnaPuzzle(fragments: ['CGGATC', 'ATCGTA', 'GTACGG', 'TACGGA'], correctOrder: [1, 3, 2, 0], assembled: 'ATCGTACGGATC'),
  _DnaPuzzle(fragments: ['TTGACC', 'GACCTA', 'AATTGA', 'CCTAGG'], correctOrder: [2, 0, 1, 3], assembled: 'AATTGACCTAGG'),
];

/// A drag-and-drop reordering game: reconstruct a full DNA sequence from scrambled,
/// overlapping sequencing "reads" by dragging fragments into the correct order.
class DnaPuzzleGame extends StatefulWidget {
  final VoidCallback onExit;
  const DnaPuzzleGame({super.key, required this.onExit});

  @override
  State<DnaPuzzleGame> createState() => _DnaPuzzleGameState();
}

class _DnaPuzzleGameState extends State<DnaPuzzleGame> {
  int puzzleIndex = 0;
  late List<int> order; // current displayed order, values are fragment indices
  bool? correct;

  @override
  void initState() {
    super.initState();
    _newPuzzle();
  }

  void _newPuzzle() {
    final puzzle = _puzzles[puzzleIndex % _puzzles.length];
    order = List.generate(puzzle.fragments.length, (i) => i)..shuffle();
    correct = null;
  }

  void _check() {
    final puzzle = _puzzles[puzzleIndex % _puzzles.length];
    setState(() => correct = order.toString() == puzzle.correctOrder.toString());
    if (correct == true) {
      context.read<GameProvider>().addXp(15, 'Solved a DNA assembly puzzle');
    }
  }

  @override
  Widget build(BuildContext context) {
    final puzzle = _puzzles[puzzleIndex % _puzzles.length];
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('DNA Puzzle', style: AppText.sectionTitle)),
              TextButton(onPressed: widget.onExit, child: const Text('← Back to Games')),
            ],
          ),
          Text('Drag the sequencing reads into the order that reconstructs the full sequence (each read overlaps the next).', style: AppText.body),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            accentColor: _accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle('Sequencing reads (drag to reorder)'),
                ReorderableListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  onReorderItem: (oldIndex, newIndex) {
                    setState(() {
                      final item = order.removeAt(oldIndex);
                      order.insert(newIndex, item);
                      correct = null;
                    });
                  },
                  children: [
                    for (final idx in order)
                      Container(
                        key: ValueKey(idx),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(color: _accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppRadius.sm), border: Border.all(color: _accent.withValues(alpha: 0.3))),
                        child: Row(
                          children: [
                            Icon(Icons.drag_handle, color: _accent, size: 18),
                            const SizedBox(width: 10),
                            Text(puzzle.fragments[idx], style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700, fontSize: 15)),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(spacing: 8, children: [
                  ElevatedButton.icon(onPressed: _check, icon: const Icon(Icons.check, size: 16), label: const Text('Check Assembly')),
                  OutlinedButton.icon(
                    onPressed: () => setState(() {
                      puzzleIndex += 1;
                      _newPuzzle();
                    }),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('New Puzzle'),
                  ),
                ]),
                if (correct != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  AppCard(
                    child: Row(
                      children: [
                        Icon(correct! ? Icons.check_circle : Icons.cancel, color: correct! ? AppColors.good : AppColors.bad),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            correct! ? 'Correct! Assembled: ${puzzle.assembled}' : 'Not quite — check where each read overlaps the next and try again.',
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
