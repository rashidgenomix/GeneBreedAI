// Core domain types shared across GeneBreed AI modules.

export type CropId = "wheat" | "rice" | "maize" | "cotton" | "tomato" | "chickpea";

export type TraitInheritance = "monogenic-dominant" | "monogenic-recessive" | "polygenic";

/** A single trait tracked on a crop, e.g. plant height or disease resistance. */
export interface Trait {
  id: string;
  name: string;
  description: string;
  inheritance: TraitInheritance;
  /** Unit shown in UI, e.g. "cm", "days", "t/ha", "1-9 score". */
  unit: string;
  /** For polygenic traits: how many loci contribute (used by the simulation engine). */
  loci?: number;
  /** Higher-is-better vs lower-is-better, used for selection scoring. */
  direction: "higher-better" | "lower-better" | "target-value";
  targetValue?: number;
  minValue: number;
  maxValue: number;
}

/** A founder / parent germplasm accession available for crossing. */
export interface Germplasm {
  id: string;
  cropId: CropId;
  name: string;
  origin: string;
  description: string;
  /** Genetic values per trait id, expressed as a 0-1 breeding value plus phenotype. */
  traitValues: Record<string, number>;
  /** Genotype at monogenic loci, e.g. { "Rht-B1": "Rr" }. */
  genotype: Record<string, string>;
  tags: string[];
}

export interface Crop {
  id: CropId;
  name: string;
  scientificName: string;
  emoji: string;
  description: string;
  chromosomeNumber: number;
  genomeSizeMb: number;
  traits: Trait[];
  germplasm: Germplasm[];
  environments: Environment[];
  unlocked: boolean;
  unlockLevel: number;
}

export interface Environment {
  id: string;
  name: string;
  description: string;
  stressors: string[];
}

export type BreedingMethod =
  | "pedigree"
  | "bulk"
  | "backcross"
  | "single-seed-descent"
  | "recurrent-selection"
  | "mass-selection"
  | "hybrid"
  | "marker-assisted-selection"
  | "genomic-selection"
  | "double-haploid";

export interface BreedingMethodInfo {
  id: BreedingMethod;
  name: string;
  summary: string;
  advantages: string[];
  limitations: string[];
  generationsToStability: number;
  costMultiplier: number;
  speedMultiplier: number;
}

export type FieldEventId =
  | "disease-outbreak"
  | "heat-stress"
  | "drought"
  | "flood"
  | "lodging"
  | "poor-germination"
  | "mutation"
  | "seed-contamination"
  | "market-shift"
  | "budget-cut";

export interface FieldEvent {
  id: FieldEventId;
  name: string;
  description: string;
  icon: string;
  /** Trait ids favored by surviving this event (selection pressure). */
  favors: string[];
  severity: "low" | "medium" | "high";
}

export interface Individual {
  id: string;
  cropId: CropId;
  generation: number;
  label: string;
  parents: [string, string] | null;
  traitValues: Record<string, number>;
  genotype: Record<string, string>;
  heterozygosity: number;
  selected: boolean;
}

export interface BreedingProgram {
  id: string;
  cropId: CropId;
  method: BreedingMethod;
  name: string;
  createdAt: number;
  parentIds: [string, string];
  generations: Individual[][];
  currentGeneration: number;
  fieldEventLog: { generation: number; event: FieldEventId; decision: string }[];
  released: boolean;
  releasedVarietyName?: string;
  score: number;
}
