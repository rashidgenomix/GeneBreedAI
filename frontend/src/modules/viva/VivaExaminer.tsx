import { useState } from "react";
import { VIVA_QUESTIONS, type VivaQuestion } from "../../data/vivaQuestions";
import { Card, CardTitle, Pill } from "../../components/ui/Card";
import { Button } from "../../components/ui/Button";
import { useGameStore } from "../../store/gameStore";
import { MessageSquareText, CheckCircle2, XCircle } from "lucide-react";

export default function VivaExaminer() {
  const [difficulty, setDifficulty] = useState<1 | 2 | 3>(1);
  const [askedIds, setAskedIds] = useState<string[]>([]);
  const [current, setCurrent] = useState<VivaQuestion | null>(null);
  const [selected, setSelected] = useState<number | null>(null);
  const [streak, setStreak] = useState(0);
  const [correctCount, setCorrectCount] = useState(0);
  const [total, setTotal] = useState(0);
  const addXp = useGameStore((s) => s.addXp);

  function pickNext(diff: 1 | 2 | 3, exclude: string[]) {
    const pool = VIVA_QUESTIONS.filter((q) => q.difficulty === diff && !exclude.includes(q.id));
    const fallback = VIVA_QUESTIONS.filter((q) => !exclude.includes(q.id));
    const source = pool.length > 0 ? pool : fallback;
    if (source.length === 0) return null;
    return source[Math.floor(Math.random() * source.length)];
  }

  function start() {
    const q = pickNext(1, []);
    setCurrent(q);
    setAskedIds(q ? [q.id] : []);
  }

  function answer(idx: number) {
    if (!current || selected !== null) return;
    setSelected(idx);
    const isCorrect = idx === current.correctIndex;
    setTotal((t) => t + 1);
    if (isCorrect) {
      setCorrectCount((c) => c + 1);
      setStreak((s) => s + 1);
      addXp(10 + current.difficulty * 5, `Viva: answered a level-${current.difficulty} question correctly`);
    } else {
      setStreak(0);
      addXp(2, "Viva: attempted a question");
    }
  }

  function next() {
    if (!current) return;
    const wasCorrect = selected === current.correctIndex;
    let newDiff = difficulty;
    if (wasCorrect && streak >= 1 && difficulty < 3) newDiff = (difficulty + 1) as 1 | 2 | 3;
    if (!wasCorrect && difficulty > 1) newDiff = (difficulty - 1) as 1 | 2 | 3;
    setDifficulty(newDiff);
    const q = pickNext(newDiff, askedIds);
    setCurrent(q);
    setSelected(null);
    if (q) setAskedIds((a) => [...a, q.id]);
  }

  if (!current) {
    return (
      <div className="mx-auto max-w-2xl text-center">
        <h1 className="mb-2 text-2xl font-bold tracking-tight">🗣️ AI Viva Examiner</h1>
        <p className="mb-6 text-sm text-emerald-900/60 dark:text-emerald-50/60">
          Adaptive oral-exam-style questioning. Difficulty rises when you answer well and eases off when you struggle — with
          follow-up questions that build on your previous answer.
        </p>
        <Button onClick={start}>
          <MessageSquareText size={16} /> Start Viva Session
        </Button>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-2xl">
      <div className="mb-4 flex items-center justify-between text-sm">
        <Pill tone="info">Difficulty: L{difficulty}</Pill>
        <Pill>{correctCount}/{total} correct</Pill>
        <Pill tone={streak >= 2 ? "good" : "neutral"}>Streak: {streak}</Pill>
      </div>

      <Card>
        <CardTitle>{current.topic}</CardTitle>
        <p className="mb-4 text-sm">{current.question}</p>
        <div className="flex flex-col gap-2">
          {current.options.map((opt, i) => (
            <button
              key={opt}
              disabled={selected !== null}
              onClick={() => answer(i)}
              className={`rounded-xl border p-3 text-left text-sm transition ${
                selected !== null
                  ? i === current.correctIndex
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
          <Card className={`mt-4 ${selected === current.correctIndex ? "border-emerald-600/30 bg-emerald-600/5" : "border-rose-500/30 bg-rose-500/5"}`}>
            <div className="mb-1 flex items-center gap-2 font-semibold text-sm">
              {selected === current.correctIndex ? (
                <><CheckCircle2 className="text-emerald-600" size={16} /> Correct</>
              ) : (
                <><XCircle className="text-rose-500" size={16} /> Not quite</>
              )}
            </div>
            <p className="mb-3 text-sm text-emerald-900/70 dark:text-emerald-50/70">
              {selected === current.correctIndex ? current.followUpCorrect : current.followUpIncorrect}
            </p>
            <Button onClick={next}>Next Question →</Button>
          </Card>
        )}
      </Card>
    </div>
  );
}
