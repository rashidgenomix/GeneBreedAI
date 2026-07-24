import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/module_theme.dart';
import '../../widgets/app_card.dart';
import 'trait_prediction_game.dart';
import 'gene_matching_game.dart';
import 'dna_puzzle_game.dart';
import 'chromosome_assembly_game.dart';
import 'mutation_challenge_game.dart';
import 'pedigree_puzzle_game.dart';
import 'genome_mapping_game.dart';
import 'breeding_escape_room_game.dart';

final _accent = moduleTheme(ModuleId.games).color;

class _GameInfo {
  final String id;
  final String name;
  final IconData icon;
  final String description;
  const _GameInfo(this.id, this.name, this.icon, this.description);
}

const List<_GameInfo> _games = [
  _GameInfo('trait-prediction', 'Trait Prediction', Icons.shuffle, 'Predict Punnett-square offspring ratios from parent genotypes.'),
  _GameInfo('gene-matching', 'Gene Matching', Icons.extension, 'Match gene symbols to their biological function.'),
  _GameInfo('dna-puzzle', 'DNA Puzzle', Icons.biotech, 'Drag sequencing reads into order to assemble a DNA sequence.'),
  _GameInfo('chromosome-assembly', 'Chromosome Assembly', Icons.account_tree, 'Drag markers onto a linkage map by recombination distance.'),
  _GameInfo('mutation-challenge', 'Mutation Challenge', Icons.dangerous, 'Tap to compare sequences and classify the mutation type.'),
  _GameInfo('escape-room', 'Breeding Escape Room', Icons.meeting_room, 'Chain three puzzles to escape the lab before the season ends.'),
  _GameInfo('pedigree-puzzle', 'Pedigree Puzzle', Icons.diversity_1, 'Read a visual family tree to deduce the inheritance pattern.'),
  _GameInfo('genome-mapping', 'Genome Mapping', Icons.map, 'Slide genes into position on a chromosome ruler by linkage distance.'),
];

class GamesHubScreen extends StatefulWidget {
  const GamesHubScreen({super.key});

  @override
  State<GamesHubScreen> createState() => _GamesHubScreenState();
}

class _GamesHubScreenState extends State<GamesHubScreen> {
  String? active;

  void _exit() => setState(() => active = null);

  @override
  Widget build(BuildContext context) {
    switch (active) {
      case 'trait-prediction':
        return TraitPredictionGame(onExit: _exit);
      case 'gene-matching':
        return GeneMatchingGame(onExit: _exit);
      case 'dna-puzzle':
        return DnaPuzzleGame(onExit: _exit);
      case 'chromosome-assembly':
        return ChromosomeAssemblyGame(onExit: _exit);
      case 'mutation-challenge':
        return MutationChallengeGame(onExit: _exit);
      case 'pedigree-puzzle':
        return PedigreePuzzleGame(onExit: _exit);
      case 'genome-mapping':
        return GenomeMappingGame(onExit: _exit);
      case 'escape-room':
        return BreedingEscapeRoomGame(onExit: _exit);
    }

    final bottomInset = MediaQuery.of(context).padding.bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sharpen your genetics intuition through fast, replayable, hands-on challenges.', style: AppText.body),
          const SizedBox(height: AppSpacing.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _games.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.95),
            itemBuilder: (context, i) {
              final g = _games[i];
              return EntityCard(
                icon: g.icon,
                accentColor: _accent,
                title: g.name,
                description: g.description,
                onTap: () => setState(() => active = g.id),
              );
            },
          ),
        ],
      ),
    );
  }
}
