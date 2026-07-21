-- Seeds for small, stable reference tables. Crop/germplasm/gene/detective-case seed data is
-- authored in frontend/src/data/*.ts (the single source of truth used by the simulation engine)
-- and mirrored into the crops/traits/germplasm/genes/detective_cases tables by the sync script
-- described in docs/02-database-schema.md — this keeps one canonical dataset instead of two.

insert into breeding_method_types (id, name, summary, generations_to_stability, cost_multiplier, speed_multiplier) values
  ('pedigree', 'Pedigree Breeding', 'Individual plants are selected each generation with full lineage tracking.', 6, 1.3, 0.8),
  ('bulk', 'Bulk Breeding', 'Segregating populations are grown in bulk before selection begins.', 7, 0.7, 0.9),
  ('backcross', 'Backcross Breeding', 'Repeated crossing back to a recurrent parent to transfer one trait.', 6, 1.1, 1.0),
  ('single-seed-descent', 'Single Seed Descent', 'One seed per plant advanced each generation without selection.', 5, 0.9, 1.6),
  ('recurrent-selection', 'Recurrent Selection', 'Repeated cycles of selection and intercrossing.', 8, 1.2, 0.7),
  ('mass-selection', 'Mass Selection', 'Phenotypic selection and bulking without progeny testing.', 4, 0.5, 1.2),
  ('hybrid', 'Hybrid Breeding', 'Inbred lines crossed to exploit heterosis.', 5, 1.6, 1.1),
  ('marker-assisted-selection', 'Marker-Assisted Selection', 'DNA markers used to select at the seedling stage.', 4, 1.8, 1.4),
  ('genomic-selection', 'Genomic Selection', 'Genome-wide markers predict breeding values.', 3, 2.2, 1.8),
  ('double-haploid', 'Doubled Haploid Technology', 'Haploid induction plus chromosome doubling for instant homozygosity.', 2, 2.0, 2.2);

insert into field_event_types (id, name, description, severity, favors_trait_ids) values
  ('disease-outbreak', 'Disease Outbreak', 'A fungal/bacterial epidemic sweeps the trial block.', 'high', '{disease_resistance}'),
  ('heat-stress', 'Heat Stress', 'A prolonged heat wave during flowering.', 'medium', '{heat_tolerance}'),
  ('drought', 'Drought', 'Rainfall fails for six weeks.', 'high', '{drought_tolerance}'),
  ('flood', 'Flooding', 'Unseasonal flooding waterlogs the field.', 'high', '{flood_tolerance}'),
  ('lodging', 'Lodging', 'A windstorm flattens tall, weak-stemmed plants.', 'medium', '{lodging_resistance,plant_height}'),
  ('poor-germination', 'Poor Germination', 'Seed vigor issues cause patchy emergence.', 'low', '{seed_vigor}'),
  ('mutation', 'Spontaneous Mutation', 'A random mutation appears in one line.', 'low', '{}'),
  ('seed-contamination', 'Seed Lot Contamination', 'Off-type seed mixed into the seed lot.', 'medium', '{}'),
  ('market-shift', 'Market Demand Shift', 'Consumer/processor demand shifts standards.', 'low', '{quality}'),
  ('budget-cut', 'Budget Cut', 'Program funding is reduced.', 'medium', '{}');

insert into badges (id, name, description, icon, category) values
  ('first-cross', 'First Cross', 'Performed your first hybridization.', 'GitBranch', 'breeding'),
  ('first-release', 'Variety Releaser', 'Released your first new variety.', 'Award', 'breeding'),
  ('survivor', 'Survivor', 'Kept a breeding line alive through a high-severity field event.', 'ShieldCheck', 'breeding'),
  ('gene-hunter', 'Gene Hunter', 'Completed your first gene knockout experiment.', 'Dna', 'genetics'),
  ('detective', 'Gene Detective', 'Solved your first mystery mutant case.', 'Search', 'genetics'),
  ('statistician', 'Statistician', 'Completed an ANOVA analysis.', 'BarChart3', 'research'),
  ('polyglot-breeder', 'Polyglot Breeder', 'Used five different breeding methods.', 'Layers', 'breeding'),
  ('six-crops', 'Crop Explorer', 'Ran a breeding program in all six crops.', 'Sprout', 'breeding'),
  ('game-champion', 'Game Champion', 'Scored full marks on a genetics game.', 'Trophy', 'games'),
  ('published', 'Published Researcher', 'Earned your first in-app publication.', 'BookOpen', 'research');

insert into missions (id, title, description, xp, type) values
  ('m-cross', 'Perform a Cross', 'Hybridize two parents in the Breeder Simulator.', 20, 'daily'),
  ('m-gene-edit', 'Run a Gene Edit', 'Complete one gene editing experiment.', 20, 'daily'),
  ('m-viva', 'Answer 3 Viva Questions', 'Complete three questions in the AI Viva Examiner.', 25, 'daily'),
  ('m-release', 'Release a Variety', 'Take a breeding program to variety release.', 60, 'weekly'),
  ('m-case', 'Solve a Detective Case', 'Correctly resolve one Gene Detective mystery case.', 45, 'weekly'),
  ('m-analysis', 'Run a Statistical Analysis', 'Complete a heritability or ANOVA analysis.', 40, 'weekly');
