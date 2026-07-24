// Core domain types shared across GeneBreed AI modules.
// Mirrors frontend/src/data/types.ts from the web app so both clients share one model.

enum TraitInheritance { monogenicDominant, monogenicRecessive, polygenic }

enum TraitDirection { higherBetter, lowerBetter, targetValue }

class Trait {
  final String id;
  final String name;
  final String description;
  final TraitInheritance inheritance;
  final String unit;
  final int? loci;
  final TraitDirection direction;
  final double? targetValue;
  final double minValue;
  final double maxValue;

  const Trait({
    required this.id,
    required this.name,
    required this.description,
    required this.inheritance,
    required this.unit,
    this.loci,
    required this.direction,
    this.targetValue,
    required this.minValue,
    required this.maxValue,
  });
}

class Germplasm {
  final String id;
  final String cropId;
  final String name;
  final String origin;
  final String description;
  final Map<String, double> traitValues;
  final Map<String, String> genotype;
  final List<String> tags;

  const Germplasm({
    required this.id,
    required this.cropId,
    required this.name,
    required this.origin,
    required this.description,
    required this.traitValues,
    required this.genotype,
    required this.tags,
  });
}

class CropEnvironment {
  final String id;
  final String name;
  final String description;
  final List<String> stressors;

  const CropEnvironment({
    required this.id,
    required this.name,
    required this.description,
    required this.stressors,
  });
}

class Crop {
  final String id;
  final String name;
  final String scientificName;
  final String emoji;
  final String description;
  final int chromosomeNumber;
  final double genomeSizeMb;
  final List<Trait> traits;
  final List<Germplasm> germplasm;
  final List<CropEnvironment> environments;
  final bool unlocked;
  final int unlockLevel;

  const Crop({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.emoji,
    required this.description,
    required this.chromosomeNumber,
    required this.genomeSizeMb,
    required this.traits,
    required this.germplasm,
    required this.environments,
    required this.unlocked,
    required this.unlockLevel,
  });
}

enum BreedingMethod {
  pedigree,
  bulk,
  backcross,
  singleSeedDescent,
  recurrentSelection,
  massSelection,
  hybrid,
  markerAssistedSelection,
  genomicSelection,
  doubledHaploid,
}

class BreedingMethodInfo {
  final BreedingMethod id;
  final String name;
  final String summary;
  final List<String> advantages;
  final List<String> limitations;
  final int generationsToStability;
  final double costMultiplier;
  final double speedMultiplier;

  const BreedingMethodInfo({
    required this.id,
    required this.name,
    required this.summary,
    required this.advantages,
    required this.limitations,
    required this.generationsToStability,
    required this.costMultiplier,
    required this.speedMultiplier,
  });
}

enum FieldEventSeverity { low, medium, high }

class FieldEvent {
  final String id;
  final String name;
  final String description;
  final String icon;
  final List<String> favors;
  final FieldEventSeverity severity;

  const FieldEvent({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.favors,
    required this.severity,
  });
}

class Individual {
  final String id;
  final String cropId;
  final int generation;
  final String label;
  final List<String>? parents;
  final Map<String, double> traitValues;
  final Map<String, String> genotype;
  final double heterozygosity;
  final bool selected;

  const Individual({
    required this.id,
    required this.cropId,
    required this.generation,
    required this.label,
    this.parents,
    required this.traitValues,
    required this.genotype,
    required this.heterozygosity,
    required this.selected,
  });

  Individual copyWith({bool? selected, Map<String, double>? traitValues}) {
    return Individual(
      id: id,
      cropId: cropId,
      generation: generation,
      label: label,
      parents: parents,
      traitValues: traitValues ?? this.traitValues,
      genotype: genotype,
      heterozygosity: heterozygosity,
      selected: selected ?? this.selected,
    );
  }
}
