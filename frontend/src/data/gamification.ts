export interface CareerRank {
  id: string;
  title: string;
  minLevel: number;
  description: string;
}

export const CAREER_RANKS: CareerRank[] = [
  { id: "student", title: "Student", minLevel: 1, description: "Just starting out in the field." },
  { id: "intern", title: "Intern", minLevel: 3, description: "Assisting with routine breeding tasks." },
  { id: "assistant-breeder", title: "Assistant Breeder", minLevel: 6, description: "Running small breeding programs independently." },
  { id: "research-associate", title: "Research Associate", minLevel: 10, description: "Designing experiments and analyzing data." },
  { id: "scientist", title: "Scientist", minLevel: 15, description: "Leading original breeding and genetics research." },
  { id: "senior-scientist", title: "Senior Scientist", minLevel: 21, description: "Mentoring others and driving strategic programs." },
  { id: "chief-plant-breeder", title: "Chief Plant Breeder", minLevel: 28, description: "Directing an institution's entire breeding portfolio." },
];

export function rankForLevel(level: number): CareerRank {
  let current = CAREER_RANKS[0];
  for (const rank of CAREER_RANKS) {
    if (level >= rank.minLevel) current = rank;
  }
  return current;
}

/** XP required to go from level N to N+1 grows quadratically to keep pacing meaningful. */
export function xpForLevel(level: number): number {
  return Math.round(80 * level * level + 120 * level);
}

export function levelForTotalXp(totalXp: number): { level: number; xpIntoLevel: number; xpForNext: number } {
  let level = 1;
  let remaining = totalXp;
  while (remaining >= xpForLevel(level)) {
    remaining -= xpForLevel(level);
    level += 1;
  }
  return { level, xpIntoLevel: remaining, xpForNext: xpForLevel(level) };
}

export interface Badge {
  id: string;
  name: string;
  description: string;
  icon: string;
  category: "breeding" | "genetics" | "research" | "games" | "career";
}

export const BADGES: Badge[] = [
  { id: "first-cross", name: "First Cross", description: "Performed your first hybridization.", icon: "GitBranch", category: "breeding" },
  { id: "first-release", name: "Variety Releaser", description: "Released your first new variety.", icon: "Award", category: "breeding" },
  { id: "survivor", name: "Survivor", description: "Kept a breeding line alive through a high-severity field event.", icon: "ShieldCheck", category: "breeding" },
  { id: "gene-hunter", name: "Gene Hunter", description: "Completed your first gene knockout experiment.", icon: "Dna", category: "genetics" },
  { id: "detective", name: "Gene Detective", description: "Solved your first mystery mutant case.", icon: "Search", category: "genetics" },
  { id: "statistician", name: "Statistician", description: "Completed an ANOVA analysis in the Virtual Research Lab.", icon: "BarChart3", category: "research" },
  { id: "polyglot-breeder", name: "Polyglot Breeder", description: "Used five different breeding methods.", icon: "Layers", category: "breeding" },
  { id: "six-crops", name: "Crop Explorer", description: "Ran a breeding program in all six crops.", icon: "Sprout", category: "breeding" },
  { id: "game-champion", name: "Game Champion", description: "Scored full marks on a genetics game.", icon: "Trophy", category: "games" },
  { id: "published", name: "Published Researcher", description: "Earned your first in-app publication.", icon: "BookOpen", category: "research" },
];
