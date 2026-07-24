import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/crops.dart';
import '../../data/genes.dart';
import '../../state/game_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/module_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/detail_sheet.dart';

final _accent = moduleTheme(ModuleId.geneLab).color;

class GeneLabScreen extends StatefulWidget {
  const GeneLabScreen({super.key});

  @override
  State<GeneLabScreen> createState() => _GeneLabScreenState();
}

class _GeneLabScreenState extends State<GeneLabScreen> {
  String cropId = crops.first.id;
  GeneCard? selectedGene;
  EditType? editType;
  GeneEditOutcome? result;

  void _runEdit() {
    if (selectedGene == null || editType == null) return;
    final outcome = selectedGene!.editOutcomes.firstWhere((o) => o.edit == editType);
    setState(() => result = outcome);
    final game = context.read<GameProvider>();
    game.addXp(20, 'Ran a ${editLabels[editType]} experiment on ${selectedGene!.symbol}');
    game.unlockBadge('gene-hunter');
  }

  void _showGeneDetails(GeneCard g) {
    showDetailSheet(
      context,
      title: g.symbol,
      subtitle: g.name,
      icon: Icons.biotech,
      accentColor: _accent,
      children: [
        DetailSection(label: 'Function', text: g.function),
        DetailSection(label: 'Pathway', text: g.pathway),
        DetailSection(label: 'Protein family', text: g.proteinFamily),
        DetailSection(label: 'Wild-type phenotype', text: g.normalPhenotype),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final genes = getGenesByCrop(cropId);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: [
              for (final c in crops)
                ChoiceChip(
                  label: Text('${c.emoji} ${c.name}'),
                  selected: cropId == c.id,
                  selectedColor: _accent.withValues(alpha: 0.2),
                  onSelected: (_) => setState(() {
                    cropId = c.id;
                    selectedGene = null;
                    result = null;
                  }),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Chromosome map', style: AppText.sectionTitle),
          const SizedBox(height: AppSpacing.sm),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: genes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.05),
            itemBuilder: (context, i) {
              final g = genes[i];
              return EntityCard(
                icon: Icons.biotech,
                accentColor: _accent,
                title: g.symbol,
                description: 'Chr ${g.chromosome} · ${g.position}',
                status: null,
                dimmed: false,
                onTap: () => setState(() {
                  selectedGene = g;
                  editType = null;
                  result = null;
                }),
                onViewDetails: () => _showGeneDetails(g),
              );
            },
          ),
          if (selectedGene != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppCard(
              accentColor: _accent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: CardTitle('${selectedGene!.symbol} — ${selectedGene!.name}')),
                      Pill('Chr ${selectedGene!.chromosome}', tone: PillTone.info),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text('EXPRESSION PROFILE', style: AppText.statLabel),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final e in selectedGene!.expression)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: _accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text('${e.tissue}: ${(e.level * 100).round()}%', style: const TextStyle(fontSize: 11)),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('GENE EDITING SIMULATOR', style: AppText.statLabel),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final et in EditType.values)
                        ChoiceChip(
                          label: Text(editLabels[et]!, style: const TextStyle(fontSize: 11)),
                          selected: editType == et,
                          selectedColor: _accent.withValues(alpha: 0.2),
                          onSelected: (_) => setState(() {
                            editType = et;
                            result = null;
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton.icon(
                    onPressed: editType != null ? _runEdit : null,
                    icon: const Icon(Icons.science, size: 16),
                    label: const Text('Run Experiment'),
                  ),
                  if (result != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    AppCard(
                      accentColor: _accent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text(selectedGene!.symbol, style: TextStyle(fontWeight: FontWeight.w700, color: _accent)),
                            const Icon(Icons.arrow_forward, size: 14),
                            Expanded(child: Text(editLabels[result!.edit]!, style: TextStyle(fontWeight: FontWeight.w700, color: _accent))),
                          ]),
                          const SizedBox(height: 6),
                          Text('Observed phenotype: ${result!.phenotype}', style: AppText.body),
                          const SizedBox(height: 4),
                          Text('Mechanism: ${result!.mechanism}', style: AppText.caption),
                          const SizedBox(height: 6),
                          Pill('Yield impact: ${result!.yieldImpact > 0 ? "+" : ""}${result!.yieldImpact}%', tone: result!.yieldImpact >= 0 ? PillTone.good : PillTone.bad),
                          const SizedBox(height: 8),
                          Text(
                            "Reflect: what does this outcome tell you about ${selectedGene!.symbol}'s normal function?",
                            style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
