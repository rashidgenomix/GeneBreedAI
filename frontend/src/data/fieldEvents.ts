import type { FieldEvent } from "./types";

export const FIELD_EVENTS: FieldEvent[] = [
  {
    id: "disease-outbreak",
    name: "Disease Outbreak",
    description: "A fungal/bacterial epidemic sweeps the trial block. Lines lacking resistance genes suffer heavy losses.",
    icon: "Bug",
    favors: ["disease_resistance"],
    severity: "high",
  },
  {
    id: "heat-stress",
    name: "Heat Stress",
    description: "A prolonged heat wave during flowering causes pollen sterility in heat-sensitive lines.",
    icon: "Thermometer",
    favors: ["heat_tolerance"],
    severity: "medium",
  },
  {
    id: "drought",
    name: "Drought",
    description: "Rainfall fails for six weeks. Deep-rooted, water-use-efficient lines pull ahead.",
    icon: "CloudDrizzle",
    favors: ["drought_tolerance"],
    severity: "high",
  },
  {
    id: "flood",
    name: "Flooding",
    description: "Unseasonal flooding waterlogs the field. Submergence-tolerant genotypes survive best.",
    icon: "Waves",
    favors: ["flood_tolerance"],
    severity: "high",
  },
  {
    id: "lodging",
    name: "Lodging",
    description: "A windstorm flattens tall, weak-stemmed plants right before harvest.",
    icon: "Wind",
    favors: ["lodging_resistance", "plant_height"],
    severity: "medium",
  },
  {
    id: "poor-germination",
    name: "Poor Germination",
    description: "Seed vigor issues cause patchy emergence in the nursery, shrinking your effective population.",
    icon: "Sprout",
    favors: ["seed_vigor"],
    severity: "low",
  },
  {
    id: "mutation",
    name: "Spontaneous Mutation",
    description: "A random mutation appears in one line. It could be a hidden gem — or a dead end.",
    icon: "Dna",
    favors: [],
    severity: "low",
  },
  {
    id: "seed-contamination",
    name: "Seed Lot Contamination",
    description: "Off-type seed mixed into your seed lot during storage. You must rogue out contaminants before advancing.",
    icon: "AlertTriangle",
    favors: [],
    severity: "medium",
  },
  {
    id: "market-shift",
    name: "Market Demand Shift",
    description: "Consumer and processor demand shifts toward a new grain/fruit quality standard, changing your selection target.",
    icon: "TrendingUp",
    favors: ["quality"],
    severity: "low",
  },
  {
    id: "budget-cut",
    name: "Budget Cut",
    description: "Your program's funding is reduced. You must shrink the population size or drop a field location.",
    icon: "Wallet",
    favors: [],
    severity: "medium",
  },
];

export const getFieldEvent = (id: string) => FIELD_EVENTS.find((e) => e.id === id)!;

export function rollFieldEvent(rng: () => number = Math.random): FieldEvent {
  const idx = Math.floor(rng() * FIELD_EVENTS.length);
  return FIELD_EVENTS[idx];
}
