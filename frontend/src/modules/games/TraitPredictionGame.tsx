import { useMemo, useState } from "react";
import { Card, CardTitle, Pill } from "../../components/ui/Card";
import { Button } from "../../components/ui/Button";
import { useGameStore } from "../../store/gameStore";
import { CheckCircle2, XCircle } from "lucide-react";

interface Round {
  parentA: string;
  parentB: string;
  question: string;
  options: string[];
  correctIndex: number;
}

function genotypeRatioLabel(parentA: string, parentB: string): { ratio: string; dominantPct: number } {
  const allelesA = parentA.split("");
  const allelesB = parentB.split("");
  let dominantCount = 0;
  const combos: string[] = [];
  for (const a of allelesA) {
    for (const b of allelesB) {
      combos.push(a + b);
      if (a === a.toUpperCase() || b === b.toUpperCase()) dominantCount += 1;
    }
  }
  const dominantPct = Math.round((dominantCount / combos.length) * 100);
  const recessivePct = 100 - dominantPct;
  const gcd = (a: number, b: number): number => (b === 0 ? a : gcd(b, a % b));
  const divisor = gcd(dominantPct, recessivePct) || 1;
  const ratio = recessivePct === 0 ? "All dominant" : `${dominantPct / divisor}:${recessivePct / divisor}`;
  return { ratio, dominantPct };
}

function buildRound(seed: number): Round {
  const crossOptions: [string, string][] = [
    ["Aa", "Aa"], ["Aa", "aa"], ["AA", "aa"], ["Aa", "AA"], ["aa", "aa"],
  ];
  const [parentA, parentB] = crossOptions[seed % crossOptions.length];
  const { ratio } = genotypeRatioLabel(parentA, parentB);
  const allRatios = ["3:1", "1:1", "All dominant", "All recessive", "1:2:1"];
  const uniqueOptions = Array.from(new Set([ratio, ...allRatios])).slice(0, 4);
  const correctIndex = uniqueOptions.indexOf(ratio);
  return {
    parentA,
    parentB,
    question: `Cross ${parentA} × ${parentB} for a single dominant gene. What phenotypic ratio (dominant : recessive) do you expect in the offspring?`,
    options: uniqueOptions,
    correctIndex,
  };
}

export default function TraitPredictionGame({ onExit }: { onExit: () => void }) {
  const [seed, setSeed] = useState(0);
  const [selected, setSelected] = useState<number | null>(null);
  const [score, setScore] = useState(0);
  const [roundsPlayed, setRoundsPlayed] = useState(0);
  const addXp = useGameStore((s) => s.addXp);
  const unlockBadge = useGameStore((s) => s.unlockBadge);

  const round = useMemo(() => buildRound(seed), [seed]);

  function answer(i: number) {
    if (selected !== null) return;
    setSelected(i);
    setRoundsPlayed((r) => r + 1);
    if (i === round.correctIndex) {
      setScore((s) => s + 1);
      addXp(12, "Trait Prediction: correct answer");
    }
  }

  function nextRound() {
    if (roundsPlayed >= 5 && score === 5) unlockBadge("game-champion");
    setSeed((s) => s + 1);
    setSelected(null);
  }

  return (
    <div className="mx-auto max-w-2xl">
      <div className="mb-4 flex items-center justify-between">
        <h1 className="text-xl font-bold">Trait Prediction</h1>
        <Button variant="secondary" onClick={onExit}>← Back to Games</Button>
      </div>
      <Pill tone="info">Score: {score}/{roundsPlayed}</Pill>

      <Card className="mt-4">
        <CardTitle>Round {roundsPlayed + 1}</CardTitle>
        <p className="mb-4 text-sm">{round.question}</p>
        <div className="grid grid-cols-2 gap-2">
          {round.options.map((opt, i) => (
            <button
              key={opt}
              disabled={selected !== null}
              onClick={() => answer(i)}
              className={`rounded-xl border p-3 text-sm font-medium transition ${
                selected !== null
                  ? i === round.correctIndex
                    ? "border-emerald-600 bg-emerald-600/10"
                    : i === selected
                    ? "border-rose-500 bg-rose-500/10"
                    : "border-emerald-900/10 opacity-60 dark:border-emerald-50/10"
                  : "border-emerald-900/10 hover:bg-emerald-900/5 dark:border-emerald-50/10 dark:hover:bg-emerald-50/5"
              }`}
            >
              {opt}
            </button>
          ))}
        </div>
        {selected !== null && (
          <div className="mt-4">
            <p className="mb-2 flex items-center gap-2 text-sm font-semibold">
              {selected === round.correctIndex ? (
                <><CheckCircle2 className="text-emerald-600" size={16} /> Correct!</>
              ) : (
                <><XCircle className="text-rose-500" size={16} /> The correct ratio was {round.options[round.correctIndex]}.</>
              )}
            </p>
            <Button onClick={nextRound}>Next Round →</Button>
          </div>
        )}
      </Card>
    </div>
  );
}
