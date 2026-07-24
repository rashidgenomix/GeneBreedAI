import 'dart:math';
import '../models/types.dart';

const List<FieldEvent> fieldEvents = [
  FieldEvent(
    id: 'disease-outbreak',
    name: 'Disease Outbreak',
    description:
        'A fungal/bacterial epidemic sweeps the trial block. Lines lacking resistance genes suffer heavy losses.',
    icon: 'bug',
    favors: ['disease_resistance'],
    severity: FieldEventSeverity.high,
  ),
  FieldEvent(
    id: 'heat-stress',
    name: 'Heat Stress',
    description: 'A prolonged heat wave during flowering causes pollen sterility in heat-sensitive lines.',
    icon: 'thermometer',
    favors: ['heat_tolerance'],
    severity: FieldEventSeverity.medium,
  ),
  FieldEvent(
    id: 'drought',
    name: 'Drought',
    description: 'Rainfall fails for six weeks. Deep-rooted, water-use-efficient lines pull ahead.',
    icon: 'cloud-drizzle',
    favors: ['drought_tolerance'],
    severity: FieldEventSeverity.high,
  ),
  FieldEvent(
    id: 'flood',
    name: 'Flooding',
    description: 'Unseasonal flooding waterlogs the field. Submergence-tolerant genotypes survive best.',
    icon: 'waves',
    favors: ['flood_tolerance'],
    severity: FieldEventSeverity.high,
  ),
  FieldEvent(
    id: 'lodging',
    name: 'Lodging',
    description: 'A windstorm flattens tall, weak-stemmed plants right before harvest.',
    icon: 'wind',
    favors: ['lodging_resistance', 'plant_height'],
    severity: FieldEventSeverity.medium,
  ),
  FieldEvent(
    id: 'poor-germination',
    name: 'Poor Germination',
    description: 'Seed vigor issues cause patchy emergence in the nursery, shrinking your effective population.',
    icon: 'sprout',
    favors: ['seed_vigor'],
    severity: FieldEventSeverity.low,
  ),
  FieldEvent(
    id: 'mutation',
    name: 'Spontaneous Mutation',
    description: 'A random mutation appears in one line. It could be a hidden gem — or a dead end.',
    icon: 'dna',
    favors: [],
    severity: FieldEventSeverity.low,
  ),
  FieldEvent(
    id: 'seed-contamination',
    name: 'Seed Lot Contamination',
    description: 'Off-type seed mixed into your seed lot during storage. You must rogue out contaminants before advancing.',
    icon: 'alert-triangle',
    favors: [],
    severity: FieldEventSeverity.medium,
  ),
  FieldEvent(
    id: 'market-shift',
    name: 'Market Demand Shift',
    description: 'Consumer and processor demand shifts toward a new grain/fruit quality standard, changing your selection target.',
    icon: 'trending-up',
    favors: ['quality'],
    severity: FieldEventSeverity.low,
  ),
  FieldEvent(
    id: 'budget-cut',
    name: 'Budget Cut',
    description: "Your program's funding is reduced. You must shrink the population size or drop a field location.",
    icon: 'wallet',
    favors: [],
    severity: FieldEventSeverity.medium,
  ),
];

FieldEvent rollFieldEvent(Random rng) => fieldEvents[rng.nextInt(fieldEvents.length)];
