import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../state/game_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/module_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/detail_sheet.dart';

final _accent = moduleTheme(ModuleId.researchLab).color;

double _gaussian(Random rng) {
  final u = 1 - rng.nextDouble();
  final v = rng.nextDouble();
  return sqrt(-2 * log(u)) * cos(2 * pi * v);
}

double _variance(List<double> values) {
  final m = values.reduce((a, b) => a + b) / values.length;
  return values.map((v) => (v - m) * (v - m)).reduce((a, b) => a + b) / (values.length - 1);
}

/// Standard normal CDF via the Abramowitz-Stegun approximation, used to turn a z/t-like
/// statistic into an approximate p-value for the GWAS analysis (a deliberate simplification —
/// this app models teachable statistics, not a production-grade association pipeline).
double _normalCdf(double z) {
  final t = 1 / (1 + 0.2316419 * z.abs());
  final poly = t * (0.319381530 + t * (-0.356563782 + t * (1.781477937 + t * (-1.821255978 + t * 1.330274429))));
  final phi = 1 - (1 / sqrt(2 * pi)) * exp(-z * z / 2) * poly;
  return z >= 0 ? phi : 1 - phi;
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

const _analyses = [
  ('heritability', 'Heritability & Genetic Advance', Icons.query_stats, 'Estimate H² and expected genetic advance from a segregating population.'),
  ('anova', 'ANOVA (Randomized Block Design)', Icons.table_chart, 'Partition variance across genotypes, blocks, and error in a yield trial.'),
  ('line-x-tester', 'Line × Tester Analysis', Icons.hub, 'Estimate GCA and SCA effects from a line × tester mating design.'),
  ('qtl', 'QTL Mapping', Icons.timeline, 'Map quantitative trait loci from a biparental mapping population.'),
  ('gwas', 'Genome-Wide Association Study', Icons.scatter_plot, 'Scan genome-wide markers for trait associations in a diversity panel.'),
];

class ResearchLabScreen extends StatefulWidget {
  const ResearchLabScreen({super.key});

  @override
  State<ResearchLabScreen> createState() => _ResearchLabScreenState();
}

class _ResearchLabScreenState extends State<ResearchLabScreen> {
  String? active;

  void _showAnalysisDetails(String id, String title, String desc) {
    const methodology = {
      'heritability': 'Compares trait variance in a genetically uniform parent population against a segregating F2 population to isolate the genetic variance component, then estimates response to selection.',
      'anova': 'A randomized block design partitions total variance into genotype, block, and residual error sources, testing whether genotype means differ more than chance via an F-test.',
      'line-x-tester': 'Crosses a set of lines to a set of testers; combining-ability analysis decomposes each cross mean into general (parent-level, GCA) and specific (cross-level, SCA) combining ability effects.',
      'qtl': 'Genotypes a biparental mapping population (e.g. recombinant inbred lines) at markers spaced along a chromosome, then tests each marker for association with the trait to localize a QTL.',
      'gwas': 'Genotypes a diversity panel at genome-wide markers and tests each one for statistical association with the trait, visualized as a Manhattan-style plot of -log10(p) by position.',
    };
    showDetailSheet(
      context,
      title: title,
      subtitle: 'Methodology',
      icon: _analyses.firstWhere((a) => a.$1 == id).$3,
      accentColor: _accent,
      children: [
        DetailSection(label: 'What this analysis does', text: desc),
        DetailSection(label: 'How it works', text: methodology[id]!),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (active == 'heritability') return _HeritabilityAnalysis(onExit: () => setState(() => active = null));
    if (active == 'anova') return _AnovaAnalysis(onExit: () => setState(() => active = null));
    if (active == 'line-x-tester') return _LineXTesterAnalysis(onExit: () => setState(() => active = null));
    if (active == 'qtl') return _QtlAnalysis(onExit: () => setState(() => active = null));
    if (active == 'gwas') return _GwasAnalysis(onExit: () => setState(() => active = null));

    final bottomInset = MediaQuery.of(context).padding.bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Run real statistical analyses on generated breeding datasets and interpret the results.', style: AppText.body),
          const SizedBox(height: AppSpacing.md),
          for (final a in _analyses)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: EntityCard(
                icon: a.$3,
                accentColor: _accent,
                title: a.$2,
                description: a.$4,
                onTap: () => setState(() => active = a.$1),
                onViewDetails: () => _showAnalysisDetails(a.$1, a.$2, a.$4),
              ),
            ),
        ],
      ),
    );
  }
}

