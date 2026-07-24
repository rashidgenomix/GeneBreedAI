import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/game_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/module_theme.dart';
import '../../widgets/app_card.dart';

final _accent = moduleTheme(ModuleId.games).color;
const _geneNames = ['flr-1', 'dwf-2', 'res-3', 'qtl-4'];

/// A slider-based placement game: drag each gene's slider to match its given genetic
/// distance (in cM) from a fixed reference gene, watching the marker move live along
/// a chromosome ruler.
class GenomeMappingGame extends StatefulWidget {
  final VoidCallback onExit;
  const GenomeMappingGame({super.key, required this.onExit});

  @override
  State<GenomeMappingGame> createState() => _GenomeMappingGameState();
}

class _GenomeMappingGameState extends State<GenomeMappingGame> {
  int seed = 1;
  late List<double> targets;
  late List<double> sliderValues;
  Map<int, bool>? results;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _generate() {
    final rng = Random(seed);
    targets = List.generate(_geneNames.length, (_) => (10 + rng.nextInt(80)).toDouble());
    sliderValues = List.filled(_geneNames.length, 50);
    results = null;
  }

  void _check() {
    setState(() {
      results = {for (var i = 0; i < targets.length; i++) i: (sliderValues[i] - targets[i]).abs() <= 3};
    });
    if (results!.values.every((v) => v)) {
      context.read<GameProvider>().addXp(25, 'Mapped all genes correctly onto the chromosome');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Genome Mapping', style: AppText.sectionTitle)),
              TextButton(onPressed: widget.onExit, child: const Text('← Back to Games')),
            ],
          ),
          Text('Use each slider to place the gene at its given distance (cM) from the reference gene "ref-0" at position 0.', style: AppText.body),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            accentColor: _accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle('Chromosome ruler'),
                _ruler(),
                const SizedBox(height: AppSpacing.md),
                for (var i = 0; i < _geneNames.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        SizedBox(width: 56, child: Text(_geneNames[i], style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700, fontSize: 12))),
                        Expanded(
                          child: Slider(
                            value: sliderValues[i],
                            min: 0,
                            max: 100,
                            activeColor: results == null ? _accent : (results![i]! ? AppColors.good : AppColors.bad),
                            label: '${sliderValues[i].round()} cM',
                            onChanged: (v) => setState(() {
                              sliderValues[i] = v;
                              results = null;
                            }),
                          ),
                        ),
                        SizedBox(width: 40, child: Text('${sliderValues[i].round()}', textAlign: TextAlign.end, style: AppText.caption)),
                      ],
                    ),
                  ),
                Text('Target distances: ${List.generate(targets.length, (i) => "${_geneNames[i]}=${targets[i].round()}cM").join(", ")}', style: AppText.caption),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(spacing: 8, children: [
            ElevatedButton.icon(onPressed: _check, icon: const Icon(Icons.check, size: 16), label: const Text('Check Positions')),
            OutlinedButton.icon(onPressed: () => setState(() { seed += 1; _generate(); }), icon: const Icon(Icons.refresh, size: 16), label: const Text('New Map')),
          ]),
          if (results != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              child: Text(
                results!.values.every((v) => v) ? 'All genes placed within tolerance — map complete!' : 'Some genes are still off — green sliders are within ±3 cM of the true position.',
                style: AppText.body,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _ruler() {
    return SizedBox(
      height: 34,
      child: LayoutBuilder(builder: (context, constraints) {
        return Stack(
          children: [
            Positioned(top: 16, left: 0, right: 0, child: Container(height: 2, color: Colors.grey.withValues(alpha: 0.4))),
            for (var i = 0; i < targets.length; i++)
              Positioned(
                left: (sliderValues[i] / 100) * (constraints.maxWidth - 12),
                top: 0,
                child: Icon(Icons.location_on, size: 22, color: results == null ? _accent : (results![i]! ? AppColors.good : AppColors.bad)),
              ),
          ],
        );
      }),
    );
  }
}
