enum EditType { knockout, overexpression, rnai, crisprEdit }

const Map<EditType, String> editLabels = {
  EditType.knockout: 'Gene Knockout',
  EditType.overexpression: 'Overexpression',
  EditType.rnai: 'RNA Interference (Knockdown)',
  EditType.crisprEdit: 'CRISPR Precision Edit',
};

class GeneEditOutcome {
  final EditType edit;
  final String phenotype;
  final String mechanism;
  final int yieldImpact;
  const GeneEditOutcome({required this.edit, required this.phenotype, required this.mechanism, required this.yieldImpact});
}

class ExpressionLevel {
  final String tissue;
  final double level;
  const ExpressionLevel(this.tissue, this.level);
}

class GeneCard {
  final String id;
  final String symbol;
  final String name;
  final int chromosome;
  final String position;
  final String cropId;
  final String function;
  final String pathway;
  final List<ExpressionLevel> expression;
  final String proteinFamily;
  final String normalPhenotype;
  final List<GeneEditOutcome> editOutcomes;

  const GeneCard({
    required this.id,
    required this.symbol,
    required this.name,
    required this.chromosome,
    required this.position,
    required this.cropId,
    required this.function,
    required this.pathway,
    required this.expression,
    required this.proteinFamily,
    required this.normalPhenotype,
    required this.editOutcomes,
  });
}

