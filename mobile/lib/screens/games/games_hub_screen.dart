import 'package:flutter/material.dart';

import '../../widgets/app_card.dart';
import 'trait_prediction_game.dart';
import 'gene_matching_game.dart';

class _GameInfo {
  final String id;
  final String name;
  final IconData icon;
  final bool ready;
  final String description;
  const _GameInfo(this.id, this.name, this.icon, this.ready, this.description);
}

const List<_GameInfo> _games = [
  _GameInfo('trait-prediction', 'Trait Prediction', Icons.shuffle, true, 'Predict Punnett-square offspring ratios from parent genotypes.'),
  _GameInfo('gene-matching', 'Gene Matching', Icons.extension, true, 'Match gene symbols to their biological function.'),
  _GameInfo('dna-puzzle', 'DNA Puzzle', Icons.biotech, false, 'Assemble a DNA sequence from overlapping reads.'),
  _GameInfo('chromosome-assembly', 'Chromosome Assembly', Icons.account_tree, false, 'Order gene markers along a chromosome by recombination distance.'),
  _GameInfo('mutation-challenge', 'Mutation Challenge', Icons.dangerous, false, 'Identify which mutation type produced a given phenotype.'),
  _GameInfo('escape-room', 'Breeding Escape Room', Icons.meeting_room, false, 'Solve a chain of breeding puzzles to escape the lab before the season ends.'),
  _GameInfo('pedigree-puzzle', 'Pedigree Puzzle', Icons.account_tree, false, 'Deduce inheritance patterns from a family pedigree chart.'),
  _GameInfo('genome-mapping', 'Genome Mapping', Icons.map, false, 'Place genes on a chromosome map using linkage data.'),
];

class GamesHubScreen extends StatefulWidget {
  const GamesHubScreen({super.key});

  @override
  State<GamesHubScreen> createState() => _GamesHubScreenState();
}

class _GamesHubScreenState extends State<GamesHubScreen> {
  String? active;

  @override
  Widget build(BuildContext context) {
    if (active == 'trait-prediction') return TraitPredictionGame(onExit: () => setState(() => active = null));
    if (active == 'gene-matching') return GeneMatchingGame(onExit: () => setState(() => active = null));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🎮 Genetics Games', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Sharpen your genetics intuition through fast, replayable challenges.', style: TextStyle(fontSize: 13)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _games.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.9),
            itemBuilder: (context, i) {
              final g = _games[i];
              return Opacity(
                opacity: g.ready ? 1 : 0.5,
                child: AppCard(
                  child: InkWell(
                    onTap: g.ready ? () => setState(() => active = g.id) : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(g.icon, color: const Color(0xFF059669), size: 24),
                        const SizedBox(height: 6),
                        Text(g.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        const SizedBox(height: 4),
                        Expanded(child: Text(g.description, style: const TextStyle(fontSize: 11), overflow: TextOverflow.fade)),
                        Pill(g.ready ? 'Play now' : 'Coming soon', tone: g.ready ? PillTone.good : PillTone.neutral),
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
}
