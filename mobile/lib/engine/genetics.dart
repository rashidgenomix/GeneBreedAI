import 'dart:math';
import '../models/types.dart';

// A small, teachable genetics engine — mirrors frontend/src/lib/genetics.ts from the web
// app so both clients compute identical, pedagogically-sound outcomes:
//
//  1. Monogenic traits segregate as single Mendelian loci (dominant/recessive).
//  2. Polygenic traits are modeled as the additive average of "parental breeding values"
//     plus environmental noise, mimicking quantitative trait inheritance.

int _idCounter = 0;
String _nextId(String prefix) {
  _idCounter += 1;
  return '$prefix-${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}-$_idCounter';
}

double _clamp01(double v) => v.clamp(0.0, 1.0);

Individual _germplasmToIndividual(Germplasm g, String cropId) {
  return Individual(
    id: _nextId('ind'),
    cropId: cropId,
    generation: 0,
    label: g.name,
    parents: null,
    traitValues: Map.of(g.traitValues),
    genotype: Map.of(g.genotype),
    heterozygosity: 0,
    selected: true,
  );
}

String _segregateLocus(String parentA, String parentB, Random rng) {
  final alleleA = parentA[rng.nextInt(parentA.length)];
  final alleleB = parentB[rng.nextInt(parentB.length)];
  final pair = [alleleA, alleleB]
    ..sort((a, b) {
      final aUpper = a == a.toUpperCase();
      final bUpper = b == b.toUpperCase();
      if (aUpper == bUpper) return a.compareTo(b);
      return aUpper ? -1 : 1;
    });
  return pair.join();
}

double _phenotypeFromGenotype(Trait trait, String genotype) {
  final hasDominant = genotype.contains(RegExp('[A-Z]'));
  if (trait.inheritance == TraitInheritance.monogenicDominant) {
    return hasDominant ? 0.85 : 0.25;
  }
  if (trait.inheritance == TraitInheritance.monogenicRecessive) {
    return hasDominant ? 0.35 : 0.85;
  }
  return 0.5;
}

/// Produce a single offspring individual from two parents.
Individual cross(Individual parentA, Individual parentB, Crop crop, int generation, Random rng) {
  final traitValues = <String, double>{};
  final genotype = <String, String>{};
  int hetLoci = 0;
  int totalLoci = 0;

  final allLocusKeys = {...parentA.genotype.keys, ...parentB.genotype.keys};
  for (final locus in allLocusKeys) {
    final gA = parentA.genotype[locus] ?? 'RR';
    final gB = parentB.genotype[locus] ?? 'RR';
    final childGenotype = _segregateLocus(gA, gB, rng);
    genotype[locus] = childGenotype;
    totalLoci += 1;
    if (childGenotype[0] != childGenotype[1]) hetLoci += 1;
  }

  for (final trait in crop.traits) {
    if (trait.inheritance == TraitInheritance.polygenic) {
      final midParent = ((parentA.traitValues[trait.id] ?? 0.5) + (parentB.traitValues[trait.id] ?? 0.5)) / 2;
      final samplingNoise = (rng.nextDouble() - 0.5) * 0.18;
      traitValues[trait.id] = _clamp01(midParent + samplingNoise);
    } else {
      final prefix = trait.id.split('_')[0].substring(0, min(3, trait.id.split('_')[0].length));
      final linkedLocus = genotype.keys.firstWhere(
        (l) => l.toLowerCase().contains(prefix),
        orElse: () => genotype.keys.isNotEmpty ? genotype.keys.first : '',
      );
      final genoStr = linkedLocus.isNotEmpty ? genotype[linkedLocus]! : 'Rr';
      traitValues[trait.id] = _phenotypeFromGenotype(trait, genoStr);
    }
  }

  final shortA = parentA.label.length > 8 ? parentA.label.substring(0, 8) : parentA.label;
  final shortB = parentB.label.length > 8 ? parentB.label.substring(0, 8) : parentB.label;

  return Individual(
    id: _nextId('ind'),
    cropId: crop.id,
    generation: generation,
    label: '${generation == 1 ? "F1" : "F$generation"} ($shortA × $shortB)',
    parents: [parentA.id, parentB.id],
    traitValues: traitValues,
    genotype: genotype,
    heterozygosity: totalLoci > 0 ? hetLoci / totalLoci : 0,
    selected: false,
  );
}

