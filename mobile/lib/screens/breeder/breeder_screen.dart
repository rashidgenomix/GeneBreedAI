import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/crops.dart';
import '../../data/breeding_methods.dart';
import '../../data/field_events.dart';
import '../../models/types.dart';
import '../../engine/genetics.dart';
import '../../state/game_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/trait_bar.dart';
import '../../widgets/icon_map.dart';

enum _Step { crop, parents, method, generations, release }

class BreederScreen extends StatefulWidget {
  const BreederScreen({super.key});

  @override
  State<BreederScreen> createState() => _BreederScreenState();
}

class _BreederScreenState extends State<BreederScreen> {
  _Step step = _Step.crop;
  Crop? crop;
  Germplasm? parentA;
  Germplasm? parentB;
  BreedingMethod? method;

  final List<List<Individual>> generations = [];
  int genIndex = 0;
  final List<(int, FieldEvent)> eventLog = [];
  FieldEvent? activeEvent;
  String releasedName = '';
  ({String name, int score})? released;

  final Random rng = Random();

  void _reset() {
    setState(() {
      step = _Step.crop;
      crop = null;
      parentA = null;
      parentB = null;
      method = null;
      generations.clear();
      genIndex = 0;
      eventLog.clear();
      activeEvent = null;
      releasedName = '';
      released = null;
    });
  }

  void _doHybridize() {
    if (crop == null || parentA == null || parentB == null) return;
    final result = hybridize(parentA!, parentB!, crop!, rng);
    setState(() {
      generations
        ..clear()
        ..add(result.f1);
      genIndex = 0;
      step = _Step.generations;
    });
    context.read<GameProvider>().addXp(25, 'Performed first hybridization');
    context.read<GameProvider>().unlockBadge('first-cross');
  }

  void _toggleSelect(String id) {
    setState(() {
      generations[genIndex] = generations[genIndex].map((ind) => ind.id == id ? ind.copyWith(selected: !ind.selected) : ind).toList();
    });
  }

  void _selectTopN(int n) {
    if (crop == null) return;
    setState(() {
      final gen = generations[genIndex];
      final ranked = [...gen]..sort((a, b) => scoreIndividual(b, crop!).compareTo(scoreIndividual(a, crop!)));
      final topIds = ranked.take(n).map((e) => e.id).toSet();
      generations[genIndex] = gen.map((ind) => ind.copyWith(selected: topIds.contains(ind.id))).toList();
    });
  }

  void _advance() {
    if (crop == null) return;
    final currentGen = generations[genIndex];
    if (currentGen.where((i) => i.selected).length < 2) return;

    final event = rollFieldEvent(rng);
    final pressured = applyFieldEventPressure(currentGen, event.favors, event.severity, rng);
    final nextGen = advanceGeneration(pressured, crop!, genIndex + 2, rng);

    setState(() {
      generations
        ..removeRange(genIndex + 1, generations.length)
        ..add(nextGen);
      genIndex += 1;
      activeEvent = event;
      eventLog.add((genIndex + 1, event));
    });
    context.read<GameProvider>().addXp(15, 'Advanced to generation F${genIndex + 1}');
  }

  void _releaseVariety() {
    if (crop == null || method == null || releasedName.trim().isEmpty) return;
    final currentGen = generations[genIndex];
    final best = ([...currentGen]..sort((a, b) => scoreIndividual(b, crop!).compareTo(scoreIndividual(a, crop!)))).first;
    final score = scoreIndividual(best, crop!);
    setState(() => released = (name: releasedName.trim(), score: score));

    final game = context.read<GameProvider>();
    game.addXp(50 + (score / 2).round(), 'Released new variety "${releasedName.trim()}"');
    game.unlockBadge('first-release');
    if (eventLog.any((e) => e.$2.severity == FieldEventSeverity.high)) {
      game.unlockBadge('survivor');
    }
  }

