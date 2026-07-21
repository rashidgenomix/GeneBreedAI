import type { Crop, Germplasm, Individual, Trait } from "../data/types";

// A small, teachable genetics engine. It is intentionally simplified (this is a
// learning simulation, not a production quantitative-genetics package) but it
// respects two real inheritance mechanisms so outcomes are pedagogically sound:
//
//  1. Monogenic traits segregate as single Mendelian loci (dominant/recessive).
//  2. Polygenic traits are modeled as the additive average of "parental breeding
//     values" plus environmental noise, mimicking quantitative trait inheritance.

let idCounter = 0;
function nextId(prefix: string) {
  idCounter += 1;
  return `${prefix}-${Date.now().toString(36)}-${idCounter}`;
}

function mulberry32(seed: number) {
  let a = seed;
  return function () {
    a |= 0;
    a = (a + 0x6d2b79f5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

export function makeRng(seed?: number) {
  return seed !== undefined ? mulberry32(seed) : Math.random;
}

function germplasmToIndividual(g: Germplasm, cropId: Crop["id"]): Individual {
  return {
    id: nextId("ind"),
    cropId,
    generation: 0,
    label: g.name,
    parents: null,
    traitValues: { ...g.traitValues },
    genotype: { ...g.genotype },
    heterozygosity: 0,
    selected: true,
  };
}

/** Combine one Mendelian allele pair from each parent's genotype string (e.g. "Rr" x "rr"). */
function segregateLocus(parentA: string, parentB: string, rng: () => number): string {
  const alleleA = parentA[Math.floor(rng() * parentA.length)];
  const alleleB = parentB[Math.floor(rng() * parentB.length)];
  const pair = [alleleA, alleleB].sort((a, b) => {
    // Uppercase (dominant) sorts first for a canonical genotype string like "Rr".
    const aUpper = a === a.toUpperCase();
    const bUpper = b === b.toUpperCase();
    if (aUpper === bUpper) return a.localeCompare(b);
    return aUpper ? -1 : 1;
  });
  return pair.join("");
}

function phenotypeFromGenotype(trait: Trait, genotype: string): number {
  // Dominant traits: any dominant allele expresses the "high" phenotype value (0.85);
  // fully recessive homozygote expresses the "low" phenotype value (0.25).
  const isHeterozygousOrDominantHomo = /[A-Z]/.test(genotype);
  if (trait.inheritance === "monogenic-dominant") {
    return isHeterozygousOrDominantHomo ? 0.85 : 0.25;
  }
  if (trait.inheritance === "monogenic-recessive") {
    // Recessive homozygote expresses the favorable trait (e.g. flood tolerance sub1 introgression modeled recessive).
    return isHeterozygousOrDominantHomo ? 0.35 : 0.85;
  }
  return 0.5;
}

/** Produce a single offspring individual from two parents. */
export function cross(parentA: Individual, parentB: Individual, crop: Crop, generation: number, rng: () => number): Individual {
  const traitValues: Record<string, number> = {};
  const genotype: Record<string, string> = {};
  let hetLoci = 0;
  let totalLoci = 0;

  const allLocusKeys = new Set([...Object.keys(parentA.genotype), ...Object.keys(parentB.genotype)]);
  for (const locus of allLocusKeys) {
    const gA = parentA.genotype[locus] ?? "RR";
    const gB = parentB.genotype[locus] ?? "RR";
    const childGenotype = segregateLocus(gA, gB, rng);
    genotype[locus] = childGenotype;
    totalLoci += 1;
    if (childGenotype[0] !== childGenotype[1]) hetLoci += 1;
  }

  for (const trait of crop.traits) {
    if (trait.inheritance === "polygenic") {
      // Additive polygenic model: offspring breeding value = midparent + Mendelian sampling noise.
      const midParent = ((parentA.traitValues[trait.id] ?? 0.5) + (parentB.traitValues[trait.id] ?? 0.5)) / 2;
      const samplingNoise = (rng() - 0.5) * 0.18; // Mendelian sampling variance
      traitValues[trait.id] = clamp01(midParent + samplingNoise);
    } else {
      // Monogenic: phenotype is derived from the segregated genotype at the trait's linked locus.
      const linkedLocus = Object.keys(genotype).find((l) => l.toLowerCase().includes(trait.id.split("_")[0].slice(0, 3))) ?? Object.keys(genotype)[0];
      const genoStr = linkedLocus ? genotype[linkedLocus] : "Rr";
      traitValues[trait.id] = phenotypeFromGenotype(trait, genoStr);
    }
  }

  return {
    id: nextId("ind"),
    cropId: crop.id,
    generation,
    label: `${generation === 1 ? "F1" : `F${generation}`} (${parentA.label.slice(0, 8)} × ${parentB.label.slice(0, 8)})`,
    parents: [parentA.id, parentB.id],
    traitValues,
    genotype,
    heterozygosity: totalLoci > 0 ? hetLoci / totalLoci : 0,
    selected: false,
  };
}

/** Generate an F1 population (default 12 individuals) from two chosen parent germplasm. */
export function hybridize(parentAG: Germplasm, parentBG: Germplasm, crop: Crop, rng: () => number, populationSize = 12): { parents: [Individual, Individual]; f1: Individual[] } {
  const parentA = germplasmToIndividual(parentAG, crop.id);
  const parentB = germplasmToIndividual(parentBG, crop.id);
  const f1 = Array.from({ length: populationSize }, () => cross(parentA, parentB, crop, 1, rng));
  return { parents: [parentA, parentB], f1 };
}

/** Advance a generation via random mating / selfing within the selected subset of the previous generation. */
export function advanceGeneration(previousGeneration: Individual[], crop: Crop, generation: number, rng: () => number, populationSize = 12): Individual[] {
  const pool = previousGeneration.filter((i) => i.selected);
  const breedingPool = pool.length >= 2 ? pool : previousGeneration;
  const next: Individual[] = [];
  for (let i = 0; i < populationSize; i++) {
    const a = breedingPool[Math.floor(rng() * breedingPool.length)];
    let b = breedingPool[Math.floor(rng() * breedingPool.length)];
    if (breedingPool.length > 1) {
      let guard = 0;
      while (b.id === a.id && guard < 10) {
        b = breedingPool[Math.floor(rng() * breedingPool.length)];
        guard += 1;
      }
    }
    next.push(cross(a, b, crop, generation, rng));
  }
  return next;
}

function clamp01(v: number) {
  return Math.max(0, Math.min(1, v));
}

/** Score an individual 0-100 against a crop's traits, used for selection index & release scoring. */
export function scoreIndividual(ind: Individual, crop: Crop, weights?: Partial<Record<string, number>>): number {
  let total = 0;
  let weightSum = 0;
  for (const trait of crop.traits) {
    const w = weights?.[trait.id] ?? 1;
    const raw = ind.traitValues[trait.id] ?? 0.5;
    const normalized = trait.direction === "lower-better" ? 1 - raw : raw;
    total += normalized * w;
    weightSum += w;
  }
  return weightSum > 0 ? Math.round((total / weightSum) * 100) : 0;
}

/** Convert a normalized 0-1 trait value into a human-readable display value for a trait's unit range. */
export function displayTraitValue(trait: Trait, normalized: number): string {
  const value = trait.minValue + normalized * (trait.maxValue - trait.minValue);
  return `${value.toFixed(trait.maxValue - trait.minValue > 20 ? 0 : 1)} ${trait.unit}`;
}

/** Apply a field-event's selection pressure: individuals lacking the favored trait(s) take a survival/score penalty. */
export function applyFieldEventPressure(population: Individual[], favoredTraitIds: string[], severity: "low" | "medium" | "high", rng: () => number): Individual[] {
  const severityPenalty = { low: 0.08, medium: 0.16, high: 0.28 }[severity];
  if (favoredTraitIds.length === 0) return population;
  return population.map((ind) => {
    const avgFavored = favoredTraitIds.reduce((s, t) => s + (ind.traitValues[t] ?? 0.5), 0) / favoredTraitIds.length;
    const survivalPenalty = (1 - avgFavored) * severityPenalty * (0.7 + rng() * 0.6);
    const adjusted: Record<string, number> = { ...ind.traitValues };
    adjusted.yield = clamp01((adjusted.yield ?? 0.5) - survivalPenalty);
    return { ...ind, traitValues: adjusted };
  });
}
