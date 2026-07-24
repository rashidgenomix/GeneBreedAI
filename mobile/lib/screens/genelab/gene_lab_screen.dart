import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/crops.dart';
import '../../data/genes.dart';
import '../../state/game_provider.dart';
import '../../widgets/app_card.dart';

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

  @override
  Widget build(BuildContext context) {
    final genes = getGenesByCrop(cropId);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🧬 Gene Function Discovery Lab', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text("Investigate genes by editing them and observing phenotype outcomes — don't memorize function, discover it.", style: TextStyle(fontSize: 13)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              for (final c in crops)
                ChoiceChip(
                  label: Text('${c.emoji} ${c.name}'),
                  selected: cropId == c.id,
                  onSelected: (_) => setState(() {
                    cropId = c.id;
                    selectedGene = null;
                    result = null;
                  }),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('CHROMOSOME MAP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey)),
          const SizedBox(height: 6),
          for (final g in genes)
            Card(
              margin: const EdgeInsets.only(bottom: 6),
              color: selectedGene?.id == g.id ? const Color(0x2210B981) : null,
              child: ListTile(
                leading: const Icon(Icons.biotech, color: Color(0xFF059669)),
                title: Text(g.symbol, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700)),
                subtitle: Text('Chr ${g.chromosome} · ${g.position}'),
                onTap: () => setState(() {
                  selectedGene = g;
                  editType = null;
                  result = null;
                }),
              ),
            ),
          if (selectedGene != null) ...[
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: CardTitle('${selectedGene!.symbol} — ${selectedGene!.name}')),
                      Pill('Chr ${selectedGene!.chromosome}', tone: PillTone.info),
                    ],
                  ),
                  Text(selectedGene!.proteinFamily, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(selectedGene!.function, style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 6),
                  Text('Pathway: ${selectedGene!.pathway}', style: const TextStyle(fontSize: 11)),
                  const SizedBox(height: 8),
                  const Text('EXPRESSION PROFILE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey)),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final e in selectedGene!.expression)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
                          child: Text('${e.tissue}: ${(e.level * 100).round()}%', style: const TextStyle(fontSize: 11)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('WILD-TYPE PHENOTYPE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey)),
                        Text(selectedGene!.normalPhenotype, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('GENE EDITING SIMULATOR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final et in EditType.values)
                        ChoiceChip(
                          label: Text(editLabels[et]!, style: const TextStyle(fontSize: 11)),
                          selected: editType == et,
                          onSelected: (_) => setState(() {
                            editType = et;
                            result = null;
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: editType != null ? _runEdit : null,
                    icon: const Icon(Icons.science, size: 16),
                    label: const Text('Run Experiment'),
                  ),
                  if (result != null) ...[
                    const SizedBox(height: 10),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text(selectedGene!.symbol, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF059669))),
                            const Icon(Icons.arrow_forward, size: 14),
                            Text(editLabels[result!.edit]!, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF059669))),
                          ]),
                          const SizedBox(height: 6),
                          Text('Observed phenotype: ${result!.phenotype}', style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 4),
                          Text('Mechanism: ${result!.mechanism}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 6),
                          Pill('Yield impact: ${result!.yieldImpact > 0 ? "+" : ""}${result!.yieldImpact}%', tone: result!.yieldImpact >= 0 ? PillTone.good : PillTone.bad),
                          const SizedBox(height: 8),
                          Text(
                            "Reflect: what does this outcome tell you about ${selectedGene!.symbol}'s normal function? Could another gene in the same pathway produce a similar phenotype?",
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