  @override
  Widget build(BuildContext context) {
    final methodInfo = method != null ? getBreedingMethod(method!) : null;
    final targetGenerations = methodInfo?.generationsToStability ?? 6;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🌾 AI Plant Breeder Simulator', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    SizedBox(height: 4),
                    Text('Select parents, choose a method, and steer generations through real field challenges toward a released variety.',
                        style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              if (step != _Step.crop)
                TextButton.icon(onPressed: _reset, icon: const Icon(Icons.chevron_left, size: 16), label: const Text('Start Over')),
            ],
          ),
          const SizedBox(height: 12),
          _buildStepper(),
          const SizedBox(height: 12),
          if (step == _Step.crop) _buildCropStep(),
          if (step == _Step.parents && crop != null) _buildParentStep(),
          if (step == _Step.method && crop != null && parentA != null && parentB != null) _buildMethodStep(),
          if (step == _Step.generations && crop != null) _buildGenerationsStep(methodInfo!, targetGenerations),
          if (step == _Step.release && crop != null && released == null) _buildReleaseStep(),
          if (released != null) _buildReleasedCard(),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    final steps = [
      (_Step.crop, '1. Crop'),
      (_Step.parents, '2. Parents'),
      (_Step.method, '3. Method'),
      (_Step.generations, '4. Grow & Select'),
      (_Step.release, '5. Release'),
    ];
    final idx = steps.indexWhere((s) => s.$1 == step);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var i = 0; i < steps.length; i++)
          Chip(
            label: Text(steps[i].$2, style: TextStyle(fontSize: 11, color: i == idx ? Colors.white : null)),
            backgroundColor: i == idx ? const Color(0xFF059669) : (i < idx ? const Color(0x2210B981) : Colors.black.withValues(alpha: 0.05)),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
          ),
      ],
    );
  }

  Widget _buildCropStep() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: crops.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.85),
      itemBuilder: (context, i) {
        final c = crops[i];
        return AppCard(
          child: InkWell(
            onTap: () => setState(() {
              crop = c;
              step = _Step.parents;
            }),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 6),
                Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(c.scientificName, style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                const SizedBox(height: 6),
                Expanded(child: Text(c.description, style: const TextStyle(fontSize: 11), overflow: TextOverflow.fade)),
                Pill('${c.germplasm.length} lines', tone: PillTone.info),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildParentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Explore the ${crop!.name} germplasm collection and choose two parents to cross.', style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 10),
        _parentPicker('Parent A', parentA, (g) => setState(() => parentA = g)),
        const SizedBox(height: 10),
        _parentPicker('Parent B', parentB, (g) => setState(() => parentB = g)),
        if (parentA != null && parentB != null) ...[
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle('Trait Comparison'),
                Text('${parentA!.name} vs ${parentB!.name}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 8),
                Text(parentA!.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                for (final t in crop!.traits) TraitBarWidget(trait: t, value: parentA!.traitValues[t.id] ?? 0.5, compareValue: parentB!.traitValues[t.id]),
                const SizedBox(height: 8),
                Text(parentB!.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                for (final t in crop!.traits) TraitBarWidget(trait: t, value: parentB!.traitValues[t.id] ?? 0.5, compareValue: parentA!.traitValues[t.id]),
                const SizedBox(height: 10),
                ElevatedButton(onPressed: () => setState(() => step = _Step.method), child: const Text('Choose Breeding Method →')),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _parentPicker(String label, Germplasm? selected, void Function(Germplasm) onPick) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardTitle(label),
          SizedBox(
            height: 180,
            child: ListView.builder(
              itemCount: crop!.germplasm.length,
              itemBuilder: (context, i) {
                final g = crop!.germplasm[i];
                final isSelected = selected?.id == g.id;
                return Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  color: isSelected ? const Color(0x2210B981) : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isSelected ? const Color(0xFF059669) : Colors.black12)),
                  child: ListTile(
                    dense: true,
                    onTap: () => onPick(g),
                    title: Text(g.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: Text(g.origin, style: const TextStyle(fontSize: 11)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Every breeding method trades off speed, cost, and precision.', style: TextStyle(fontSize: 13)),
        const SizedBox(height: 10),
        for (final m in breedingMethods)
          AppCard(
            padding: const EdgeInsets.all(12),
            child: InkWell(
              onTap: () => setState(() => method = m.id),
              child: Container(
                decoration: method == m.id ? BoxDecoration(border: Border.all(color: const Color(0xFF059669), width: 2), borderRadius: BorderRadius.circular(12)) : null,
                padding: const EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CardTitle(m.name),
                    Text(m.summary, style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 6),
                    Text('Advantages', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.green.shade700)),
                    for (final a in m.advantages) Text('• $a', style: const TextStyle(fontSize: 11)),
                    const SizedBox(height: 4),
                    Text('Limitations', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.red.shade400)),
                    for (final a in m.limitations) Text('• $a', style: const TextStyle(fontSize: 11)),
                    const SizedBox(height: 6),
                    Pill('~${m.generationsToStability} generations', tone: PillTone.info),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: method != null ? _doHybridize : null,
          icon: const Icon(Icons.auto_awesome, size: 16),
          label: const Text('Perform Hybridization'),
        ),
      ],
    );
  }

  Widget _buildGenerationsStep(BreedingMethodInfo methodInfo, int targetGenerations) {
    final gen = generations[genIndex];
    final selectedCount = gen.where((i) => i.selected).length;
    final label = genIndex == 0 ? 'F1' : 'F${genIndex + 1}';
    final readyToRelease = genIndex + 1 >= targetGenerations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (activeEvent != null)
          AppCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(iconForName(activeEvent!.icon), color: Colors.amber.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text('Field Event: ${activeEvent!.name}', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.amber.shade800)),
                        const SizedBox(width: 6),
                        Pill(activeEvent!.severity.name, tone: activeEvent!.severity == FieldEventSeverity.high ? PillTone.bad : PillTone.warn),
                      ]),
                      Text(activeEvent!.description, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 10),
        Text('Generation $label', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        Text('Method: ${methodInfo.name} · progress ${genIndex + 1}/$targetGenerations', style: const TextStyle(fontSize: 11)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          OutlinedButton(onPressed: () => _selectTopN(4), child: const Text('Auto-select Top 4')),
          if (readyToRelease)
            ElevatedButton(onPressed: () => setState(() => step = _Step.release), child: const Text('Proceed to Release →'))
          else
            ElevatedButton(onPressed: selectedCount >= 2 ? _advance : null, child: Text('Advance Generation ($selectedCount selected)')),
        ]),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: gen.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 0.78),
          itemBuilder: (context, i) {
            final ind = gen[i];
            return AppCard(
              padding: const EdgeInsets.all(10),
              child: InkWell(
                onTap: () => _toggleSelect(ind.id),
                child: Container(
                  decoration: ind.selected ? BoxDecoration(border: Border.all(color: const Color(0xFF059669), width: 2), borderRadius: BorderRadius.circular(10)) : null,
                  padding: const EdgeInsets.all(2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(ind.label.split(' ')[0], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                        Pill('${scoreIndividual(ind, crop!)}', tone: PillTone.info),
                      ]),
                      for (final t in crop!.traits.take(3)) TraitBarWidget(trait: t, value: ind.traitValues[t.id] ?? 0.5),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReleaseStep() {
    final currentGen = generations[genIndex];
    final best = ([...currentGen]..sort((a, b) => scoreIndividual(b, crop!).compareTo(scoreIndividual(a, crop!)))).first;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardTitle('Release Candidate: Best Line'),
          Pill('Score: ${scoreIndividual(best, crop!)}/100', tone: PillTone.good),
          const SizedBox(height: 8),
          for (final t in crop!.traits) TraitBarWidget(trait: t, value: best.traitValues[t.id] ?? 0.5),
          const SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(hintText: 'e.g. ${crop!.name}-Champion-1', border: const OutlineInputBorder()),
            onChanged: (v) => releasedName = v,
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(onPressed: _releaseVariety, icon: const Icon(Icons.emoji_events, size: 16), label: const Text('Release Variety')),
        ],
      ),
    );
  }

  Widget _buildReleasedCard() {
    return AppCard(
      child: Column(
        children: [
          const Icon(Icons.emoji_events, color: Colors.amber, size: 40),
          const SizedBox(height: 8),
          Text('🎉 "${released!.name}" Released!', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('Final performance score: ${released!.score}/100. Saved to your research record.', textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton.icon(onPressed: _reset, icon: const Icon(Icons.auto_awesome, size: 16), label: const Text('Breed Another Variety')),
        ],
      ),
    );
  }
}