Widget _statTile(String label, String value) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: _accent.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.sm)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: AppText.statLabel),
        Text(value, style: AppText.statValue.copyWith(color: _accent)),
      ],
    ),
  );
}

Widget _analysisHeader(String title, VoidCallback onExit) {
  return Row(
    children: [
      Expanded(child: Text(title, style: AppText.sectionTitle)),
      TextButton(onPressed: onExit, child: const Text('← Back to Lab')),
    ],
  );
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

    final bottomInset = MediaQuery.of(context).padding.bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _analysisHeader('Heritability & Genetic Advance', widget.onExit),
          AppCard(
            accentColor: _accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle('Dataset'),
                Text('Parent population: 20 uniform plants. F2 population: 60 segregating plants. Yield in g/plant.', style: AppText.caption),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 180,
                  child: BarChart(
                    BarChartData(
                      barGroups: [
                        for (var i = 0; i < counts.length; i++)
                          BarChartGroupData(x: i, barRods: [BarChartRodData(toY: counts[i].toDouble(), color: _accent, width: 16, borderRadius: BorderRadius.circular(4))]),
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
                const SizedBox(height: AppSpacing.sm),
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
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle('Your Task'),
                Text('Estimate broad-sense heritability (H²) from variance components, then estimate genetic advance under 5% selection intensity.', style: AppText.caption),
                const SizedBox(height: AppSpacing.sm),
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
                  const SizedBox(height: AppSpacing.sm),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: [
                      _statTile('Vp (parents)', vpParents.toStringAsFixed(1)),
                      _statTile('Vp (F2)', vpF2.toStringAsFixed(1)),
                      _statTile('Vg (estimated)', vg.toStringAsFixed(1)),
                      _statTile('H² (broad-sense)', '${(h2 * 100).toStringAsFixed(1)}%'),
                      _statTile('Genetic advance', '${gain.toStringAsFixed(2)} g'),
                      _statTile('GA (% of mean)', '${gainPct.toStringAsFixed(1)}%'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('INTERPRETATION', style: AppText.statLabel),
                        Text(
                          h2 > 0.6
                              ? 'High heritability — direct phenotypic selection should be effective and genetic gain will be substantial.'
                              : h2 > 0.3
                                  ? 'Moderate heritability — combine phenotypic selection with replicated trials or markers.'
                                  : 'Low heritability — environmental variance dominates; consider marker-assisted/genomic selection.',
                          style: AppText.body,
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

    final bottomInset = MediaQuery.of(context).padding.bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _analysisHeader('ANOVA — Randomized Block Design', widget.onExit),
          AppCard(
            accentColor: _accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle('Trial dataset'),
                Text('4 genotypes × 3 blocks, yield in t/ha.', style: AppText.caption),
                const SizedBox(height: AppSpacing.sm),
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
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(onPressed: () => setState(() => seed += 3), icon: const Icon(Icons.refresh, size: 14), label: const Text('New Trial Data')),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
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
                const SizedBox(height: AppSpacing.sm),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('INTERPRETATION', style: AppText.statLabel),
                      Text(
                        'F(genotype) = ${fGeno.toStringAsFixed(2)} vs critical ≈4.76 (df=3,6, α=0.05) — '
                        '${fGeno > 4.76 ? "genotypes differ significantly; selection among them is justified." : "genotype differences are not significant at this replication level."}',
                        style: AppText.body,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
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

/// Line × Tester combining-ability analysis: decomposes each cross mean into General
/// Combining Ability (parent-level) and Specific Combining Ability (cross-level) effects.
class _LineXTesterAnalysis extends StatefulWidget {
  final VoidCallback onExit;
  const _LineXTesterAnalysis({required this.onExit});

  @override
  State<_LineXTesterAnalysis> createState() => _LineXTesterAnalysisState();
}

class _LineXTesterAnalysisState extends State<_LineXTesterAnalysis> {
  int seed = 1;
  bool computed = false;

  @override
  Widget build(BuildContext context) {
    const lines = ['L1', 'L2', 'L3', 'L4'];
    const testers = ['T1', 'T2'];
    const lineEffects = {'L1': 2.0, 'L2': -3.0, 'L3': 5.0, 'L4': -1.0};
    const testerEffects = {'T1': 1.0, 'T2': -1.0};
    final rng = Random(seed);

    final crossMeans = <String, Map<String, double>>{};
    for (final l in lines) {
      crossMeans[l] = {};
      for (final t in testers) {
        // A modest random interaction term simulates genuine SCA beyond additive GCA effects.
        final interaction = _gaussian(rng) * 2.2;
        crossMeans[l]![t] = 40 + lineEffects[l]! + testerEffects[t]! + interaction;
      }
    }

    final grandMean = crossMeans.values.expand((m) => m.values).reduce((a, b) => a + b) / (lines.length * testers.length);
    final lineMeans = {for (final l in lines) l: crossMeans[l]!.values.reduce((a, b) => a + b) / testers.length};
    final testerMeans = {
      for (final t in testers) t: lines.map((l) => crossMeans[l]![t]!).reduce((a, b) => a + b) / lines.length,
    };
    final lineGca = {for (final l in lines) l: lineMeans[l]! - grandMean};
    final testerGca = {for (final t in testers) t: testerMeans[t]! - grandMean};
    final sca = <String, double>{
      for (final l in lines)
        for (final t in testers) '$l×$t': crossMeans[l]![t]! - grandMean - lineGca[l]! - testerGca[t]!,
    };
    final bestCross = sca.entries.reduce((a, b) => a.value > b.value ? a : b);

    final bottomInset = MediaQuery.of(context).padding.bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _analysisHeader('Line × Tester Analysis', widget.onExit),
          AppCard(
            accentColor: _accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle('Cross means (t/ha)'),
                Text('${lines.length} lines × ${testers.length} testers = ${lines.length * testers.length} crosses.', style: AppText.caption),
                const SizedBox(height: AppSpacing.sm),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [const DataColumn(label: Text('Line')), for (final t in testers) DataColumn(label: Text(t))],
                    rows: [
                      for (final l in lines)
                        DataRow(cells: [DataCell(Text(l)), for (final t in testers) DataCell(Text(crossMeans[l]![t]!.toStringAsFixed(1)))]),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(onPressed: () => setState(() { seed += 1; computed = false; }), icon: const Icon(Icons.refresh, size: 14), label: const Text('New Mating Design')),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle('Your Task'),
                Text('Decompose each cross mean into GCA (line/tester) and SCA (cross-specific) effects to find the best-combining parents.', style: AppText.caption),
                const SizedBox(height: AppSpacing.sm),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() => computed = true);
                    context.read<GameProvider>().addXp(30, 'Completed a Line × Tester analysis');
                  },
                  icon: const Icon(Icons.science, size: 16),
                  label: const Text('Compute GCA / SCA'),
                ),
                if (computed) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text('GCA — Lines', style: AppText.statLabel),
                  SizedBox(
                    height: 120,
                    child: BarChart(
                      BarChartData(
                        barGroups: [
                          for (var i = 0; i < lines.length; i++)
                            BarChartGroupData(x: i, barRods: [BarChartRodData(toY: lineGca[lines[i]]!, color: lineGca[lines[i]]! >= 0 ? AppColors.good : AppColors.bad, width: 22, borderRadius: BorderRadius.circular(4))]),
                        ],
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) => Text(lines[v.toInt()], style: const TextStyle(fontSize: 10)))),
                        ),
                        gridData: const FlGridData(show: true, drawVerticalLine: false),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text('SCA — Best specific cross', style: AppText.statLabel),
                  const SizedBox(height: 4),
                  _statTile(bestCross.key, 'SCA ${bestCross.value.toStringAsFixed(2)}'),
                  const SizedBox(height: AppSpacing.sm),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('INTERPRETATION', style: AppText.statLabel),
                        Text(
                          'Lines/testers with the largest positive GCA transmit good general performance to any cross. '
                          '${bestCross.key} has the highest SCA — a specific combination that outperforms what its parents\' GCA alone would predict, making it the strongest hybrid candidate.',
                          style: AppText.body,
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

/// Simplified interval-mapping QTL scan: genotypes a biparental RIL population at markers
/// along one chromosome and tests each marker for a genotype-class mean difference,
/// approximating a LOD score from the resulting t-statistic.
class _QtlAnalysis extends StatefulWidget {
  final VoidCallback onExit;
  const _QtlAnalysis({required this.onExit});

  @override
  State<_QtlAnalysis> createState() => _QtlAnalysisState();
}

class _QtlAnalysisState extends State<_QtlAnalysis> {
  int seed = 1;
  bool computed = false;
  static const _markerPositions = [0, 10, 20, 30, 40, 50, 60];
  static const _causalMarkerIndex = 3; // the "true" QTL location, at 30 cM

  @override
  Widget build(BuildContext context) {
    const n = 80;
    final rng = Random(seed);

    // Simulate marker genotypes along the chromosome with Haldane-mapped recombination
    // between adjacent markers, then a trait value driven by the causal marker's genotype.
    final genotypes = List.generate(n, (_) {
      final row = <int>[];
      var allele = rng.nextBool() ? 1 : 0;
      for (var m = 0; m < _markerPositions.length; m++) {
        if (m > 0) {
          final d = (_markerPositions[m] - _markerPositions[m - 1]) / 100;
          final r = 0.5 * (1 - exp(-2 * d));
          if (rng.nextDouble() < r) allele = 1 - allele;
        }
        row.add(allele);
      }
      return row;
    });
    final traits = List.generate(n, (i) {
      final qtlEffect = genotypes[i][_causalMarkerIndex] == 1 ? 6.0 : 0.0;
      return 40 + qtlEffect + _gaussian(rng) * 5;
    });

    final lodScores = <double>[];
    for (var m = 0; m < _markerPositions.length; m++) {
      final group0 = <double>[], group1 = <double>[];
      for (var i = 0; i < n; i++) {
        (genotypes[i][m] == 0 ? group0 : group1).add(traits[i]);
      }
      if (group0.length < 2 || group1.length < 2) {
        lodScores.add(0);
        continue;
      }
      final mean0 = group0.reduce((a, b) => a + b) / group0.length;
      final mean1 = group1.reduce((a, b) => a + b) / group1.length;
      final pooledVar = (_variance(group0) * (group0.length - 1) + _variance(group1) * (group1.length - 1)) / (n - 2);
      final se = sqrt(pooledVar * (1 / group0.length + 1 / group1.length));
      final t = se == 0 ? 0.0 : (mean1 - mean0) / se;
      final r2 = (t * t) / (t * t + (n - 2));
      final lod = -(n / 2) * (log(1 - r2) / ln10);
      lodScores.add(lod.isFinite ? lod : 0);
    }
    final peakIndex = lodScores.indexOf(lodScores.reduce(max));

    final bottomInset = MediaQuery.of(context).padding.bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _analysisHeader('QTL Mapping', widget.onExit),
          AppCard(
            accentColor: _accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle('Mapping population'),
                Text('$n recombinant inbred lines genotyped at ${_markerPositions.length} markers across a 60 cM chromosome segment.', style: AppText.caption),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(onPressed: () => setState(() { seed += 1; computed = false; }), icon: const Icon(Icons.refresh, size: 14), label: const Text('New Population')),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle('Your Task'),
                Text('Scan each marker for a genotype-class trait difference to localize the QTL along the chromosome.', style: AppText.caption),
                const SizedBox(height: AppSpacing.sm),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() => computed = true);
                    context.read<GameProvider>().addXp(35, 'Completed a QTL mapping analysis');
                  },
                  icon: const Icon(Icons.science, size: 16),
                  label: const Text('Run Marker Scan'),
                ),
                if (computed) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text('LOD profile along chromosome', style: AppText.statLabel),
                  SizedBox(
                    height: 160,
                    child: BarChart(
                      BarChartData(
                        barGroups: [
                          for (var i = 0; i < _markerPositions.length; i++)
                            BarChartGroupData(x: i, barRods: [BarChartRodData(toY: lodScores[i], color: i == peakIndex ? AppColors.bad : _accent, width: 18, borderRadius: BorderRadius.circular(4))]),
                        ],
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) => Text('${_markerPositions[v.toInt()]}', style: const TextStyle(fontSize: 9)))),
                        ),
                        gridData: const FlGridData(show: true, drawVerticalLine: false),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _statTile('Peak position', '${_markerPositions[peakIndex]} cM'),
                  const SizedBox(height: AppSpacing.sm),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('INTERPRETATION', style: AppText.statLabel),
                        Text(
                          'LOD peaks at ${_markerPositions[peakIndex]} cM (LOD = ${lodScores[peakIndex].toStringAsFixed(2)}) — '
                          '${lodScores[peakIndex] > 3 ? 'above the conventional LOD ≥ 3 significance threshold, a strong candidate QTL position.' : 'below the conventional LOD ≥ 3 threshold — more individuals or markers would strengthen this signal.'}',
                          style: AppText.body,
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

/// Simplified GWAS scan across a diversity panel: association test per SNP marker,
/// visualized as a Manhattan-style bar chart of -log10(p) with a significance threshold.
class _GwasAnalysis extends StatefulWidget {
  final VoidCallback onExit;
  const _GwasAnalysis({required this.onExit});

  @override
  State<_GwasAnalysis> createState() => _GwasAnalysisState();
}

class _GwasAnalysisState extends State<_GwasAnalysis> {
  int seed = 1;
  bool computed = false;
  static const _snpCount = 12;
  static const _causalSnpIndex = 7;

  @override
  Widget build(BuildContext context) {
    const n = 100;
    final rng = Random(seed);

    final genotypes = List.generate(n, (_) => List.generate(_snpCount, (_) => rng.nextBool() ? 1 : 0));
    final traits = List.generate(n, (i) {
      final effect = genotypes[i][_causalSnpIndex] == 1 ? 4.5 : 0.0;
      return 50 + effect + _gaussian(rng) * 6;
    });

    final negLogP = <double>[];
    for (var s = 0; s < _snpCount; s++) {
      final group0 = <double>[], group1 = <double>[];
      for (var i = 0; i < n; i++) {
        (genotypes[i][s] == 0 ? group0 : group1).add(traits[i]);
      }
      if (group0.length < 2 || group1.length < 2) {
        negLogP.add(0);
        continue;
      }
      final mean0 = group0.reduce((a, b) => a + b) / group0.length;
      final mean1 = group1.reduce((a, b) => a + b) / group1.length;
      final pooledVar = (_variance(group0) * (group0.length - 1) + _variance(group1) * (group1.length - 1)) / (n - 2);
      final se = sqrt(pooledVar * (1 / group0.length + 1 / group1.length));
      final z = se == 0 ? 0.0 : (mean1 - mean0) / se;
      final p = (2 * (1 - _normalCdf(z.abs()))).clamp(1e-12, 1.0);
      negLogP.add(-(log(p) / ln10));
    }
    final peakIndex = negLogP.indexOf(negLogP.reduce(max));
    final threshold = -(log(0.05 / _snpCount) / ln10); // Bonferroni-corrected significance line

    final bottomInset = MediaQuery.of(context).padding.bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _analysisHeader('Genome-Wide Association Study', widget.onExit),
          AppCard(
            accentColor: _accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle('Diversity panel'),
                Text('$n unrelated accessions genotyped at $_snpCount genome-wide SNP markers.', style: AppText.caption),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(onPressed: () => setState(() { seed += 1; computed = false; }), icon: const Icon(Icons.refresh, size: 14), label: const Text('New Panel')),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle('Your Task'),
                Text('Test each SNP for association with the trait and identify which markers clear the significance threshold.', style: AppText.caption),
                const SizedBox(height: AppSpacing.sm),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() => computed = true);
                    context.read<GameProvider>().addXp(35, 'Completed a GWAS analysis');
                  },
                  icon: const Icon(Icons.science, size: 16),
                  label: const Text('Run Association Scan'),
                ),
                if (computed) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text('Manhattan plot (-log₁₀ p by SNP)', style: AppText.statLabel),
                  SizedBox(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        barGroups: [
                          for (var i = 0; i < _snpCount; i++)
                            BarChartGroupData(x: i, barRods: [BarChartRodData(toY: negLogP[i], color: negLogP[i] >= threshold ? AppColors.bad : _accent, width: 14, borderRadius: BorderRadius.circular(3))]),
                        ],
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) => Text('SNP${v.toInt() + 1}', style: const TextStyle(fontSize: 8)))),
                        ),
                        gridData: const FlGridData(show: true, drawVerticalLine: false),
                        borderData: FlBorderData(show: false),
                        extraLinesData: ExtraLinesData(horizontalLines: [
                          HorizontalLine(y: threshold, color: AppColors.warn, strokeWidth: 1.5, dashArray: [6, 4]),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _statTile('Top hit', 'SNP${peakIndex + 1} (${negLogP[peakIndex].toStringAsFixed(2)})'),
                  const SizedBox(height: AppSpacing.sm),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('INTERPRETATION', style: AppText.statLabel),
                        Text(
                          'SNP${peakIndex + 1} clears the Bonferroni-corrected threshold (dashed line), suggesting linkage to a causal locus. '
                          'Remember that population structure/relatedness — not modeled here — is the classic source of false-positive GWAS hits in real panels.',
                          style: AppText.body,
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
