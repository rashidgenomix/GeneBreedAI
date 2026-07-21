import type { Crop, Germplasm, Trait } from "./types";

function commonTraits(overrides?: Partial<Record<string, Partial<Trait>>>): Trait[] {
  const base: Trait[] = [
    { id: "yield", name: "Grain/Fruit Yield", description: "Yield potential under optimal management.", inheritance: "polygenic", unit: "t/ha", loci: 8, direction: "higher-better", minValue: 1, maxValue: 12 },
    { id: "plant_height", name: "Plant Height", description: "Height at maturity; affects lodging risk.", inheritance: "monogenic-dominant", unit: "cm", direction: "target-value", targetValue: 90, minValue: 40, maxValue: 180 },
    { id: "maturity_days", name: "Days to Maturity", description: "Days from sowing/planting to harvest maturity.", inheritance: "polygenic", unit: "days", loci: 5, direction: "lower-better", minValue: 70, maxValue: 160 },
    { id: "disease_resistance", name: "Disease Resistance", description: "Resistance to the crop's major foliar/root disease.", inheritance: "monogenic-dominant", unit: "1-9 score", direction: "higher-better", minValue: 1, maxValue: 9 },
    { id: "drought_tolerance", name: "Drought Tolerance", description: "Ability to maintain yield under water deficit.", inheritance: "polygenic", unit: "1-9 score", loci: 6, direction: "higher-better", minValue: 1, maxValue: 9 },
    { id: "heat_tolerance", name: "Heat Tolerance", description: "Pollen and grain-set stability under heat stress.", inheritance: "polygenic", unit: "1-9 score", loci: 5, direction: "higher-better", minValue: 1, maxValue: 9 },
    { id: "flood_tolerance", name: "Flood/Submergence Tolerance", description: "Survival and recovery after waterlogging or submergence.", inheritance: "monogenic-recessive", unit: "1-9 score", direction: "higher-better", minValue: 1, maxValue: 9 },
    { id: "lodging_resistance", name: "Lodging Resistance", description: "Stem strength and standability near harvest.", inheritance: "polygenic", unit: "1-9 score", loci: 4, direction: "higher-better", minValue: 1, maxValue: 9 },
    { id: "seed_vigor", name: "Seed Vigor", description: "Germination speed and uniformity of emergence.", inheritance: "polygenic", unit: "1-9 score", loci: 3, direction: "higher-better", minValue: 1, maxValue: 9 },
    { id: "quality", name: "Grain/Fruit Quality", description: "Processing and end-use quality traits (protein, taste, fiber, etc).", inheritance: "polygenic", unit: "1-9 score", loci: 6, direction: "higher-better", minValue: 1, maxValue: 9 },
  ];
  if (!overrides) return base;
  return base.map((t) => (overrides[t.id] ? { ...t, ...overrides[t.id] } : t));
}

function g(cropId: Crop["id"], id: string, name: string, origin: string, description: string, traitValues: Record<string, number>, genotype: Record<string, string>, tags: string[] = []): Germplasm {
  return { id, cropId, name, origin, description, traitValues, genotype, tags };
}

