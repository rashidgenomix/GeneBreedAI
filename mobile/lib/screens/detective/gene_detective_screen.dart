import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/crops.dart';
import '../../data/detective_cases.dart';
import '../../state/game_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/module_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/detail_sheet.dart';
import '../../widgets/icon_map.dart';

final _accent = moduleTheme(ModuleId.detective).color;

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

  void _showCaseSymptoms(DetectiveCase c) {
    showDetailSheet(
      context,
      title: c.title,
      subtitle: crops.firstWhere((cr) => cr.id == c.cropId, orElse: () => crops.first).name,
      icon: Icons.search,
      accentColor: _accent,
      children: [
        DetailBulletList(label: 'Observed symptoms', items: c.symptoms, bulletColor: _accent),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    if (activeCase == null) {
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg + bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('A mystery mutant has appeared in each case below. Gather clues, then defend a hypothesis.', style: AppText.body),
            const SizedBox(height: AppSpacing.md),
            for (final c in detectiveCases)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: EntityCard(
                  icon: Icons.search,
                  accentColor: _accent,
                  title: c.title,
                  description: '${c.symptoms.length} symptoms · ${c.clues.length} clues to gather',
                  onTap: () => _openCase(c),
                  onViewDetails: () => _showCaseSymptoms(c),
                ),
              ),
          ],
        ),
      );
    }

    final c = activeCase!;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(c.title, style: AppText.sectionTitle)),
              TextButton(onPressed: () => setState(() => activeCase = null), child: const Text('← Case Files')),
            ],
          ),
          AppCard(
            accentColor: _accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle('Observed Symptoms'),
                for (final s in c.symptoms) Text('• $s', style: AppText.body),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('INVESTIGATION TOOLS — tap to run a test', style: AppText.statLabel),
          const SizedBox(height: AppSpacing.sm),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: c.clues.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.4),
            itemBuilder: (context, i) {
              final clue = c.clues[i];
              final revealed = revealedClues.contains(clue.tool);
              return AppCard(
                accentColor: revealed ? _accent : null,
                padding: const EdgeInsets.all(10),
                child: InkWell(
                  onTap: () => setState(() => revealedClues.add(clue.tool)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(iconForName(clue.icon), size: 16, color: revealed ? _accent : Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(child: Text(clue.tool, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                      ]),
                      if (revealed)
                        Padding(padding: const EdgeInsets.only(top: 6), child: Text(clue.text, style: const TextStyle(fontSize: 11)))
                      else
                        Padding(padding: const EdgeInsets.only(top: 6), child: Text('Tap to run test', style: AppText.caption)),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            accentColor: _accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle('Propose Your Hypothesis'),
                Text('Which explanation is best supported by all the evidence you gathered?', style: AppText.caption),
                const SizedBox(height: AppSpacing.sm),
                for (final opt in options)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Card(
                      color: answer != null ? (opt == c.correctHypothesis ? AppColors.good.withValues(alpha: 0.12) : (opt == answer ? AppColors.bad.withValues(alpha: 0.12) : null)) : null,
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
                          Icon(correct! ? Icons.check_circle : Icons.cancel, color: correct! ? AppColors.good : AppColors.bad, size: 18),
                          const SizedBox(width: 6),
                          Expanded(child: Text(correct! ? 'Well reasoned!' : 'Not quite — re-examine the evidence.', style: const TextStyle(fontWeight: FontWeight.w700))),
                        ]),
                        const SizedBox(height: 6),
                        Text(c.explanation, style: AppText.body),
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
