export interface Clue {
  tool: string;
  icon: string;
  text: string;
}

export interface DetectiveCase {
  id: string;
  title: string;
  cropId: string;
  symptoms: string[];
  clues: Clue[];
  culpritGene: string;
  correctHypothesis: string;
  distractors: string[];
  explanation: string;
}

export const DETECTIVE_CASES: DetectiveCase[] = [
  {
    id: "case-purple-dwarf",
    title: "The Purple Dwarf Mystery",
    cropId: "maize",
    symptoms: ["Severely reduced plant height", "Purple pigmentation in leaves and stem", "Delayed flowering by ~10 days"],
    clues: [
      { tool: "Microscope", icon: "Microscope", text: "Leaf cross-sections show normal cell structure — no pathogen bodies visible." },
      { tool: "Pedigree", icon: "GitBranch", text: "Trait segregates 3:1 (normal:mutant) in an F2 population — consistent with a single recessive gene." },
      { tool: "Gene expression", icon: "Activity", text: "Anthocyanin biosynthesis genes are strongly upregulated in mutant tissue." },
      { tool: "Marker analysis", icon: "MapPin", text: "The mutant phenotype co-segregates with a marker near a known gibberellin-pathway gene." },
      { tool: "PCR", icon: "TestTube", text: "PCR amplification confirms a small deletion disrupting a GA-biosynthesis gene coding region." },
    ],
    culpritGene: "A gibberellin (GA) biosynthesis gene",
    correctHypothesis: "A recessive mutation disrupts gibberellin biosynthesis, causing dwarfism, delayed flowering, and stress-induced anthocyanin (purple pigment) accumulation as a secondary effect.",
    distractors: [
      "A dominant disease-resistance gene has been activated, causing a hypersensitive purple response.",
      "The plant is infected by a purple-pigment-producing fungal pathogen.",
      "A photoperiod gene mutation is directly causing purple pigmentation.",
    ],
    explanation: "GA-deficient dwarfs commonly accumulate anthocyanins because blocked growth diverts sugars into secondary metabolism (anthocyanin pathway), and GA deficiency independently delays the floral transition. The 3:1 segregation and marker linkage point to a single recessive GA-pathway gene, not a pathogen or a directly pigment-controlling gene.",
  },
  {
    id: "case-late-bloomer",
    title: "The Late Bloomer Case",
    cropId: "rice",
    symptoms: ["Flowering delayed by 3 weeks under short-day conditions", "Excessive vegetative biomass", "Reduced grain yield due to short grain-fill window before season end"],
    clues: [
      { tool: "Phenotyping", icon: "Ruler", text: "Plant height and tiller number are both above average — vegetative growth is enhanced, not suppressed." },
      { tool: "Gene expression", icon: "Activity", text: "A known floral-promoting mobile signal gene shows sharply reduced expression in leaf tissue." },
      { tool: "Pedigree", icon: "GitBranch", text: "The late-flowering trait breeds true and segregates as a single recessive locus." },
      { tool: "DNA sequencing", icon: "Dna", text: "Sequencing reveals a premature stop codon early in the coding sequence of the floral-signal gene." },
    ],
    culpritGene: "A florigen (FT-like) gene",
    correctHypothesis: "A loss-of-function mutation in a mobile florigen (FT-like) gene delays the floral transition, prolonging vegetative growth and shrinking the grain-fill window.",
    distractors: [
      "A root-development gene mutation is indirectly delaying flowering by limiting water uptake.",
      "The plants are suffering from nitrogen deficiency, which delays flowering in all crops.",
      "A dominant gene actively represses flowering only in this population.",
    ],
    explanation: "The premature stop codon in the florigen-coding gene, combined with reduced transcript levels and a recessive 1-locus inheritance pattern, points directly to loss of the mobile flowering signal — not an environmental or root-related cause.",
  },
];

export const getDetectiveCase = (id: string) => DETECTIVE_CASES.find((c) => c.id === id)!;
