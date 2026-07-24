import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../state/game_provider.dart';
import '../../widgets/app_card.dart';

double _gaussian(Random rng) {
  final u = 1 - rng.nextDouble();
  final v = rng.nextDouble();
  return sqrt(-2 * log(u)) * cos(2 * pi * v);
}

double _variance(List<double> values) {
  final m = values.reduce((a, b) => a + b) / values.length;
  return values.map((v) => (v - m) * (v - m)).reduce((a, b) => a + b) / (values.length - 1);
}

class _Plant {
  final String id;
  final double value;
  _Plant(this.id, this.value);
}

List<_Plant> _generatePopulation(int n, double mean, double genoVarRatio, int seed) {
  final rng = Random(seed);
  final genoSd = sqrt(genoVarRatio) * 8;
  final envSd = sqrt(1 - genoVarRatio) * 8;
  return List.generate(n, (i) {
    final g = _gaussian(rng) * genoSd;
    final e = _gaussian(rng) * envSd;
    return _Plant('P${i + 1}', max(0, mean + g + e));
  });
}

class ResearchLabScreen extends StatefulWidget {
  const ResearchLabScreen({super.key});

  @override
  State<ResearchLabScreen> createState() => _ResearchLabScreenState();
}

class _ResearchLabScreenState extends State<ResearchLabScreen> {
  String? active;

