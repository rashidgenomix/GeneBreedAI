export interface VivaQuestion {
  id: string;
  difficulty: 1 | 2 | 3;
  topic: string;
  question: string;
  options: string[];
  correctIndex: number;
  followUpCorrect: string;
  followUpIncorrect: string;
}

export const VIVA_QUESTIONS: VivaQuestion[] = [
  {
    id: "v1",
    difficulty: 1,
    topic: "Mendelian genetics",
    question: "In a monohybrid cross between two heterozygotes (Aa × Aa), what phenotypic ratio is expected in the offspring?",
    options: ["1:1", "3:1", "9:3:3:1", "1:2:1"],
    correctIndex: 1,
    followUpCorrect: "Good. Now, what genotypic ratio underlies that 3:1 phenotypic ratio?",
    followUpIncorrect: "Reconsider: dominant allele A masks a in both AA and Aa individuals. Count how many of the four combinations show the dominant phenotype.",
  },
  {
    id: "v2",
    difficulty: 1,
    topic: "Breeding methods",
    question: "Which breeding method is specifically designed to transfer a single gene while recovering most of an elite parent's genome?",
    options: ["Bulk breeding", "Backcross breeding", "Mass selection", "Recurrent selection"],
    correctIndex: 1,
    followUpCorrect: "Correct. How many backcross generations are typically needed to recover about 99% of the recurrent parent genome?",
    followUpIncorrect: "Think about which method repeatedly crosses back to one 'recurrent' parent to preserve its genetic background.",
  },
  {
    id: "v3",
    difficulty: 2,
    topic: "Quantitative genetics",
    question: "Broad-sense heritability (H²) is defined as the ratio of which two variance components?",
    options: ["Additive variance / phenotypic variance", "Genotypic variance / phenotypic variance", "Environmental variance / genotypic variance", "Additive variance / genotypic variance"],
    correctIndex: 1,
    followUpCorrect: "Right. Now distinguish this from narrow-sense heritability (h²) — what variance component does it use instead?",
    followUpIncorrect: "Broad-sense heritability captures ALL genetic variance (additive + dominance + epistasis), not just one component.",
  },
  {
    id: "v4",
    difficulty: 2,
    topic: "Molecular breeding",
    question: "Marker-assisted selection is most valuable for traits that are:",
    options: ["Highly heritable and easy to score visually", "Low heritability, expensive, or hard to phenotype", "Only expressed in the F1 generation", "Controlled by cytoplasmic inheritance"],
    correctIndex: 1,
    followUpCorrect: "Exactly — MAS shines when phenotyping is destructive, slow, or unreliable. Can you name a trait like that in your target crop?",
    followUpIncorrect: "If a trait is cheap and easy to score by eye, direct phenotypic selection is usually more cost-effective than MAS.",
  },
  {
    id: "v5",
    difficulty: 3,
    topic: "Genomic selection",
    question: "What is the main reason genomic selection can shorten a breeding cycle compared to conventional phenotypic selection?",
    options: ["It eliminates the need for a training population", "It predicts breeding values from genome-wide markers before phenotypes are measured", "It only works on monogenic traits", "It removes the need for field trials entirely"],
    correctIndex: 1,
    followUpCorrect: "Correct. What happens to genomic prediction accuracy as the training population becomes more distantly related to the selection candidates?",
    followUpIncorrect: "Genomic selection still needs a well-phenotyped training population — its speed advantage comes from predicting untested candidates via genome-wide markers.",
  },
  {
    id: "v6",
    difficulty: 3,
    topic: "QTL / GWAS",
    question: "In a GWAS, a strong marker-trait association could be a false positive mainly due to:",
    options: ["Too few markers used", "Population structure/relatedness confounding the association", "Using a continuous rather than categorical trait", "The crop being self-pollinated"],
    correctIndex: 1,
    followUpCorrect: "Right. What statistical approach is commonly used to correct for population structure in GWAS models?",
    followUpIncorrect: "Population structure (subgroups differing in both allele frequency and trait means) is the classic source of spurious GWAS associations.",
  },
];