const List<GeneCard> geneCards = [
  GeneCard(
    id: 'gene-ft',
    symbol: 'FT',
    name: 'FLOWERING LOCUS T',
    chromosome: 7,
    position: '23.4 Mb',
    cropId: 'wheat',
    function: 'Mobile florigen signal produced in leaves that moves to the shoot apex to trigger the transition to flowering.',
    pathway: 'Photoperiod / Flowering time pathway',
    expression: [ExpressionLevel('Leaf (phloem)', 0.9), ExpressionLevel('Shoot apex', 0.3), ExpressionLevel('Root', 0.05)],
    proteinFamily: 'PEBP (phosphatidylethanolamine-binding protein) family',
    normalPhenotype: 'Plant flowers on schedule under inductive day length, allowing normal grain fill before season end.',
    editOutcomes: [
      GeneEditOutcome(edit: EditType.knockout, phenotype: 'Severe late flowering or non-flowering; vegetative growth continues indefinitely.', mechanism: 'Loss of the mobile florigen signal prevents the floral transition at the shoot apex.', yieldImpact: -35),
      GeneEditOutcome(edit: EditType.overexpression, phenotype: 'Extremely early flowering, sometimes before adequate vegetative biomass has formed, reducing yield.', mechanism: 'Excess florigen signal triggers premature floral transition.', yieldImpact: -15),
      GeneEditOutcome(edit: EditType.rnai, phenotype: 'Delayed flowering, milder than full knockout, with variable penetrance across plants.', mechanism: 'Partial knockdown reduces but does not eliminate FT transcript.', yieldImpact: -12),
      GeneEditOutcome(edit: EditType.crisprEdit, phenotype: 'Fine-tuned flowering time shift (earlier or later) depending on the promoter edit introduced.', mechanism: 'Targeted promoter edits change FT expression level without removing the gene.', yieldImpact: 8),
    ],
  ),
  GeneCard(
    id: 'gene-rht',
    symbol: 'Rht-B1',
    name: 'Reduced height 1',
    chromosome: 4,
    position: '18.9 Mb',
    cropId: 'wheat',
    function: 'DELLA-domain growth repressor; gain-of-function alleles blunt gibberellin signaling to shorten the stem.',
    pathway: 'Gibberellin (GA) signaling pathway',
    expression: [ExpressionLevel('Stem internode', 0.85), ExpressionLevel('Leaf', 0.4), ExpressionLevel('Root', 0.2)],
    proteinFamily: 'DELLA / GRAS transcription factor family',
    normalPhenotype: 'Tall stem architecture with wild-type gibberellin response.',
    editOutcomes: [
      GeneEditOutcome(edit: EditType.knockout, phenotype: 'Semi-dwarf plant with thick, lodging-resistant stems (mimics the Green Revolution Rht alleles).', mechanism: "Loss of gibberellin-signal repression is bypassed by removing the repressor's growth-limiting domain in this allele class.", yieldImpact: 12),
      GeneEditOutcome(edit: EditType.overexpression, phenotype: 'Severe dwarfism and reduced seedling vigor from excess growth repression.', mechanism: 'Excess DELLA repressor activity strongly blocks gibberellin-driven cell elongation.', yieldImpact: -20),
      GeneEditOutcome(edit: EditType.rnai, phenotype: 'Mild height reduction with intermediate lodging resistance.', mechanism: 'Partial transcript knockdown produces a dosage-dependent semi-dwarf phenotype.', yieldImpact: 5),
      GeneEditOutcome(edit: EditType.crisprEdit, phenotype: 'Precisely tunable height, allowing breeders to target an optimal height for lodging resistance without yield drag.', mechanism: 'Targeted editing of the DELLA domain calibrates repression strength.', yieldImpact: 10),
    ],
  ),
  GeneCard(
    id: 'gene-sub1a',
    symbol: 'SUB1A',
    name: 'Submergence 1A',
    chromosome: 9,
    position: '6.2 Mb',
    cropId: 'rice',
    function: 'Ethylene-responsive transcription factor that induces quiescence during submergence, conserving energy reserves.',
    pathway: 'Ethylene signaling / submergence tolerance pathway',
    expression: [ExpressionLevel('Stem base', 0.7), ExpressionLevel('Leaf', 0.5), ExpressionLevel('Root', 0.3)],
    proteinFamily: 'ERF (Ethylene Response Factor) transcription factor family',
    normalPhenotype: 'Without functional SUB1A, plants elongate rapidly underwater, exhausting carbohydrate reserves and dying after prolonged submergence.',
    editOutcomes: [
      GeneEditOutcome(edit: EditType.knockout, phenotype: 'Loss of submergence tolerance — plants die after more than 3-4 days fully submerged.', mechanism: 'Without SUB1A-induced quiescence, plants futilely elongate underwater and exhaust sugar reserves.', yieldImpact: -60),
      GeneEditOutcome(edit: EditType.overexpression, phenotype: 'Enhanced submergence survival but slightly slower recovery growth after floodwaters recede.', mechanism: 'Stronger quiescence response conserves more energy but delays post-flood elongation.', yieldImpact: -5),
      GeneEditOutcome(edit: EditType.rnai, phenotype: 'Intermediate submergence tolerance, better than knockout but worse than wild type.', mechanism: 'Partial knockdown weakens but does not eliminate the quiescence response.', yieldImpact: -25),
      GeneEditOutcome(edit: EditType.crisprEdit, phenotype: 'Introgression-quality SUB1A activity restored precisely into an elite background (used to create Swarna-Sub1-type varieties).', mechanism: 'Precise allele swap installs the functional SUB1A variant.', yieldImpact: 20),
    ],
  ),
  GeneCard(
    id: 'gene-opaque2',
    symbol: 'o2 (Opaque2)',
    name: 'Opaque2',
    chromosome: 7,
    position: '12.0 Mb',
    cropId: 'maize',
    function: 'bZIP transcription factor regulating zein storage-protein gene expression in the endosperm.',
    pathway: 'Seed storage protein regulation',
    expression: [ExpressionLevel('Endosperm', 0.95), ExpressionLevel('Leaf', 0.05), ExpressionLevel('Root', 0.02)],
    proteinFamily: 'bZIP transcription factor family',
    normalPhenotype: 'Normal zein-rich, vitreous (hard, translucent) endosperm with lower lysine/tryptophan content.',
    editOutcomes: [
      GeneEditOutcome(edit: EditType.knockout, phenotype: 'Soft, opaque (chalky) endosperm with higher lysine and tryptophan content — the basis of Quality Protein Maize (QPM).', mechanism: 'Loss of zein activation shifts protein composition toward more balanced, lysine-rich proteins, but softens the kernel.', yieldImpact: -8),
      GeneEditOutcome(edit: EditType.overexpression, phenotype: 'Extremely hard, vitreous kernel with reduced nutritional quality.', mechanism: 'Excess zein activation further skews protein composition away from balanced amino acids.', yieldImpact: 2),
      GeneEditOutcome(edit: EditType.rnai, phenotype: 'Partially soft endosperm with moderately improved amino acid balance.', mechanism: 'Partial knockdown produces an intermediate opaque phenotype.', yieldImpact: -4),
      GeneEditOutcome(edit: EditType.crisprEdit, phenotype: 'QPM-quality nutrition combined with normal vitreous kernel hardness (modifier genes co-edited).', mechanism: 'Precise editing of o2 together with endosperm modifier loci decouples opacity from nutrition gain.', yieldImpact: 6),
    ],
  ),
  GeneCard(
    id: 'gene-tm2',
    symbol: 'Tm-2²',
    name: 'Tomato mosaic virus resistance 2',
    chromosome: 9,
    position: '56.1 Mb',
    cropId: 'tomato',
    function: 'CC-NBS-LRR resistance protein that recognizes the ToMV movement protein and triggers a hypersensitive response.',
    pathway: 'Plant innate immunity / effector-triggered immunity',
    expression: [ExpressionLevel('Leaf', 0.6), ExpressionLevel('Stem', 0.4), ExpressionLevel('Fruit', 0.2)],
    proteinFamily: 'NBS-LRR (nucleotide-binding, leucine-rich repeat) resistance protein family',
    normalPhenotype: 'Susceptible plants develop mosaic leaf mottling, stunting, and fruit yield loss after ToMV infection.',
    editOutcomes: [
      GeneEditOutcome(edit: EditType.knockout, phenotype: 'Loss of ToMV resistance — full susceptibility to Tobacco Mosaic Virus infection returns.', mechanism: 'Without the resistance protein, the viral movement protein is no longer detected and the immune response is not triggered.', yieldImpact: -30),
      GeneEditOutcome(edit: EditType.overexpression, phenotype: 'Stronger, faster hypersensitive response; may cause minor autoimmune leaf lesions without infection.', mechanism: 'Excess resistance protein occasionally self-triggers a mild defense response.', yieldImpact: -3),
      GeneEditOutcome(edit: EditType.rnai, phenotype: 'Partial loss of resistance; some plants show mild mosaic symptoms under high viral pressure.', mechanism: 'Reduced transcript lowers the threshold for successful viral infection.', yieldImpact: -15),
      GeneEditOutcome(edit: EditType.crisprEdit, phenotype: 'Broadened resistance spectrum to additional ToMV strains.', mechanism: 'Targeted edits to the LRR recognition domain change effector specificity.', yieldImpact: 10),
    ],
  ),
  GeneCard(
    id: 'gene-efl',
    symbol: 'EFL1',
    name: 'Early Flowering 1',
    chromosome: 3,
    position: '9.7 Mb',
    cropId: 'chickpea',
    function: 'Floral repressor whose reduced activity accelerates the transition to flowering, enabling drought escape.',
    pathway: 'Photoperiod-independent flowering time pathway',
    expression: [ExpressionLevel('Leaf', 0.7), ExpressionLevel('Shoot apex', 0.5), ExpressionLevel('Root', 0.1)],
    proteinFamily: 'MADS-box transcription factor family',
    normalPhenotype: 'Standard flowering time, may face terminal drought stress in short-season dryland environments.',
    editOutcomes: [
      GeneEditOutcome(edit: EditType.knockout, phenotype: 'Markedly earlier flowering, allowing the crop to complete its cycle before terminal drought — but with a smaller yield ceiling.', mechanism: 'Loss of floral repression accelerates the vegetative-to-reproductive transition.', yieldImpact: -5),
      GeneEditOutcome(edit: EditType.overexpression, phenotype: 'Delayed flowering and increased vegetative biomass, risking terminal drought exposure.', mechanism: 'Excess repressor activity prolongs the vegetative phase.', yieldImpact: -18),
      GeneEditOutcome(edit: EditType.rnai, phenotype: 'Moderately early flowering with partial drought escape benefit.', mechanism: 'Partial knockdown gives an intermediate flowering-time shift.', yieldImpact: 3),
      GeneEditOutcome(edit: EditType.crisprEdit, phenotype: 'Flowering time precisely tuned to a target maturity window for a specific agro-climatic zone.', mechanism: 'Promoter-strength edits allow graded control of repressor dosage.', yieldImpact: 9),
    ],
  ),
];

List<GeneCard> getGenesByCrop(String cropId) => geneCards.where((g) => g.cropId == cropId).toList();
GeneCard getGene(String id) => geneCards.firstWhere((g) => g.id == id);