  @override
  Widget build(BuildContext context) {
    if (active == 'heritability') return _HeritabilityAnalysis(onExit: () => setState(() => active = null));
    if (active == 'anova') return _AnovaAnalysis(onExit: () => setState(() => active = null));

    final analyses = [
      ('heritability', 'Heritability & Genetic Advance', true, 'Estimate H² and expected genetic advance from a simulated segregating population.'),
      ('anova', 'ANOVA (Randomized Block Design)', true, 'Partition variance across genotypes, blocks, and error in a yield trial.'),
      ('line-x-tester', 'Line × Tester Analysis', false, 'Estimate GCA and SCA effects from a line × tester mating design.'),
      ('qtl', 'QTL Mapping', false, 'Map quantitative trait loci from a biparental mapping population.'),
      ('gwas', 'Genome-Wide Association Study', false, 'Scan genome-wide markers for trait associations in a diversity panel.'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🧪 Virtual Research Lab', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Run real statistical analyses on generated breeding datasets and interpret the results.', style: TextStyle(fontSize: 13)),
          const SizedBox(height: 12),
          for (final a in analyses)
            Opacity(
              opacity: a.$3 ? 1 : 0.5,
              child: AppCard(
                child: InkWell(
                  onTap: a.$3 ? () => setState(() => active = a.$1) : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CardTitle(a.$2),
                      Text(a.$4, style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 6),
                      Pill(a.$3 ? 'Run analysis' : 'Coming soon', tone: a.$3 ? PillTone.good : PillTone.neutral),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeritabilityAnalysis extends StatefulWidget {
  final VoidCallback onExit;
  const _HeritabilityAnalysis({required this.onExit});

  @override
  State<_HeritabilityAnalysis> createState() => _HeritabilityAnalysisState();
}

class _HeritabilityAnalysisState extends State<_HeritabilityAnalysis> {
  int seed = 1;
  bool computed = false;

  @override
  Widget build(BuildContext context) {
    final parents = _generatePopulation(20, 60, 0.15, seed);
    final f2 = _generatePopulation(60, 65, 0.55, seed + 1);

    final vpParents = _variance(parents.map((p) => p.value).toList());
    final vpF2 = _variance(f2.map((p) => p.value).toList());
    final vg = max(0.0, vpF2 - vpParents);
    final h2 = min(0.99, vg / vpF2);
    const selectionIntensity = 2.06;
    final gain = h2 * selectionIntensity * sqrt(vpF2);
    final meanF2 = f2.map((p) => p.value).reduce((a, b) => a + b) / f2.length;
    final gainPct = (gain / meanF2) * 100;

    final values = f2.map((p) => p.value).toList();
    final minV = values.reduce(min);
    final maxV = values.reduce(max);
    const bins = 8;
    final width = (maxV - minV) / bins == 0 ? 1.0 : (maxV - minV) / bins;
    final counts = List.filled(bins, 0);
    for (final v in values) {
      final idx = min(bins - 1, ((v - minV) / width).floor());
      counts[idx] += 1;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Heritability & Genetic Advance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              TextButton(onPressed: widget.onExit, child: const Text('← Back to Lab')),
            ],
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle('Dataset'),
                const Text(
                  'Parent population: 20 genetically uniform plants. F2 population: 60 segregating plants. Yield in g/plant.',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 180,
                  child: BarChart(
                    BarChartData(
                      barGroups: [
                        for (var i = 0; i < counts.length; i++)
                          BarChartGroupData(x: i, barRods: [BarChartRodData(toY: counts[i].toDouble(), color: const Color(0xFF10B981), width: 16, borderRadius: BorderRadius.circular(4))]),
                      ],
                      titlesData: const FlTitlesData(
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
                      ),
                      gridData: const FlGridData(show: true, drawVerticalLine: false),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => setState(() {
                    seed += 2;
                    computed = false;
                  }),
                  icon: const Icon(Icons.refresh, size: 14),
                  label: const Text('Generate New Dataset'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle('Your Task'),
                const Text(
                  'Estimate broad-sense heritability using the variance-component method: H² = (Vp,F2 − Vp,parents) / Vp,F2, then estimate expected genetic advance under 5% selection intensity.',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() => computed = true);
                    context.read<GameProvider>().addXp(30, 'Completed a heritability & genetic advance analysis');
                    context.read<GameProvider>().unlockBadge('statistician');
                  },
                  icon: const Icon(Icons.science, size: 16),
                  label: const Text('Compute Results'),
                ),
                if (computed) ...[
                  const SizedBox(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: [
                      _stat('Vp (parents)', vpParents.toStringAsFixed(1)),
                      _stat('Vp (F2)', vpF2.toStringAsFixed(1)),
                      _stat('Vg (estimated)', vg.toStringAsFixed(1)),
                      _stat('H² (broad-sense)', '${(h2 * 100).toStringAsFixed(1)}%'),
                      _stat('Genetic advance', '${gain.toStringAsFixed(2)} g'),
                      _stat('GA (% of mean)', '${gainPct.toStringAsFixed(1)}%'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('INTERPRETATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey)),
                        Text(
                          h2 > 0.6
                              ? 'High heritability — direct phenotypic selection on this trait should be effective and genetic gain will be substantial.'
                              : h2 > 0.3
                                  ? 'Moderate heritability — combine phenotypic selection with replicated trials or markers to improve selection accuracy.'
                                  : 'Low heritability — environmental variance dominates. Consider replicated multi-location trials or marker-assisted/genomic selection.',
                          style: const TextStyle(fontSize: 12),
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

  Widget _stat(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(value, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700, fontSize: 14)),
        ],
      ),
    );
  }
}

class _AnovaAnalysis extends StatefulWidget {
  final VoidCallback onExit;
  const _AnovaAnalysis({required this.onExit});

  @override
  State<_AnovaAnalysis> createState() => _AnovaAnalysisState();
}

class _AnovaAnalysisState extends State<_AnovaAnalysis> {
  int seed = 10;

  @override
  Widget build(BuildContext context) {
    const genotypes = ['G1', 'G2', 'G3', 'G4'];
    const blocks = [1, 2, 3];
    final rng = Random(seed);
    const genoEffects = {'G1': 0.0, 'G2': 4.0, 'G3': -2.0, 'G4': 7.0};
    const blockEffects = {1: 0.0, 2: 2.0, 3: -1.0};

    final data = <String, Map<int, double>>{};
    for (final g in genotypes) {
      data[g] = {};
      for (final b in blocks) {
        final value = 30 + genoEffects[g]! + blockEffects[b]! + _gaussian(rng) * 2.5;
        data[g]![b] = (value * 10).round() / 10;
      }
    }

    final allValues = data.values.expand((m) => m.values).toList();
    final grandMean = allValues.reduce((a, b) => a + b) / allValues.length;
    final genoMeans = {for (final g in genotypes) g: data[g]!.values.reduce((a, b) => a + b) / blocks.length};
    final blockMeans = {for (final b in blocks) b: genotypes.map((g) => data[g]![b]!).reduce((a, b) => a + b) / genotypes.length};

    final ssTotal = allValues.map((v) => (v - grandMean) * (v - grandMean)).reduce((a, b) => a + b);
    final ssGeno = blocks.length * genotypes.map((g) => (genoMeans[g]! - grandMean) * (genoMeans[g]! - grandMean)).reduce((a, b) => a + b);
    final ssBlock = genotypes.length * blocks.map((b) => (blockMeans[b]! - grandMean) * (blockMeans[b]! - grandMean)).reduce((a, b) => a + b);
    final ssError = ssTotal - ssGeno - ssBlock;

    final dfGeno = genotypes.length - 1;
    final dfBlock = blocks.length - 1;
    final dfError = dfGeno * dfBlock;
    final msGeno = ssGeno / dfGeno;
    final msBlock = ssBlock / dfBlock;
    final msError = ssError / dfError;
    final fGeno = msGeno / msError;
    final fBlock = msBlock / msError;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ANOVA — Randomized Block Design', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              TextButton(onPressed: widget.onExit, child: const Text('← Back')),
            ],
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle('Trial dataset'),
                const Text('4 genotypes × 3 blocks, yield in t/ha.', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      const DataColumn(label: Text('Genotype')),
                      for (final b in blocks) DataColumn(label: Text('Block $b')),
                      const DataColumn(label: Text('Mean')),
                    ],
                    rows: [
                      for (final g in genotypes)
                        DataRow(cells: [
                          DataCell(Text(g)),
                          for (final b in blocks) DataCell(Text('${data[g]![b]}')),
                          DataCell(Text(genoMeans[g]!.toStringAsFixed(1))),
                        ]),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(onPressed: () => setState(() => seed += 3), icon: const Icon(Icons.refresh, size: 14), label: const Text('New Trial Data')),
              ],
            ),
          ),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle('ANOVA Table'),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Source')),
                      DataColumn(label: Text('df')),
                      DataColumn(label: Text('SS')),
                      DataColumn(label: Text('MS')),
                      DataColumn(label: Text('F')),
                    ],
                    rows: [
                      DataRow(cells: [const DataCell(Text('Genotype')), DataCell(Text('$dfGeno')), DataCell(Text(ssGeno.toStringAsFixed(1))), DataCell(Text(msGeno.toStringAsFixed(1))), DataCell(Text(fGeno.toStringAsFixed(2)))]),
                      DataRow(cells: [const DataCell(Text('Block')), DataCell(Text('$dfBlock')), DataCell(Text(ssBlock.toStringAsFixed(1))), DataCell(Text(msBlock.toStringAsFixed(1))), DataCell(Text(fBlock.toStringAsFixed(2)))]),
                      DataRow(cells: [const DataCell(Text('Error')), DataCell(Text('$dfError')), DataCell(Text(ssError.toStringAsFixed(1))), DataCell(Text(msError.toStringAsFixed(1))), const DataCell(Text('—'))]),
                      DataRow(cells: [const DataCell(Text('Total')), DataCell(Text('${dfGeno + dfBlock + dfError}')), DataCell(Text(ssTotal.toStringAsFixed(1))), const DataCell(Text('—')), const DataCell(Text('—'))]),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('INTERPRETATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey)),
                      Text(
                        'F(genotype) = ${fGeno.toStringAsFixed(2)} against a critical value around 4.76 (df=3,6, α=0.05) — '
                        '${fGeno > 4.76 ? "genotypes differ significantly, so selection among them is justified." : "genotype differences are not statistically significant at this replication level."}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => context.read<GameProvider>().addXp(30, 'Completed an ANOVA (RBD) analysis'),
                  icon: const Icon(Icons.science, size: 16),
                  label: const Text('Submit Interpretation'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
