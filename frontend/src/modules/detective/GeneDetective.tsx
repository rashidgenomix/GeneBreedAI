import { useState } from "react";
import * as Icons from "lucide-react";
import { Search, CheckCircle2, XCircle } from "lucide-react";
import { DETECTIVE_CASES } from "../../data/detectiveCases";
import { Card, CardTitle, Pill } from "../../components/ui/Card";
import { Button } from "../../components/ui/Button";
import { useGameStore } from "../../store/gameStore";

export default function GeneDetective() {
  const [caseId, setCaseId] = useState<string | null>(null);
  const [revealedClues, setRevealedClues] = useState<Set<string>>(new Set());
  const [answer, setAnswer] = useState<string | null>(null);
  const [verdict, setVerdict] = useState<"correct" | "incorrect" | null>(null);
  const addXp = useGameStore((s) => s.addXp);
  const unlockBadge = useGameStore((s) => s.unlockBadge);

  const activeCase = DETECTIVE_CASES.find((c) => c.id === caseId);
  const options = activeCase
    ? shuffleStable([activeCase.correctHypothesis, ...activeCase.distractors], activeCase.id)
    : [];

  function submitAnswer(choice: string) {
    if (!activeCase) return;
    setAnswer(choice);
    const isCorrect = choice === activeCase.correctHypothesis;
    setVerdict(isCorrect ? "correct" : "incorrect");
    if (isCorrect) {
      addXp(35, `Solved case "${activeCase.title}"`);
      unlockBadge("detective");
    } else {
      addXp(5, `Attempted case "${activeCase.title}"`);
    }
  }

  function reset() {
    setCaseId(null);
    setRevealedClues(new Set());
    setAnswer(null);
    setVerdict(null);
  }

  if (!activeCase) {
    return (
      <div className="mx-auto max-w-5xl">
        <h1 className="text-2xl font-bold tracking-tight">🔍 AI Gene Detective</h1>
        <p className="mb-6 text-sm text-emerald-900/60 dark:text-emerald-50/60">
          A mystery mutant has appeared. Gather clues with real investigative tools, then propose and defend a hypothesis.
        </p>
        <div className="grid gap-4 sm:grid-cols-2">
          {DETECTIVE_CASES.map((c) => (
            <Card key={c.id} className="cursor-pointer hover:-translate-y-0.5 hover:shadow-md">
              <button className="w-full text-left" onClick={() => setCaseId(c.id)}>
                <CardTitle>{c.title}</CardTitle>
                <ul className="list-inside list-disc text-sm text-emerald-900/70 dark:text-emerald-50/70">
                  {c.symptoms.map((s) => <li key={s}>{s}</li>)}
                </ul>
              </button>
            </Card>
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-5xl">
      <div className="mb-4 flex items-center justify-between">
        <h1 className="text-xl font-bold">{activeCase.title}</h1>
        <Button variant="secondary" onClick={reset}>← Case Files</Button>
      </div>

      <Card className="mb-4">
        <CardTitle>Observed Symptoms</CardTitle>
        <ul className="list-inside list-disc text-sm text-emerald-900/70 dark:text-emerald-50/70">
          {activeCase.symptoms.map((s) => <li key={s}>{s}</li>)}
        </ul>
      </Card>

      <p className="mb-2 text-xs font-semibold uppercase text-emerald-900/50 dark:text-emerald-50/50">Investigation tools — click to run a test</p>
      <div className="mb-4 grid gap-3 sm:grid-cols-2">
        {activeCase.clues.map((clue) => {
          const revealed = revealedClues.has(clue.tool);
          const Icon = (Icons as unknown as Record<string, typeof Search>)[clue.icon] ?? Search;
          return (
            <Card key={clue.tool}>
              <button
                className="flex w-full items-center gap-2 text-left"
                onClick={() => setRevealedClues((s) => new Set(s).add(clue.tool))}
              >
                <Icon size={18} className="shrink-0 text-emerald-600" />
                <span className="text-sm font-semibold">{clue.tool}</span>
              </button>
              {revealed && <p className="mt-2 text-sm text-emerald-900/70 dark:text-emerald-50/70">{clue.text}</p>}
            </Card>
          );
        })}
      </div>

      <Card>
        <CardTitle>Propose Your Hypothesis</CardTitle>
        <p className="mb-3 text-xs text-emerald-900/60 dark:text-emerald-50/60">
          Which explanation is best supported by <em>all</em> the evidence you gathered?
        </p>
        <div className="flex flex-col gap-2">
          {options.map((opt) => {
            const isChosen = answer === opt;
            const isCorrectOpt = opt === activeCase.correctHypothesis;
            return (
              <button
                key={opt}
                disabled={!!answer}
                onClick={() => submitAnswer(opt)}
                className={`rounded-xl border p-3 text-left text-sm transition ${
                  answer
                    ? isCorrectOpt
                      ? "border-emerald-600 bg-emerald-600/10"
                      : isChosen
                      ? "border-rose-500 bg-rose-500/10"
                      : "border-emerald-900/10 opacity-60 dark:border-emerald-50/10"
                    : "border-emerald-900/10 hover:bg-emerald-900/5 dark:border-emerald-50/10 dark:hover:bg-emerald-50/5"
                }`}
              >
                {opt}
              </button>
            );
          })}
        </div>

        {verdict && (
          <Card className={`mt-4 ${verdict === "correct" ? "border-emerald-600/30 bg-emerald-600/5" : "border-rose-500/30 bg-rose-500/5"}`}>
            <div className="mb-1 flex items-center gap-2 font-semibold">
              {verdict === "correct" ? (
                <><CheckCircle2 className="text-emerald-600" size={18} /> Well reasoned!</>
              ) : (
                <><XCircle className="text-rose-500" size={18} /> Not quite — re-examine the evidence.</>
              )}
            </div>
            <p className="text-sm text-emerald-900/70 dark:text-emerald-50/70">{activeCase.explanation}</p>
            <Pill tone="info">Culprit: {activeCase.culpritGene}</Pill>
          </Card>
        )}
      </Card>
    </div>
  );
}

function shuffleStable<T>(arr: T[], seed: string): T[] {
  let h = 0;
  for (let i = 0; i < seed.length; i++) h = (h * 31 + seed.charCodeAt(i)) >>> 0;
  const copy = [...arr];
  for (let i = copy.length - 1; i > 0; i--) {
    h = (h * 1103515245 + 12345) >>> 0;
    const j = h % (i + 1);
    [copy[i], copy[j]] = [copy[j], copy[i]];
  }
  return copy;
}
