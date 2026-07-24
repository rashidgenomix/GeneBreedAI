import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/crops.dart';
import '../../data/breeding_methods.dart';
import '../../data/field_events.dart';
import '../../models/types.dart';
import '../../engine/genetics.dart';
import '../../state/game_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/module_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/detail_sheet.dart';
import '../../widgets/status_state.dart';
import '../../widgets/trait_bar.dart';
import '../../widgets/icon_map.dart';

enum _Step { crop, parents, method, generations, release }

final _accent = moduleTheme(ModuleId.breeder).color;

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
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildStepper()),
              if (step != _Step.crop)
                TextButton.icon(onPressed: _reset, icon: const Icon(Icons.refresh, size: 16), label: const Text('Restart')),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
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
      (_Step.crop, Icons.eco, 'Crop'),
      (_Step.parents, Icons.diversity_3, 'Parents'),
      (_Step.method, Icons.alt_route, 'Method'),
      (_Step.generations, Icons.grain, 'Grow'),
      (_Step.release, Icons.emoji_events, 'Release'),
    ];
    final idx = steps.indexWhere((s) => s.$1 == step);
    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          Column(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: i <= idx ? _accent : Colors.black.withValues(alpha: 0.08),
                child: Icon(steps[i].$2, size: 15, color: i <= idx ? Colors.white : Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(steps[i].$3, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: i == idx ? _accent : Colors.grey)),
            ],
          ),
          if (i < steps.length - 1) Expanded(child: Container(height: 2, margin: const EdgeInsets.only(bottom: 14), color: i < idx ? _accent : Colors.black.withValues(alpha: 0.08))),
        ],
      ],
    );
  }

  Widget _buildCropStep() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: crops.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.95),
      itemBuilder: (context, i) {
        final c = crops[i];
        return EntityCard(
          icon: Icons.eco,
          accentColor: _accent,
          title: '${c.emoji} ${c.name}',
          description: '${c.germplasm.length} germplasm lines',
          onTap: () => setState(() {
            crop = c;
            step = _Step.parents;
          }),
          onViewDetails: () => _showCropDetails(c),
        );
      },
    );
  }

  void _showCropDetails(Crop c) {
    showDetailSheet(
      context,
      title: c.name,
      subtitle: c.scientificName,
      icon: Icons.eco,
      accentColor: _accent,
      children: [
        DetailSection(label: 'About', text: c.description),
        DetailSection(label: 'Genome', text: '${c.chromosomeNumber} chromosomes · ${c.genomeSizeMb.toStringAsFixed(0)} Mb genome size'),
        DetailBulletList(label: 'Environments', items: [for (final e in c.environments) '${e.name} — ${e.description}'], bulletColor: _accent),
      ],
    );
  }

  Widget _buildParentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Explore the ${crop!.name} germplasm collection and choose two parents to cross.', style: AppText.body),
        const SizedBox(height: AppSpacing.md),
        _parentPicker('Parent A', parentA, (g) => setState(() => parentA = g)),
        const SizedBox(height: AppSpacing.md),
        _parentPicker('Parent B', parentB, (g) => setState(() => parentB = g)),
        if (parentA != null && parentB != null) ...[
          const SizedBox(height: AppSpacing.md),
          AppCard(
            accentColor: _accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle('Trait Comparison'),
                Text('${parentA!.name} vs ${parentB!.name}', style: AppText.caption),
                const SizedBox(height: AppSpacing.sm),
                Text(parentA!.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                for (final t in crop!.traits) TraitBarWidget(trait: t, value: parentA!.traitValues[t.id] ?? 0.5, compareValue: parentB!.traitValues[t.id]),
                const SizedBox(height: AppSpacing.sm),
                Text(parentB!.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                for (final t in crop!.traits) TraitBarWidget(trait: t, value: parentB!.traitValues[t.id] ?? 0.5, compareValue: parentA!.traitValues[t.id]),
                const SizedBox(height: AppSpacing.md),
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
      accentColor: _accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardTitle(label),
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: crop!.germplasm.length,
              itemBuilder: (context, i) {
                final g = crop!.germplasm[i];
                final isSelected = selected?.id == g.id;
                return Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  color: isSelected ? _accent.withValues(alpha: 0.12) : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm), side: BorderSide(color: isSelected ? _accent : Colors.black12)),
                  child: ListTile(
                    dense: true,
                    onTap: () => onPick(g),
                    title: Text(g.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: Text(g.origin, style: AppText.caption),
                    trailing: IconButton(
                      icon: const Icon(Icons.info_outline, size: 18),
                      onPressed: () => _showGermplasmDetails(g),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showGermplasmDetails(Germplasm g) {
    showDetailSheet(
      context,
      title: g.name,
      subtitle: g.origin,
      icon: Icons.eco,
      accentColor: _accent,
      children: [
        DetailSection(label: 'Description', text: g.description),
        DetailBulletList(label: 'Tags', items: g.tags, bulletColor: _accent),
        const SizedBox(height: AppSpacing.sm),
        Text('TRAIT PROFILE', style: AppText.statLabel),
        const SizedBox(height: 4),
        for (final t in crop!.traits) TraitBarWidget(trait: t, value: g.traitValues[t.id] ?? 0.5),
      ],
    );
  }

  Widget _buildMethodStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Every breeding method trades off speed, cost, and precision. Tap a card to select it.', style: AppText.body),
        const SizedBox(height: AppSpacing.md),
        for (final m in breedingMethods)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: EntityCard(
              icon: Icons.alt_route,
              accentColor: _accent,
              title: m.name,
              description: m.summary,
              status: method == m.id ? StatusState.completed : null,
              onTap: () => setState(() => method = m.id),
              onViewDetails: () => _showMethodDetails(m),
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        ElevatedButton.icon(
          onPressed: method != null ? _doHybridize : null,
          icon: const Icon(Icons.auto_awesome, size: 16),
          label: const Text('Perform Hybridization'),
        ),
      ],
    );
  }

  void _showMethodDetails(BreedingMethodInfo m) {
    showDetailSheet(
      context,
      title: m.name,
      subtitle: '~${m.generationsToStability} generations to stability',
      icon: Icons.alt_route,
      accentColor: _accent,
      children: [
        DetailSection(label: 'Summary', text: m.summary),
        DetailBulletList(label: 'Advantages', items: m.advantages, bulletColor: AppColors.good),
        DetailBulletList(label: 'Limitations', items: m.limitations, bulletColor: AppColors.bad),
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
            accentColor: AppColors.warn,
            child: InkWell(
              onTap: () => _showFieldEventDetails(activeEvent!),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(iconForName(activeEvent!.icon), color: Colors.amber.shade700),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(child: Text('Field Event: ${activeEvent!.name}', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.amber.shade800))),
                          Pill(activeEvent!.severity.name, tone: activeEvent!.severity == FieldEventSeverity.high ? PillTone.bad : PillTone.warn),
                        ]),
                        Text(activeEvent!.description, style: AppText.body, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 18),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        Text('Generation $label', style: AppText.sectionTitle),
        Text('Method: ${methodInfo.name} · progress ${genIndex + 1}/$targetGenerations', style: AppText.caption),
        const SizedBox(height: AppSpacing.sm),
        Wrap(spacing: 8, runSpacing: 8, children: [
          OutlinedButton(onPressed: () => _selectTopN(4), child: const Text('Auto-select Top 4')),
          if (readyToRelease)
            ElevatedButton(onPressed: () => setState(() => step = _Step.release), child: const Text('Proceed to Release →'))
          else
            ElevatedButton(onPressed: selectedCount >= 2 ? _advance : null, child: Text('Advance Generation ($selectedCount selected)')),
        ]),
        const SizedBox(height: AppSpacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: gen.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 0.8),
          itemBuilder: (context, i) {
            final ind = gen[i];
            return AppCard(
              padding: const EdgeInsets.all(10),
              accentColor: ind.selected ? _accent : null,
              child: InkWell(
                onTap: () => _toggleSelect(ind.id),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Expanded(child: Text(ind.label.split(' ')[0], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis)),
                      GestureDetector(
                        onTap: () => _showIndividualDetails(ind),
                        child: Pill('${scoreIndividual(ind, crop!)}', tone: PillTone.info),
                      ),
                    ]),
                    for (final t in crop!.traits.take(2)) TraitBarWidget(trait: t, value: ind.traitValues[t.id] ?? 0.5),
                    if (ind.selected) Icon(Icons.check_circle, size: 14, color: _accent),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showFieldEventDetails(FieldEvent e) {
    showDetailSheet(
      context,
      title: e.name,
      subtitle: '${e.severity.name} severity',
      icon: iconForName(e.icon),
      accentColor: AppColors.warn,
      children: [
        DetailSection(label: 'What happened', text: e.description),
        if (e.favors.isNotEmpty) DetailBulletList(label: 'Favors traits', items: e.favors, bulletColor: AppColors.good),
      ],
    );
  }

  void _showIndividualDetails(Individual ind) {
    showDetailSheet(
      context,
      title: ind.label,
      subtitle: 'Score ${scoreIndividual(ind, crop!)}/100 · Heterozygosity ${(ind.heterozygosity * 100).round()}%',
      icon: Icons.grain,
      accentColor: _accent,
      children: [
        Text('FULL TRAIT PROFILE', style: AppText.statLabel),
        const SizedBox(height: 4),
        for (final t in crop!.traits) TraitBarWidget(trait: t, value: ind.traitValues[t.id] ?? 0.5),
        const SizedBox(height: AppSpacing.sm),
        DetailBulletList(label: 'Genotype', items: [for (final entry in ind.genotype.entries) '${entry.key}: ${entry.value}'], bulletColor: _accent),
      ],
    );
  }

  Widget _buildReleaseStep() {
    final currentGen = generations[genIndex];
    final best = ([...currentGen]..sort((a, b) => scoreIndividual(b, crop!).compareTo(scoreIndividual(a, crop!)))).first;
    return AppCard(
      accentColor: _accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardTitle('Release Candidate: Best Line'),
          Pill('Score: ${scoreIndividual(best, crop!)}/100', tone: PillTone.good),
          const SizedBox(height: AppSpacing.sm),
          for (final t in crop!.traits) TraitBarWidget(trait: t, value: best.traitValues[t.id] ?? 0.5),
          const SizedBox(height: AppSpacing.md),
          TextField(
            decoration: InputDecoration(hintText: 'e.g. ${crop!.name}-Champion-1', border: const OutlineInputBorder()),
            onChanged: (v) => releasedName = v,
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(onPressed: _releaseVariety, icon: const Icon(Icons.emoji_events, size: 16), label: const Text('Release Variety')),
        ],
      ),
    );
  }

  Widget _buildReleasedCard() {
    return AppCard(
      accentColor: _accent,
      child: Column(
        children: [
          Icon(Icons.emoji_events, color: _accent, size: 40),
          const SizedBox(height: AppSpacing.sm),
          Text('🎉 "${released!.name}" Released!', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('Final performance score: ${released!.score}/100. Saved to your research record.', textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(onPressed: _reset, icon: const Icon(Icons.auto_awesome, size: 16), label: const Text('Breed Another Variety')),
        ],
      ),
    );
  }
}
