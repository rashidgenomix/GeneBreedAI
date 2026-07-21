import { useState } from "react";
import { Card, CardTitle, Pill } from "../../components/ui/Card";
import { Gamepad2, Puzzle, Dna, Skull, DoorClosed, GitBranch, Map, Shuffle } from "lucide-react";
import TraitPredictionGame from "./TraitPredictionGame";
import GeneMatchingGame from "./GeneMatchingGame";

type GameId = "trait-prediction" | "gene-matching" | "dna-puzzle" | "chromosome-assembly" | "mutation-challenge" | "escape-room" | "pedigree-puzzle" | "genome-mapping";

const GAMES: { id: GameId; name: string; icon: typeof Gamepad2; ready: boolean; description: string }[] = [
  { id: "trait-prediction", name: "Trait Prediction", icon: Shuffle, ready: true, description: "Predict Punnett-square offspring ratios from parent genotypes." },
  { id: "gene-matching", name: "Gene Matching", icon: Puzzle, ready: true, description: "Match gene symbols to their biological function." },
  { id: "dna-puzzle", name: "DNA Puzzle", icon: Dna, ready: false, description: "Assemble a DNA sequence from overlapping reads." },
  { id: "chromosome-assembly", name: "Chromosome Assembly", icon: GitBranch, ready: false, description: "Order gene markers along a chromosome by recombination distance." },
  { id: "mutation-challenge", name: "Mutation Challenge", icon: Skull, ready: false, description: "Identify which mutation type produced a given phenotype." },
  { id: "escape-room", name: "Breeding Escape Room", icon: DoorClosed, ready: false, description: "Solve a chain of breeding puzzles to escape the lab before the season ends." },
  { id: "pedigree-puzzle", name: "Pedigree Puzzle", icon: GitBranch, ready: false, description: "Deduce inheritance patterns from a family pedigree chart." },
  { id: "genome-mapping", name: "Genome Mapping", icon: Map, ready: false, description: "Place genes on a chromosome map using linkage data." },
];

export default function GamesHub() {
  const [active, setActive] = useState<GameId | null>(null);

  if (active === "trait-prediction") return <TraitPredictionGame onExit={() => setActive(null)} />;
  if (active === "gene-matching") return <GeneMatchingGame onExit={() => setActive(null)} />;

  return (
    <div className="mx-auto max-w-5xl">
      <h1 className="text-2xl font-bold tracking-tight">🎮 Genetics Games</h1>
      <p className="mb-6 text-sm text-emerald-900/60 dark:text-emerald-50/60">
        Sharpen your genetics intuition through fast, replayable challenges. Earn XP and unlock achievements.
      </p>
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {GAMES.map((g) => (
          <Card key={g.id} className={g.ready ? "cursor-pointer hover:-translate-y-0.5 hover:shadow-md" : "opacity-60"}>
            <button className="w-full text-left" disabled={!g.ready} onClick={() => setActive(g.id)}>
              <g.icon className="mb-2 text-emerald-600" size={24} />
              <CardTitle>{g.name}</CardTitle>
              <p className="mb-2 text-sm text-emerald-900/70 dark:text-emerald-50/70">{g.description}</p>
              <Pill tone={g.ready ? "good" : "neutral"}>{g.ready ? "Play now" : "Coming soon"}</Pill>
            </button>
          </Card>
        ))}
      </div>
    </div>
  );
}
