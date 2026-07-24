import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/detective_cases.dart';
import '../../state/game_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/icon_map.dart';

class GeneDetectiveScreen extends StatefulWidget {
  const GeneDetectiveScreen({super.key});

  @override
  State<GeneDetectiveScreen> createState() => _GeneDetectiveScreenState();
}

class _GeneDetectiveScreenState extends State<GeneDetectiveScreen> {
  DetectiveCase? activeCase;
  final Set<String> revealedClues = {};
  String? answer;
  bool? correct;
  List<String> options = [];

  void _openCase(DetectiveCase c) {
    final opts = [c.correctHypothesis, ...c.distractors];
    opts.shuffle();
    setState(() {
      activeCase = c;
      revealedClues.clear();
      answer = null;
      correct = null;
      options = opts;
    });
  }

  void _submit(String choice) {
    if (activeCase == null || answer != null) return;
    final isCorrect = choice == activeCase!.correctHypothesis;
    setState(() {
      answer = choice;
      correct = isCorrect;
    });
    final game = context.read<GameProvider>();
    if (isCorrect) {
      game.addXp(35, 'Solved case "${activeCase!.title}"');
      game.unlockBadge('detective');
    } else {
      game.addXp(5, 'Attempted case "${activeCase!.title}"');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (activeCase == null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🔍 AI Gene Detective', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('A mystery mutant has appeared. Gather clues with real investigative tools, then propose and defend a hypothesis.', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            for (final c in detectiveCases)
              AppCard(
                child: InkWell(
                  onTap: () => _openCase(c),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CardTitle(c.title),
                      for (final s in c.symptoms) Text('• $s', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    }

    final c = activeCase!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(c.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
              TextButton(onPressed: () => setState(() => activeCase = null), child: const Text('← Case Files')),
            ],
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle('Observed Symptoms'),
                for (final s in c.symptoms) Text('• $s', style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text('INVESTIGATION TOOLS — tap to run a test', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey)),
          const SizedBox(height: 6),
          for (final clue in c.clues)
            AppCard(
              child: InkWell(
                onTap: () => setState(() => revealedClues.add(clue.tool)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(iconForName(clue.icon), size: 18, color: const Color(0xFF059669)),
                      const SizedBox(width: 8),
                      Text(clue.tool, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ]),
                    if (revealedClues.contains(clue.tool)) Padding(padding: const EdgeInsets.only(top: 6), child: Text(clue.text, style: const TextStyle(fontSize: 12))),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle('Propose Your Hypothesis'),
                const Text('Which explanation is best supported by all the evidence you gathered?', style: TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 8),
                for (final opt in options)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Card(
                      color: answer != null
                          ? (opt == c.correctHypothesis ? const Color(0x2210B981) : (opt == answer ? const Color(0x22F43F5E) : null))
                          : null,
                      child: ListTile(
                        onTap: answer == null ? () => _submit(opt) : null,
                        title: Text(opt, style: const TextStyle(fontSize: 13)),
                      ),
                    ),
                  ),
                if (correct != null)
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(correct! ? Icons.check_circle : Icons.cancel, color: correct! ? const Color(0xFF059669) : const Color(0xFFF43F5E), size: 18),
                          const SizedBox(width: 6),
                          Text(correct! ? 'Well reasoned!' : 'Not quite — re-examine the evidence.', style: const TextStyle(fontWeight: FontWeight.w700)),
                        ]),
                        const SizedBox(height: 6),
                        Text(c.explanation, style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 6),
                        Pill('Culprit: ${c.culpritGene}', tone: PillTone.info),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
