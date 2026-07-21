import { useState } from "react";
import { Card, CardTitle, Pill } from "../../components/ui/Card";
import { Button } from "../../components/ui/Button";
import { pickSupervisorPrompt, type SupervisorPrompt } from "../../data/supervisorQuestions";
import { useGameStore } from "../../store/gameStore";
import { GraduationCap, SendHorizonal, Lightbulb } from "lucide-react";

interface Turn {
  prompt: SupervisorPrompt;
  response: string;
  feedback: string;
  strength: "weak" | "developing" | "strong";
}

export default function ResearchSupervisor() {
  const [topic, setTopic] = useState("");
  const [started, setStarted] = useState(false);
  const [currentPrompt, setCurrentPrompt] = useState<SupervisorPrompt | null>(null);
  const [draft, setDraft] = useState("");
  const [turns, setTurns] = useState<Turn[]>([]);
  const [showHint, setShowHint] = useState(false);
  const addXp = useGameStore((s) => s.addXp);

  function begin() {
    if (!topic.trim()) return;
    setStarted(true);
    setCurrentPrompt(pickSupervisorPrompt(new Set()));
  }

  function evaluate(response: string): { feedback: string; strength: Turn["strength"] } {
    const trimmed = response.trim();
    const words = trimmed.split(/\s+/).filter(Boolean);
    const reasoningMarkers = ["because", "evidence", "data", "control", "hypothesis", "compare", "expect", "predict", "test"];
    const markerHits = reasoningMarkers.filter((m) => trimmed.toLowerCase().includes(m)).length;

    if (words.length < 6) {
      return { feedback: "That's quite brief. A research supervisor would push you to elaborate — what specific reasoning or evidence backs this up?", strength: "weak" };
    }
    if (markerHits >= 2) {
      return { feedback: "Good — you're grounding your answer in evidence and causal reasoning rather than intuition alone. Keep connecting claims to data.", strength: "strong" };
    }
    return { feedback: "You've stated a position, but try tying it more explicitly to evidence or a testable prediction — what would you expect to see if you're right?", strength: "developing" };
  }

  function submit() {
    if (!currentPrompt || !draft.trim()) return;
    const { feedback, strength } = evaluate(draft);
    setTurns((t) => [...t, { prompt: currentPrompt, response: draft, feedback, strength }]);
    addXp(strength === "strong" ? 15 : strength === "developing" ? 8 : 3, "Responded to research supervisor prompt");
    setDraft("");
    setShowHint(false);
    setCurrentPrompt(pickSupervisorPrompt(new Set(turns.map((t) => t.prompt.question))));
  }

  return (
    <div className="mx-auto max-w-3xl">
      <h1 className="text-2xl font-bold tracking-tight">🎓 AI Research Supervisor</h1>
      <p className="mb-6 text-sm text-emerald-900/60 dark:text-emerald-50/60">
        The supervisor never hands you answers. It interrogates your reasoning — like a real advisor would — and only offers a hint
        when you're stuck.
      </p>

      {!started && (
        <Card>
          <CardTitle>What decision or hypothesis do you want to defend?</CardTitle>
          <p className="mb-2 text-xs text-emerald-900/60 dark:text-emerald-50/60">
            e.g. "I chose Drysdale as a parent because it's drought tolerant" or "I think Rht-B1 controls plant height."
          </p>
          <textarea
            value={topic}
            onChange={(e) => setTopic(e.target.value)}
            rows={3}
            className="mb-3 w-full rounded-xl border border-emerald-900/15 bg-transparent p-3 text-sm outline-none focus:border-emerald-600 dark:border-emerald-50/15"
          />
          <Button onClick={begin} disabled={!topic.trim()}>
            <GraduationCap size={16} /> Begin Viva-style Discussion
          </Button>
        </Card>
      )}

      {started && (
        <>
          <Card className="mb-4 bg-emerald-600/5">
            <p className="text-xs font-semibold uppercase text-emerald-900/50 dark:text-emerald-50/50">Your claim</p>
            <p className="text-sm italic">"{topic}"</p>
          </Card>

          {turns.map((t, i) => (
            <Card key={i} className="mb-3">
              <div className="mb-1 flex items-center gap-2 text-sm font-semibold text-emerald-700 dark:text-emerald-300">
                <GraduationCap size={16} /> Supervisor asks:
              </div>
              <p className="mb-2 text-sm">{t.prompt.question}</p>
              <p className="mb-2 rounded-lg bg-emerald-900/5 p-2 text-sm dark:bg-emerald-50/5">You: {t.response}</p>
              <Pill tone={t.strength === "strong" ? "good" : t.strength === "developing" ? "warn" : "bad"}>{t.strength} reasoning</Pill>
              <p className="mt-2 text-sm text-emerald-900/70 dark:text-emerald-50/70">{t.feedback}</p>
            </Card>
          ))}

          {currentPrompt && (
            <Card>
              <div className="mb-2 flex items-center gap-2 text-sm font-semibold text-emerald-700 dark:text-emerald-300">
                <GraduationCap size={16} /> Supervisor asks:
              </div>
              <p className="mb-3 text-sm">{currentPrompt.question}</p>
              <textarea
                value={draft}
                onChange={(e) => setDraft(e.target.value)}
                rows={3}
                placeholder="Respond with your reasoning..."
                className="mb-2 w-full rounded-xl border border-emerald-900/15 bg-transparent p-3 text-sm outline-none focus:border-emerald-600 dark:border-emerald-50/15"
              />
              <div className="flex gap-2">
                <Button onClick={submit} disabled={!draft.trim()}>
                  <SendHorizonal size={16} /> Respond
                </Button>
                <Button variant="secondary" onClick={() => setShowHint((v) => !v)}>
                  <Lightbulb size={16} /> Hint
                </Button>
              </div>
              {showHint && (
                <p className="mt-2 text-xs italic text-emerald-900/60 dark:text-emerald-50/60">
                  Hint: mention what data, comparison, or control would let someone else check your reasoning independently.
                </p>
              )}
            </Card>
          )}
        </>
      )}
    </div>
  );
}
