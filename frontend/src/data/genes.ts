export type EditType = "knockout" | "overexpression" | "rnai" | "crispr-edit";

export interface GeneEditOutcome {
  edit: EditType;
  phenotype: string;
  mechanism: string;
  yieldImpact: number; // percent change
}

export interface GeneCard {
  id: string;
  symbol: string;
  name: string;
  chromosome: number;
  position: string;
  cropId: string;
  function: string;
  pathway: string;
  expression: { tissue: string; level: number }[];
  proteinFamily: string;
  normalPhenotype: string;
  editOutcomes: GeneEditOutcome[];
}

export const GENE_CARDS: GeneCard[] = [
  {
    id: "gene-ft",
    symbol: "FT",
    name: "FLOWERING LOCUS T",
    chromosome: 7,
    position: "23.4 Mb",
    cropId: "wheat",
    function: "Mobile florigen signal produced in leaves that moves to the shoot apex to trigger the transition to flowering.",
    pathway: "Photoperiod / Flowering time pathway",
    expression: [
      { tissue: "Leaf (phloem)", level: 0.9 },
      { tissue: "Shoot apex", level: 0.3 },
      { tissue: "Root", level: 0.05 },
    ],
    proteinFamily: "PEBP (phosphatidylethanolamine-binding protein) family",
    normalPhenotype: "Plant flowers on schedule under inductive day length, allowing normal grain fill before season end.",
    editOutcomes: [
      { edit: "knockout", phenotype: "Severe late flowering or non-flowering; vegetative growth continues indefinitely.", mechanism: "Loss of the mobile florigen signal prevents the floral transition at the shoot apex.", yieldImpact: -35 },
      { edit: "overexpression", phenotype: "Extremely early flowering, sometimes before adequate vegetative biomass has formed, reducing yield.", mechanism: "Excess florigen signal triggers premature floral transition.", yieldImpact: -15 },
      { edit: "rnai", phenotype: "Delayed flowering, milder than full knockout, with variable penetrance across plants.", mechanism: "Partial knockdown reduces but does not eliminate FT transcript.", yieldImpact: -12 },
      { edit: "crispr-edit", phenotype: "Fine-tuned flowering time shift (earlier or later) depending on the promoter edit introduced.", mechanism: "Targeted promoter edits change FT expression level without removing the gene.", yieldImpact: 8 },
    ],
  },
  {
    id: "gene-rht",
    symbol: "Rht-B1",
    name: "Reduced height 1",
    chromosome: 4,
    position: "18.9 Mb",
    cropId: "wheat",
    function: "DELLA-domain growth repressor; gain-of-function alleles blunt gibberellin signaling to shorten the stem.",
    pathway: "Gibberellin (GA) signaling pathway",
    expression: [
      { tissue: "Stem internode", level: 0.85 },
      { tissue: "Leaf", level: 0.4 },
      { tissue: "Root", level: 0.2 },
    ],
    proteinFamily: "DELLA / GRAS transcription factor family",
    normalPhenotype: "Tall stem architecture with wild-type gibberellin response.",
    editOutcomes: [
      { edit: "knockout", phenotype: "Semi-dwarf plant with thick, lodging-resistant stems (mimics the Green Revolution Rht alleles).", mechanism: "Loss of gibberellin-signal repression is bypassed by removing the repressor's growth-limiting domain in this allele class.", yieldImpact: 12 },
      { edit: "overexpression", phenotype: "Severe dwarfism and reduced seedling vigor from excess growth repression.", mechanism: "Excess DELLA repressor activity strongly blocks gibberellin-driven cell elongation.", yieldImpact: -20 },
      { edit: "rnai", phenotype: "Mild height reduction with intermediate lodging resistance.", mechanism: "Partial transcript knockdown produces a dosage-dependent semi-dwarf phenotype.", yieldImpact: 5 },
      { edit: "crispr-edit", phenotype: "Precisely tunable height, allowing breeders to target an optimal height for lodging resistance without yield drag.", mechanism: "Targeted editing of the DELLA domain calibrates repression strength.", yieldImpact: 10 },
    ],
  },
  {
    id: "gene-sub1a",
    symbol: "SUB1A",
    name: "Submergence 1A",
    chromosome: 9,
    position: "6.2 Mb",
    cropId: "rice",
    function: "Ethylene-responsive transcription factor that induces quiescence during submergence, conserving energy reserves.",
    pathway: "Ethylene signaling / submergence tolerance pathway",
    expression: [
      { tissue: "Stem base", level: 0.7 },
      { tissue: "Leaf", level: 0.5 },
      { tissue: "Root", level: 0.3 },
    ],
    proteinFamily: "ERF (Ethylene Response Factor) transcription factor family",
    normalPhenotype: "Without functional SUB1A, plants elongate rapidly underwater, exhausting carbohydrate reserves and dying after prolonged submergence.",
    editOutcomes: [
      { edit: "knockout", phenotype: "Loss of submergence tolerance — plants die after more than 3-4 days fully submerged.", mechanism: "Without SUB1A-induced quiescence, plants futilely elongate underwater and exhaust sugar reserves.", yieldImpact: -60 },
      { edit: "overexpression", phenotype: "Enhanced submergence survival but slightly slower recovery growth after floodwaters recede.", mechanism: "Stronger quiescence response conserves more energy but delays post-flood elongation.", yieldImpact: -5 },
      { edit: "rnai", phenotype: "Intermediate submergence tolerance, better than knockout but worse than wild type.", mechanism: "Partial knockdown weakens but does not eliminate the quiescence response.", yieldImpact: -25 },
      { edit: "crispr-edit", phenotype: "Introgression-quality SUB1A activity restored precisely into an elite background (used to create Swarna-Sub1-type varieties).", mechanism: "Precise allele swap installs the functional SUB1A variant.", yieldImpact: 20 },
    ],
  },
  {
    id: "gene-opaque2",
    symbol: "o2 (Opaque2)",
    name: "Opaque2",
    chromosome: 7,
    position: "12.0 Mb",
    cropId: "maize",
    function: "bZIP transcription factor regulating zein storage-protein gene expression in the endosperm.",
    pathway: "Seed storage protein regulation",
    expression: [
      { tissue: "Endosperm", level: 0.95 },
      { tissue: "Leaf", level: 0.05 },
      { tissue: "Root", level: 0.02 },
    ],
    proteinFamily: "bZIP transcription factor family",
    normalPhenotype: "Normal zein-rich, vitreous (hard, translucent) endosperm with lower lysine/tryptophan content.",
    editOutcomes: [
      { edit: "knockout", phenotype: "Soft, opaque (chalky) endosperm with higher lysine and tryptophan content — the basis of Quality Protein Maize (QPM).", mechanism: "Loss of zein activation shifts protein composition toward more balanced, lysine-rich proteins, but softens the kernel.", yieldImpact: -8 },
      { edit: "overexpression", phenotype: "Extremely hard, vitreous kernel with reduced nutritional quality.", mechanism: "Excess zein activation further skews protein composition away from balanced amino acids.", yieldImpact: 2 },
      { edit: "rnai", phenotype: "Partially soft endosperm with moderately improved amino acid balance.", mechanism: "Partial knockdown produces an intermediate opaque phenotype.", yieldImpact: -4 },
      { edit: "crispr-edit", phenotype: "QPM-quality nutrition combined with normal vitreous kernel hardness (modifier genes co-edited).", mechanism: "Precise editing of o2 together with endosperm modifier loci decouples opacity from nutrition gain.", yieldImpact: 6 },
    ],
  },
  {
    id: "gene-tm2",
    symbol: "Tm-2²",
    name: "Tomato mosaic virus resistance 2",
    chromosome: 9,
    position: "56.1 Mb",
    cropId: "tomato",
    function: "CC-NBS-LRR resistance protein that recognizes the ToMV movement protein and triggers a hypersensitive response.",
    pathway: "Plant innate immunity / effector-triggered immunity",
    expression: [
      { tissue: "Leaf", level: 0.6 },
      { tissue: "Stem", level: 0.4 },
      { tissue: "Fruit", level: 0.2 },
    ],
    proteinFamily: "NBS-LRR (nucleotide-binding, leucine-rich repeat) resistance protein family",
    normalPhenotype: "Susceptible plants develop mosaic leaf mottling, stunting, and fruit yield loss after ToMV infection.",
    editOutcomes: [
      { edit: "knockout", phenotype: "Loss of ToMV resistance — full susceptibility to Tobacco Mosaic Virus infection returns.", mechanism: "Without the resistance protein, the viral movement protein is no longer detected and the immune response is not triggered.", yieldImpact: -30 },
      { edit: "overexpression", phenotype: "Stronger, faster hypersensitive response; may cause minor autoimmune leaf lesions without infection.", mechanism: "Excess resistance protein occasionally self-triggers a mild defense response.", yieldImpact: -3 },
      { edit: "rnai", phenotype: "Partial loss of resistance; some plants show mild mosaic symptoms under high viral pressure.", mechanism: "Reduced transcript lowers the threshold for successful viral infection.", yieldImpact: -15 },
      { edit: "crispr-edit", phenotype: "Broadened resistance spectrum to additional ToMV strains.", mechanism: "Targeted edits to the LRR recognition domain change effector specificity.", yieldImpact: 10 },
    ],
  },
  {
    id: "gene-efl",
    symbol: "EFL1",
    name: "Early Flowering 1",
    chromosome: 3,
    position: "9.7 Mb",
    cropId: "chickpea",
    function: "Floral repressor whose reduced activity accelerates the transition to flowering, enabling drought escape.",
    pathway: "Photoperiod-independent flowering time pathway",
    expression: [
      { tissue: "Leaf", level: 0.7 },
      { tissue: "Shoot apex", level: 0.5 },
      { tissue: "Root", level: 0.1 },
    ],
    proteinFamily: "MADS-box transcription factor family",
    normalPhenotype: "Standard flowering time, may face terminal drought stress in short-season dryland environments.",
    editOutcomes: [
      { edit: "knockout", phenotype: "Markedly earlier flowering, allowing the crop to complete its cycle before terminal drought — but with a smaller yield ceiling.", mechanism: "Loss of floral repression accelerates the vegetative-to-reproductive transition.", yieldImpact: -5 },
      { edit: "overexpression", phenotype: "Delayed flowering and increased vegetative biomass, risking terminal drought exposure.", mechanism: "Excess repressor activity prolongs the vegetative phase.", yieldImpact: -18 },
      { edit: "rnai", phenotype: "Moderately early flowering with partial drought escape benefit.", mechanism: "Partial knockdown gives an intermediate flowering-time shift.", yieldImpact: 3 },
      { edit: "crispr-edit", phenotype: "Flowering time precisely tuned to a target maturity window for a specific agro-climatic zone.", mechanism: "Promoter-strength edits allow graded control of repressor dosage.", yieldImpact: 9 },
    ],
  },
];

export const getGenesByCrop = (cropId: string) => GENE_CARDS.filter((g) => g.cropId === cropId);
export const getGene = (id: string) => GENE_CARDS.find((g) => g.id === id)!;

export const EDIT_LABELS: Record<EditType, string> = {
  knockout: "Gene Knockout",
  overexpression: "Overexpression",
  rnai: "RNA Interference (Knockdown)",
  "crispr-edit": "CRISPR Precision Edit",
};