class HybridizationResult {
  final Individual parentA;
  final Individual parentB;
  final List<Individual> f1;
  HybridizationResult({required this.parentA, required this.parentB, required this.f1});
}

/// Generate an F1 population (default 12 individuals) from two chosen parent germplasm.
HybridizationResult hybridize(Germplasm parentAG, Germplasm parentBG, Crop crop, Random rng, {int populationSize = 12}) {
  final parentA = _germplasmToIndividual(parentAG, crop.id);
  final parentB = _germplasmToIndividual(parentBG, crop.id);
  final f1 = List.generate(populationSize, (_) => cross(parentA, parentB, crop, 1, rng));
  return HybridizationResult(parentA: parentA, parentB: parentB, f1: f1);
}

/// Advance a generation via random mating/selfing within the selected subset of the previous generation.
List<Individual> advanceGeneration(List<Individual> previousGeneration, Crop crop, int generation, Random rng, {int populationSize = 12}) {
  final pool = previousGeneration.where((i) => i.selected).toList();
  final breedingPool = pool.length >= 2 ? pool : previousGeneration;
  final next = <Individual>[];
  for (var i = 0; i < populationSize; i++) {
    final a = breedingPool[rng.nextInt(breedingPool.length)];
    var b = breedingPool[rng.nextInt(breedingPool.length)];
    if (breedingPool.length > 1) {
      var guard = 0;
      while (b.id == a.id && guard < 10) {
        b = breedingPool[rng.nextInt(breedingPool.length)];
        guard += 1;
      }
    }
    next.add(cross(a, b, crop, generation, rng));
  }
  return next;
}

/// Score an individual 0-100 against a crop's traits, used for selection index & release scoring.
int scoreIndividual(Individual ind, Crop crop, {Map<String, double>? weights}) {
  double total = 0;
  double weightSum = 0;
  for (final trait in crop.traits) {
    final w = weights?[trait.id] ?? 1.0;
    final raw = ind.traitValues[trait.id] ?? 0.5;
    final normalized = trait.direction == TraitDirection.lowerBetter ? 1 - raw : raw;
    total += normalized * w;
    weightSum += w;
  }
  return weightSum > 0 ? ((total / weightSum) * 100).round() : 0;
}

/// Convert a normalized 0-1 trait value into a human-readable display value for a trait's unit range.
String displayTraitValue(Trait trait, double normalized) {
  final value = trait.minValue + normalized * (trait.maxValue - trait.minValue);
  final decimals = (trait.maxValue - trait.minValue) > 20 ? 0 : 1;
  return '${value.toStringAsFixed(decimals)} ${trait.unit}';
}

/// Apply a field-event's selection pressure: individuals lacking the favored trait(s) take a
/// survival/score penalty (modeled as a yield penalty).
List<Individual> applyFieldEventPressure(List<Individual> population, List<String> favoredTraitIds, FieldEventSeverity severity, Random rng) {
  final severityPenalty = {FieldEventSeverity.low: 0.08, FieldEventSeverity.medium: 0.16, FieldEventSeverity.high: 0.28}[severity]!;
  if (favoredTraitIds.isEmpty) return population;
  return population.map((ind) {
    final avgFavored = favoredTraitIds.map((t) => ind.traitValues[t] ?? 0.5).reduce((a, b) => a + b) / favoredTraitIds.length;
    final survivalPenalty = (1 - avgFavored) * severityPenalty * (0.7 + rng.nextDouble() * 0.6);
    final adjusted = Map<String, double>.of(ind.traitValues);
    adjusted['yield'] = _clamp01((adjusted['yield'] ?? 0.5) - survivalPenalty);
    return ind.copyWith(traitValues: adjusted);
  }).toList();
}