export const CROPS: Crop[] = [
  {
    id: "wheat",
    name: "Wheat",
    scientificName: "Triticum aestivum",
    emoji: "🌾",
    description: "A hexaploid staple cereal grown across temperate zones; the world's most widely cultivated crop.",
    chromosomeNumber: 42,
    genomeSizeMb: 14500,
    unlocked: true,
    unlockLevel: 1,
    traits: commonTraits({ disease_resistance: { name: "Rust Resistance", description: "Resistance to stem/leaf/yellow rust (Puccinia spp.)." } }),
    environments: [
      { id: "irrigated-plains", name: "Irrigated Plains", description: "High-input, irrigated lowland wheat belt.", stressors: ["lodging", "disease"] },
      { id: "rainfed-highlands", name: "Rainfed Highlands", description: "Cooler, rainfed, marginal-input environment.", stressors: ["drought", "cold"] },
    ],
    germplasm: [
      g("wheat", "wh-norin10", "Norin 10 Derivative", "Japan", "Carrier of the Rht dwarfing genes that launched the Green Revolution.", { yield: 0.55, plant_height: 0.15, maturity_days: 0.5, disease_resistance: 0.4, drought_tolerance: 0.4, heat_tolerance: 0.4, flood_tolerance: 0.3, lodging_resistance: 0.85, seed_vigor: 0.55, quality: 0.5 }, { "Rht-B1": "rr" }, ["semi-dwarf", "lodging-resistant"]),
      g("wheat", "wh-sonalika", "Sonalika", "India (CIMMYT origin)", "Historic high-yielding, heat-tolerant Green Revolution variety.", { yield: 0.6, plant_height: 0.55, maturity_days: 0.35, disease_resistance: 0.3, drought_tolerance: 0.5, heat_tolerance: 0.75, flood_tolerance: 0.3, lodging_resistance: 0.45, seed_vigor: 0.6, quality: 0.5 }, { "Rht-B1": "Rr" }, ["heat-tolerant", "early-maturing"]),
      g("wheat", "wh-pbw343", "PBW-343", "Punjab, India", "Widely adapted variety, later succeeded due to rust susceptibility.", { yield: 0.7, plant_height: 0.4, maturity_days: 0.55, disease_resistance: 0.25, drought_tolerance: 0.45, heat_tolerance: 0.5, flood_tolerance: 0.35, lodging_resistance: 0.6, seed_vigor: 0.6, quality: 0.6 }, { "Rht-B1": "rr" }, ["high-yield", "rust-susceptible"]),
      g("wheat", "wh-lr34", "Lr34 Donor Line", "CIMMYT", "Carrier of the durable, multi-pathogen adult-plant resistance gene Lr34.", { yield: 0.45, plant_height: 0.6, maturity_days: 0.6, disease_resistance: 0.9, drought_tolerance: 0.45, heat_tolerance: 0.4, flood_tolerance: 0.3, lodging_resistance: 0.5, seed_vigor: 0.5, quality: 0.55 }, { "Rht-B1": "RR", "Lr34": "Rr" }, ["durable-resistance"]),
      g("wheat", "wh-drysdale", "Drysdale", "Australia", "Bred specifically for high water-use efficiency in dry regions.", { yield: 0.5, plant_height: 0.45, maturity_days: 0.4, disease_resistance: 0.4, drought_tolerance: 0.85, heat_tolerance: 0.55, flood_tolerance: 0.2, lodging_resistance: 0.55, seed_vigor: 0.55, quality: 0.55 }, { "Rht-B1": "Rr" }, ["drought-tolerant"]),
      g("wheat", "wh-landrace-local", "Local Landrace", "Farmer-saved seed", "Genetically diverse, low-yielding but broadly resilient farmer variety.", { yield: 0.3, plant_height: 0.7, maturity_days: 0.6, disease_resistance: 0.55, drought_tolerance: 0.6, heat_tolerance: 0.6, flood_tolerance: 0.5, lodging_resistance: 0.35, seed_vigor: 0.65, quality: 0.45 }, { "Rht-B1": "RR" }, ["landrace", "genetically-diverse"]),
    ],
  },
  {
    id: "rice",
    name: "Rice",
    scientificName: "Oryza sativa",
    emoji: "🌾",
    description: "The staple cereal for over half the world's population, grown from flooded lowlands to rainfed uplands.",
    chromosomeNumber: 24,
    genomeSizeMb: 430,
    unlocked: true,
    unlockLevel: 1,
    traits: commonTraits({ disease_resistance: { name: "Blast Resistance", description: "Resistance to rice blast (Magnaporthe oryzae)." } }),
    environments: [
      { id: "irrigated-lowland", name: "Irrigated Lowland", description: "Puddled, transplanted, fully irrigated system.", stressors: ["disease", "lodging"] },
      { id: "rainfed-lowland", name: "Rainfed Lowland", description: "Bunded fields dependent on monsoon rainfall, flood-prone.", stressors: ["flood", "drought"] },
    ],
    germplasm: [
      g("rice", "ri-ir8", "IR8", "IRRI, Philippines", "The original 'Miracle Rice' that anchored the Green Revolution in Asia.", { yield: 0.7, plant_height: 0.2, maturity_days: 0.45, disease_resistance: 0.35, drought_tolerance: 0.3, heat_tolerance: 0.4, flood_tolerance: 0.25, lodging_resistance: 0.8, seed_vigor: 0.55, quality: 0.35 }, { "sd1": "rr" }, ["semi-dwarf", "high-yield"]),
      g("rice", "ri-swarna-sub1", "Swarna-Sub1", "IRRI/India", "Popular mega-variety carrying the SUB1 submergence tolerance gene.", { yield: 0.55, plant_height: 0.5, maturity_days: 0.55, disease_resistance: 0.5, drought_tolerance: 0.4, heat_tolerance: 0.45, flood_tolerance: 0.9, lodging_resistance: 0.55, seed_vigor: 0.5, quality: 0.55 }, { "sd1": "Rr", "SUB1": "Rr" }, ["flood-tolerant"]),
      g("rice", "ri-nerica", "NERICA-4", "AfricaRice", "Interspecific hybrid combining African and Asian rice for upland vigor.", { yield: 0.5, plant_height: 0.55, maturity_days: 0.4, disease_resistance: 0.6, drought_tolerance: 0.7, heat_tolerance: 0.55, flood_tolerance: 0.3, lodging_resistance: 0.5, seed_vigor: 0.65, quality: 0.45 }, { "sd1": "RR" }, ["drought-tolerant", "upland"]),
      g("rice", "ri-basmati370", "Basmati 370", "Punjab", "Premium aromatic long-grain rice prized for cooking quality.", { yield: 0.35, plant_height: 0.65, maturity_days: 0.65, disease_resistance: 0.3, drought_tolerance: 0.35, heat_tolerance: 0.35, flood_tolerance: 0.25, lodging_resistance: 0.3, seed_vigor: 0.45, quality: 0.9 }, { "sd1": "RR", "fgr": "rr" }, ["aromatic", "premium-quality"]),
      g("rice", "ri-pusa-blast-r", "Pusa Blast-R Line", "IARI, India", "Breeding line carrying stacked Pi genes for durable blast resistance.", { yield: 0.55, plant_height: 0.4, maturity_days: 0.5, disease_resistance: 0.9, drought_tolerance: 0.4, heat_tolerance: 0.45, flood_tolerance: 0.3, lodging_resistance: 0.55, seed_vigor: 0.5, quality: 0.55 }, { "sd1": "rr", "Pi9": "Rr" }, ["blast-resistant"]),
      g("rice", "ri-landrace-local", "Local Landrace", "Farmer-saved seed", "Traditional tall variety with broad stress resilience but low yield.", { yield: 0.3, plant_height: 0.8, maturity_days: 0.6, disease_resistance: 0.55, drought_tolerance: 0.55, heat_tolerance: 0.5, flood_tolerance: 0.6, lodging_resistance: 0.3, seed_vigor: 0.6, quality: 0.5 }, { "sd1": "RR" }, ["landrace"]),
    ],
  },
  {
    id: "maize",
    name: "Maize",
    scientificName: "Zea mays",
    emoji: "🌽",
    description: "A cross-pollinated cereal grown worldwide for food, feed, and industrial use; hybrid breeding's flagship crop.",
    chromosomeNumber: 20,
    genomeSizeMb: 2300,
    unlocked: true,
    unlockLevel: 1,
    traits: commonTraits({ disease_resistance: { name: "Leaf Blight Resistance", description: "Resistance to northern/southern corn leaf blight." } }),
    environments: [
      { id: "high-input", name: "High-Input Commercial", description: "Fertile soil, full irrigation, hybrid seed system.", stressors: ["disease", "lodging"] },
      { id: "smallholder-rainfed", name: "Smallholder Rainfed", description: "Low-input, rainfed, open-pollinated varieties common.", stressors: ["drought", "poor-germination"] },
    ],
    germplasm: [
      g("maize", "ma-b73", "B73", "USA (Iowa Stiff Stalk)", "Foundational US inbred line behind countless commercial hybrids.", { yield: 0.6, plant_height: 0.55, maturity_days: 0.5, disease_resistance: 0.45, drought_tolerance: 0.4, heat_tolerance: 0.45, flood_tolerance: 0.3, lodging_resistance: 0.7, seed_vigor: 0.6, quality: 0.5 }, { "opaque2": "RR" }, ["elite-inbred"]),
      g("maize", "ma-mo17", "Mo17", "USA (Lancaster)", "Classic heterotic-group inbred that pairs strongly with B73.", { yield: 0.55, plant_height: 0.5, maturity_days: 0.5, disease_resistance: 0.4, drought_tolerance: 0.45, heat_tolerance: 0.5, flood_tolerance: 0.3, lodging_resistance: 0.65, seed_vigor: 0.55, quality: 0.5 }, { "opaque2": "RR" }, ["elite-inbred"]),
      g("maize", "ma-qpm", "QPM Line (Quality Protein Maize)", "CIMMYT", "Opaque2 mutant background modified for balanced amino-acid nutrition.", { yield: 0.45, plant_height: 0.55, maturity_days: 0.55, disease_resistance: 0.5, drought_tolerance: 0.45, heat_tolerance: 0.45, flood_tolerance: 0.3, lodging_resistance: 0.55, seed_vigor: 0.5, quality: 0.85 }, { "opaque2": "rr" }, ["high-quality-protein"]),
      g("maize", "ma-drought-tego", "Drought Tego Line", "CIMMYT/Africa", "Selected across multiple drought-prone sites for stable grain fill.", { yield: 0.45, plant_height: 0.5, maturity_days: 0.45, disease_resistance: 0.45, drought_tolerance: 0.85, heat_tolerance: 0.6, flood_tolerance: 0.25, lodging_resistance: 0.55, seed_vigor: 0.55, quality: 0.5 }, { "opaque2": "RR" }, ["drought-tolerant"]),
      g("maize", "ma-opv-local", "Local OPV", "Farmer-saved open-pollinated variety", "Open-pollinated landrace grown by smallholders; broadly adapted.", { yield: 0.35, plant_height: 0.65, maturity_days: 0.5, disease_resistance: 0.55, drought_tolerance: 0.55, heat_tolerance: 0.55, flood_tolerance: 0.35, lodging_resistance: 0.4, seed_vigor: 0.6, quality: 0.5 }, { "opaque2": "RR" }, ["open-pollinated", "landrace"]),
      g("maize", "ma-mln-r", "MLN-Resistant Line", "KALRO/CIMMYT", "Carries resistance to Maize Lethal Necrosis disease complex.", { yield: 0.45, plant_height: 0.5, maturity_days: 0.5, disease_resistance: 0.9, drought_tolerance: 0.4, heat_tolerance: 0.5, flood_tolerance: 0.3, lodging_resistance: 0.55, seed_vigor: 0.5, quality: 0.5 }, { "opaque2": "RR" }, ["disease-resistant"]),
    ],
  },
  {
    id: "cotton",
    name: "Cotton",
    scientificName: "Gossypium hirsutum",
    emoji: "🌱",
    description: "The world's leading natural fiber crop, an allotetraploid with a complex breeding history.",
    chromosomeNumber: 52,
    genomeSizeMb: 2500,
    unlocked: true,
    unlockLevel: 2,
    traits: commonTraits({ disease_resistance: { name: "Bollworm/Wilt Resistance", description: "Resistance to bollworm complex and fusarium wilt." }, quality: { name: "Fiber Quality", description: "Staple length, strength, and micronaire of the lint." } }),
    environments: [
      { id: "irrigated-belt", name: "Irrigated Cotton Belt", description: "Intensive irrigated production with heavy pest pressure.", stressors: ["disease", "heat"] },
      { id: "rainfed-marginal", name: "Rainfed Marginal Lands", description: "Low-input rainfed cotton on marginal soils.", stressors: ["drought", "poor-germination"] },
    ],
    germplasm: [
      g("cotton", "co-bt-line", "Bt Insertion Line", "Public breeding program", "Carries a Bt transgene conferring resistance to lepidopteran bollworms.", { yield: 0.6, plant_height: 0.5, maturity_days: 0.5, disease_resistance: 0.85, drought_tolerance: 0.4, heat_tolerance: 0.5, flood_tolerance: 0.3, lodging_resistance: 0.5, seed_vigor: 0.5, quality: 0.55 }, { "Bt-Cry1Ac": "Rr" }, ["Bt", "insect-resistant"]),
      g("cotton", "co-desi-diploid", "Desi Diploid Type", "South Asia (G. arboreum)", "Hardy diploid cotton, tolerant of heat and poor soils but low fiber quality.", { yield: 0.35, plant_height: 0.55, maturity_days: 0.45, disease_resistance: 0.55, drought_tolerance: 0.75, heat_tolerance: 0.8, flood_tolerance: 0.3, lodging_resistance: 0.5, seed_vigor: 0.55, quality: 0.3 }, { "Bt-Cry1Ac": "rr" }, ["heat-tolerant", "diploid"]),
      g("cotton", "co-longstaple", "Extra-Long-Staple Line", "Egypt/USA (Pima)", "Premium long, strong fiber for high-end textiles.", { yield: 0.4, plant_height: 0.55, maturity_days: 0.6, disease_resistance: 0.45, drought_tolerance: 0.4, heat_tolerance: 0.5, flood_tolerance: 0.25, lodging_resistance: 0.5, seed_vigor: 0.45, quality: 0.9 }, { "Bt-Cry1Ac": "rr" }, ["premium-fiber"]),
      g("cotton", "co-wilt-r", "Fusarium Wilt Resistant Line", "Public breeding program", "Selected for stable stands in wilt-infested fields.", { yield: 0.45, plant_height: 0.5, maturity_days: 0.5, disease_resistance: 0.8, drought_tolerance: 0.5, heat_tolerance: 0.5, flood_tolerance: 0.3, lodging_resistance: 0.5, seed_vigor: 0.55, quality: 0.5 }, { "Bt-Cry1Ac": "rr", "Fov-R": "Rr" }, ["wilt-resistant"]),
      g("cotton", "co-elite-hybrid-parent", "Elite Hybrid Parent A", "Commercial breeding program", "One parent of a widely grown commercial F1 hybrid.", { yield: 0.65, plant_height: 0.5, maturity_days: 0.45, disease_resistance: 0.55, drought_tolerance: 0.45, heat_tolerance: 0.5, flood_tolerance: 0.3, lodging_resistance: 0.55, seed_vigor: 0.6, quality: 0.6 }, { "Bt-Cry1Ac": "RR" }, ["hybrid-parent"]),
      g("cotton", "co-landrace-local", "Local Landrace", "Farmer-saved seed", "Traditional variety, genetically diverse and locally adapted.", { yield: 0.3, plant_height: 0.6, maturity_days: 0.5, disease_resistance: 0.5, drought_tolerance: 0.55, heat_tolerance: 0.55, flood_tolerance: 0.35, lodging_resistance: 0.45, seed_vigor: 0.55, quality: 0.4 }, { "Bt-Cry1Ac": "rr" }, ["landrace"]),
    ],
  },
  {
    id: "tomato",
    name: "Tomato",
    scientificName: "Solanum lycopersicum",
    emoji: "🍅",
    description: "A model diploid horticultural crop widely used to teach genetics due to its simple Mendelian traits.",
    chromosomeNumber: 24,
    genomeSizeMb: 900,
    unlocked: true,
    unlockLevel: 1,
    traits: commonTraits({ disease_resistance: { name: "Fusarium/TYLCV Resistance", description: "Resistance to fusarium wilt and tomato yellow leaf curl virus." }, quality: { name: "Fruit Quality", description: "Brix (sweetness), firmness, and shelf life." } }),
    environments: [
      { id: "greenhouse", name: "Protected Greenhouse", description: "Controlled climate, high management intensity.", stressors: ["disease"] },
      { id: "open-field", name: "Open Field", description: "Field production exposed to weather and pest pressure.", stressors: ["heat", "disease", "flood"] },
    ],
    germplasm: [
      g("tomato", "to-moneymaker", "Moneymaker", "Europe", "Classic heirloom-like reference variety used widely in teaching.", { yield: 0.5, plant_height: 0.6, maturity_days: 0.5, disease_resistance: 0.3, drought_tolerance: 0.4, heat_tolerance: 0.4, flood_tolerance: 0.3, lodging_resistance: 0.4, seed_vigor: 0.55, quality: 0.55 }, { "rin": "RR", "Tm-2": "rr" }, ["reference-variety"]),
      g("tomato", "to-rin-mutant", "rin Mutant Line", "Breeding stock", "Carries the ripening-inhibitor (rin) mutation extending shelf life.", { yield: 0.4, plant_height: 0.55, maturity_days: 0.55, disease_resistance: 0.4, drought_tolerance: 0.4, heat_tolerance: 0.4, flood_tolerance: 0.3, lodging_resistance: 0.4, seed_vigor: 0.5, quality: 0.7 }, { "rin": "rr", "Tm-2": "rr" }, ["long-shelf-life"]),
      g("tomato", "to-tm2-line", "Tm-2² Resistant Line", "Breeding stock", "Carries the Tm-2² gene for resistance to Tobacco Mosaic Virus.", { yield: 0.45, plant_height: 0.55, maturity_days: 0.5, disease_resistance: 0.85, drought_tolerance: 0.4, heat_tolerance: 0.45, flood_tolerance: 0.3, lodging_resistance: 0.45, seed_vigor: 0.5, quality: 0.55 }, { "rin": "RR", "Tm-2": "Rr" }, ["virus-resistant"]),
      g("tomato", "to-heat-set", "Heat-Set Line", "Breeding stock (tropics)", "Selected for reliable fruit set under high night temperatures.", { yield: 0.4, plant_height: 0.5, maturity_days: 0.45, disease_resistance: 0.4, drought_tolerance: 0.45, heat_tolerance: 0.85, flood_tolerance: 0.3, lodging_resistance: 0.4, seed_vigor: 0.5, quality: 0.5 }, { "rin": "RR", "Tm-2": "rr" }, ["heat-tolerant"]),
      g("tomato", "to-cherry-wild", "Wild Cherry Relative (S. pimpinellifolium)", "Wild relative", "Wild relative rich in disease resistance and quality alleles, low yield.", { yield: 0.25, plant_height: 0.7, maturity_days: 0.6, disease_resistance: 0.75, drought_tolerance: 0.6, heat_tolerance: 0.55, flood_tolerance: 0.4, lodging_resistance: 0.35, seed_vigor: 0.6, quality: 0.65 }, { "rin": "RR", "Tm-2": "rr" }, ["wild-relative", "genetically-diverse"]),
      g("tomato", "to-processing", "Processing Type Line", "Commercial breeding program", "Bred for machine harvest and paste quality, high solids content.", { yield: 0.65, plant_height: 0.4, maturity_days: 0.5, disease_resistance: 0.5, drought_tolerance: 0.45, heat_tolerance: 0.5, flood_tolerance: 0.3, lodging_resistance: 0.6, seed_vigor: 0.55, quality: 0.6 }, { "rin": "Rr", "Tm-2": "rr" }, ["processing-type"]),
    ],
  },
  {
    id: "chickpea",
    name: "Chickpea",
    scientificName: "Cicer arietinum",
    emoji: "🫘",
    description: "A self-pollinated grain legume vital for protein security in dryland cropping systems.",
    chromosomeNumber: 16,
    genomeSizeMb: 740,
    unlocked: true,
    unlockLevel: 2,
    traits: commonTraits({ disease_resistance: { name: "Ascochyta Blight / Wilt Resistance", description: "Resistance to Ascochyta blight and Fusarium wilt." } }),
    environments: [
      { id: "dryland", name: "Dryland Rabi Season", description: "Post-monsoon residual-moisture cropping, terminal drought common.", stressors: ["drought", "heat"] },
      { id: "irrigated-legume", name: "Irrigated Rotation", description: "Irrigated legume phase in a cereal-legume rotation.", stressors: ["disease", "flood"] },
    ],
    germplasm: [
      g("chickpea", "ch-jg11", "JG-11", "ICRISAT/India", "Widely grown desi-type variety with broad adaptation.", { yield: 0.55, plant_height: 0.45, maturity_days: 0.45, disease_resistance: 0.45, drought_tolerance: 0.55, heat_tolerance: 0.5, flood_tolerance: 0.3, lodging_resistance: 0.5, seed_vigor: 0.55, quality: 0.5 }, { "efl": "RR" }, ["desi-type", "widely-adapted"]),
      g("chickpea", "ch-icc4958", "ICC 4958", "ICRISAT", "Reference drought-tolerant accession with a deep, vigorous root system.", { yield: 0.45, plant_height: 0.4, maturity_days: 0.4, disease_resistance: 0.45, drought_tolerance: 0.9, heat_tolerance: 0.55, flood_tolerance: 0.25, lodging_resistance: 0.5, seed_vigor: 0.55, quality: 0.5 }, { "efl": "RR" }, ["drought-tolerant", "deep-rooted"]),
      g("chickpea", "ch-kabuli-elite", "Kabuli Elite Line", "Mediterranean breeding program", "Large-seeded kabuli type for premium export markets.", { yield: 0.5, plant_height: 0.5, maturity_days: 0.55, disease_resistance: 0.4, drought_tolerance: 0.45, heat_tolerance: 0.4, flood_tolerance: 0.25, lodging_resistance: 0.45, seed_vigor: 0.5, quality: 0.8 }, { "efl": "rr" }, ["kabuli-type", "large-seed"]),
      g("chickpea", "ch-wilt-r", "Fusarium Wilt Resistant Line", "ICRISAT", "Carries multiple race-specific resistance genes against Fusarium wilt.", { yield: 0.45, plant_height: 0.45, maturity_days: 0.45, disease_resistance: 0.85, drought_tolerance: 0.5, heat_tolerance: 0.45, flood_tolerance: 0.3, lodging_resistance: 0.5, seed_vigor: 0.5, quality: 0.5 }, { "efl": "RR", "Foc-R": "Rr" }, ["wilt-resistant"]),
      g("chickpea", "ch-early-flowering", "Early-Flowering Line", "ICRISAT", "Carries an early-flowering (efl) allele allowing terminal drought escape.", { yield: 0.4, plant_height: 0.35, maturity_days: 0.25, disease_resistance: 0.4, drought_tolerance: 0.6, heat_tolerance: 0.55, flood_tolerance: 0.25, lodging_resistance: 0.45, seed_vigor: 0.5, quality: 0.5 }, { "efl": "rr" }, ["early-maturing", "drought-escape"]),
      g("chickpea", "ch-landrace-local", "Local Landrace", "Farmer-saved seed", "Traditional variety with broad but modest resilience across stresses.", { yield: 0.3, plant_height: 0.55, maturity_days: 0.5, disease_resistance: 0.5, drought_tolerance: 0.55, heat_tolerance: 0.5, flood_tolerance: 0.35, lodging_resistance: 0.4, seed_vigor: 0.55, quality: 0.5 }, { "efl": "RR" }, ["landrace"]),
    ],
  },
];

export const getCrop = (id: string) => CROPS.find((c) => c.id === id)!;
