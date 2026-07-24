import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/game_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/module_theme.dart';
import '../../widgets/app_card.dart';

final _accent = moduleTheme(ModuleId.games).color;
const _markerNames = ['A', 'B', 'C', 'D'];

/// A drag-and-drop game: drop gene-marker chips onto ordered chromosome slots based on
/// pairwise recombination-frequency clues — markers separated by a smaller recombination
/// frequency belong closer together on the linkage map.
class ChromosomeAssemblyGame extends StatefulWidget {
  final VoidCallback onExit;
  const ChromosomeAssemblyGame({super.key, required this.onExit});

  @override
  State<ChromosomeAssemblyGame> createState() => _ChromosomeAssemblyGameState();
}

class _ChromosomeAssemblyGameState extends State<ChromosomeAssemblyGame> {
  int seed = 1;
  late List<int> positions; // "true" cM position of markers A..D (index-aligned)
  late List<String?> slots; // marker name placed in each of the 4 ordered slots
  late List<String> pool; // markers not yet placed
  bool? correct;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _generate() {
    final rng = Random(seed);
    final raw = [0, 5 + rng.nextInt(15), 20 + rng.nextInt(15), 38 + rng.nextInt(15)];
    positions = raw;
    slots = List.filled(4, null);
    pool = List.of(_markerNames)..shuffle(rng);
    correct = null;
  }

  List<String> get _correctOrder {
    final indexed = List.generate(4, (i) => i)..sort((a, b) => positions[a].compareTo(positions[b]));
    return [for (final i in indexed) _markerNames[i]];
  }

  int _distance(String a, String b) => (positions[_markerNames.indexOf(a)] - positions[_markerNames.indexOf(b)]).abs();

  void _check() {
    setState(() => correct = slots.whereType<String>().toList().join() == _correctOrder.join());
    if (correct == true) {
      context.read<GameProvider>().addXp(20, 'Ordered a chromosome linkage map correctly');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pairs = <(String, String, int)>[];
    for (var i = 0; i < _markerNames.length; i++) {
      for (var j = i + 1; j < _markerNames.length; j++) {
        pairs.add((_markerNames[i], _markerNames[j], _distance(_markerNames[i], _markerNames[j])));
      }
    }
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Chromosome Assembly', style: AppText.sectionTitle)),
              TextButton(onPressed: widget.onExit, child: const Text('← Back to Games')),
            ],
          ),
          Text('Drag each marker onto the linkage map in the order implied by the recombination-frequency clues below.', style: AppText.body),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            accentColor: _accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle('Recombination frequency clues'),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [for (final p in pairs) Chip(label: Text('${p.$1}–${p.$2}: ${p.$3} cM', style: const TextStyle(fontSize: 11)))],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Unplaced markers', style: AppText.statLabel),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              for (final m in pool)
                Draggable<String>(
                  data: m,
                  feedback: _markerChip(m, dragging: true),
                  childWhenDragging: Opacity(opacity: 0.3, child: _markerChip(m)),
                  child: _markerChip(m),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Linkage map (left → right)', style: AppText.statLabel),
          const SizedBox(height: 6),
          Row(
            children: [
              for (var i = 0; i < 4; i++) ...[
                Expanded(
                  child: DragTarget<String>(
                    onWillAcceptWithDetails: (_) => slots[i] == null,
                    onAcceptWithDetails: (details) => setState(() {
                      pool.remove(details.data);
                      slots[i] = details.data;
                      correct = null;
                    }),
                    builder: (context, candidate, rejected) {
                      return GestureDetector(
                        onTap: slots[i] != null
                            ? () => setState(() {
                                  pool.add(slots[i]!);
                                  slots[i] = null;
                                  correct = null;
                                })
                            : null,
                        child: Container(
                          height: 64,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: slots[i] != null ? _accent.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(color: candidate.isNotEmpty ? _accent : Colors.black26, width: candidate.isNotEmpty ? 2 : 1),
                          ),
                          alignment: Alignment.center,
                          child: slots[i] != null
                              ? Text(slots[i]!, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: _accent))
                              : Text('${i + 1}', style: const TextStyle(color: Colors.grey)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(spacing: 8, children: [
            ElevatedButton.icon(onPressed: slots.every((s) => s != null) ? _check : null, icon: const Icon(Icons.check, size: 16), label: const Text('Check Order')),
            OutlinedButton.icon(onPressed: () => setState(() { seed += 1; _generate(); }), icon: const Icon(Icons.refresh, size: 16), label: const Text('New Map')),
          ]),
          if (correct != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              child: Row(
                children: [
                  Icon(correct! ? Icons.check_circle : Icons.cancel, color: correct! ? AppColors.good : AppColors.bad),
                  const SizedBox(width: 8),
                  Expanded(child: Text(correct! ? 'Correct order!' : 'Not quite — the smallest recombination frequency marks the closest neighbors.', style: AppText.body)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _markerChip(String m, {bool dragging = false}) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _accent,
          shape: BoxShape.circle,
          boxShadow: dragging ? [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8)] : null,
        ),
        alignment: Alignment.center,
        child: Text(m, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
      ),
    );
  }
}
