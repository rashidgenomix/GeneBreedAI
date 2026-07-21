import { useMemo, useState } from "react";
import { CROPS } from "../../data/crops";
import { BREEDING_METHODS, getBreedingMethod } from "../../data/breedingMethods";
import { rollFieldEvent } from "../../data/fieldEvents";
import type { Crop, Germplasm, Individual, BreedingMethod, FieldEvent } from "../../data/types";
import { advanceGeneration, applyFieldEventPressure, hybridize, makeRng, scoreIndividual } from "../../lib/genetics";
import { Card, CardTitle, Pill } from "../../components/ui/Card";
import { Button } from "../../components/ui/Button";
import { TraitBar } from "../../components/ui/TraitBar";
import { useGameStore } from "../../store/gameStore";
import * as Icons from "lucide-react";
import { ChevronLeft, Sparkles, Trophy } from "lucide-react";

type Step = "crop" | "parents" | "method" | "generations" | "release";

export default function BreederSimulator() {
  const [step, setStep] = useState<Step>("crop");
  const [crop, setCrop] = useState<Crop | null>(null);
  const [parentA, setParentA] = useState<Germplasm | null>(null);
  const [parentB, setParentB] = useState<Germplasm | null>(null);
  const [method, setMethod] = useState<BreedingMethod | null>(null);

  const [generations, setGenerations] = useState<Individual[][]>([]);
  const [genIndex, setGenIndex] = useState(0);
  const [eventLog, setEventLog] = useState<{ generation: number; event: FieldEvent }[]>([]);
  const [activeEvent, setActiveEvent] = useState<FieldEvent | null>(null);
  const [releasedName, setReleasedName] = useState("");
  const [released, setReleased] = useState<{ name: string; score: number } | null>(null);

  const addXp = useGameStore((s) => s.addXp);
  const unlockBadge = useGameStore((s) => s.unlockBadge);
  const saveProgram = useGameStore((s) => s.saveProgram);

  const rng = useMemo(() => makeRng(), []);
  const methodInfo = method ? getBreedingMethod(method) : null;
  const currentGen = generations[genIndex] ?? [];
  const targetGenerations = methodInfo?.generationsToStability ?? 6;

  function reset() {
    setStep("crop");
    setCrop(null);
    setParentA(null);
    setParentB(null);
    setMethod(null);
    setGenerations([]);
    setGenIndex(0);
    setEventLog([]);
    setActiveEvent(null);
    setReleasedName("");
    setReleased(null);
  }

  function doHybridize() {
    if (!crop || !parentA || !parentB) return;
    const { f1 } = hybridize(parentA, parentB, crop, rng);
    setGenerations([f1]);
    setGenIndex(0);
    addXp(25, "Performed first hybridization");
    unlockBadge("first-cross");
    setStep("generations");
  }

  function toggleSelect(id: string) {
    setGenerations((gens) =>
      gens.map((gen, i) => (i === genIndex ? gen.map((ind) => (ind.id === id ? { ...ind, selected: !ind.selected } : ind)) : gen))
    );
  }

  function selectTopN(n: number) {
    setGenerations((gens) =>
      gens.map((gen, i) => {
        if (i !== genIndex || !crop) return gen;
        const ranked = [...gen].sort((a, b) => scoreIndividual(b, crop) - scoreIndividual(a, crop));
        const topIds = new Set(ranked.slice(0, n).map((x) => x.id));
        return gen.map((ind) => ({ ...ind, selected: topIds.has(ind.id) }));
      })
    );
  }

  function advance() {
    if (!crop) return;
    const selectedCount = currentGen.filter((i) => i.selected).length;
    if (selectedCount < 2) return;

    const event = rollFieldEvent(rng);
    setActiveEvent(event);

    const pressured = applyFieldEventPressure(currentGen, event.favors, event.severity, rng);
    const nextGen = advanceGeneration(pressured, crop, genIndex + 2, rng);

    setGenerations((gens) => [...gens.slice(0, genIndex + 1), nextGen]);
    setGenIndex((i) => i + 1);
    setEventLog((log) => [...log, { generation: genIndex + 2, event }]);
    addXp(15, `Advanced to generation F${genIndex + 2}`);
  }

  function releaseVariety() {
    if (!crop || !method || !releasedName.trim()) return;
    const best = [...currentGen].sort((a, b) => scoreIndividual(b, crop) - scoreIndividual(a, crop))[0];
    const score = scoreIndividual(best, crop);
    setReleased({ name: releasedName.trim(), score });
    saveProgram({
      id: `prog-${Date.now()}`,
      cropId: crop.id,
      method,
      name: releasedName.trim(),
      createdAt: Date.now(),
      parentIds: [parentA!.id, parentB!.id],
      generations,
      currentGeneration: genIndex + 1,
      fieldEventLog: eventLog.map((e) => ({ generation: e.generation, event: e.event.id, decision: "selected-for-tolerance" })),
      released: true,
      releasedVarietyName: releasedName.trim(),
      score,
    });
    const xpEarned = 50 + Math.round(score / 2);
    addXp(xpEarned, `Released new variety "${releasedName.trim()}"`);
    unlockBadge("first-release");
    if (eventLog.some((e) => e.event.severity === "high")) unlockBadge("survivor");
  }

  return (
    <div className="mx-auto max-w-6xl">
      <div className="mb-6 flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">🌾 AI Plant Breeder Simulator</h1>
          <p className="text-sm text-emerald-900/60 dark:text-emerald-50/60">
            Select parents, choose a method, and steer generations through real field challenges toward a released variety.
          </p>
        </div>
        {step !== "crop" && (
          <Button variant="secondary" onClick={reset}>
            <ChevronLeft size={16} /> Start Over
          </Button>
        )}
      </div>

      <Stepper step={step} />

      {step === "crop" && <CropStep onPick={(c) => { setCrop(c); setStep("parents"); }} />}

      {step === "parents" && crop && (
        <ParentStep
          crop={crop}
          parentA={parentA}
          parentB={parentB}
          onPick={(slot, g) => (slot === "A" ? setParentA(g) : setParentB(g))}
          onNext={() => setStep("method")}
        />
      )}

      {step === "method" && crop && parentA && parentB && (
        <MethodStep method={method} onPick={setMethod} onNext={doHybridize} />
      )}

      {step === "generations" && crop && (
        <GenerationsStep
          crop={crop}
          generations={generations}
          genIndex={genIndex}
          methodInfo={methodInfo!}
          targetGenerations={targetGenerations}
          activeEvent={activeEvent}
          onToggleSelect={toggleSelect}
          onSelectTopN={selectTopN}
          onAdvance={advance}
          onGoToRelease={() => setStep("release")}
        />
      )}

      {step === "release" && crop && !released && (
        <ReleaseStep crop={crop} generation={currentGen} name={releasedName} setName={setReleasedName} onRelease={releaseVariety} />
      )}

      {released && (
        <Card className="mt-6 text-center">
          <div className="mb-3 flex justify-center">
            <Trophy className="text-amber-500" size={40} />
          </div>
          <h2 className="text-xl font-bold">🎉 "{released.name}" Released!</h2>
          <p className="mx-auto mt-2 max-w-md text-sm text-emerald-900/70 dark:text-emerald-50/70">
            Final performance score: <strong>{released.score}/100</strong>. This variety and its full pedigree are now saved to your
            research record.
          </p>
          <Button className="mt-4" onClick={reset}>
            <Sparkles size={16} /> Breed Another Variety
          </Button>
        </Card>
      )}
    </div>
  );
}

function Stepper({ step }: { step: Step }) {
  const steps: { id: Step; label: string }[] = [
    { id: "crop", label: "1. Choose Crop" },
    { id: "parents", label: "2. Choose Parents" },
    { id: "method", label: "3. Breeding Method" },
    { id: "generations", label: "4. Grow & Select" },
    { id: "release", label: "5. Release Variety" },
  ];
  const idx = steps.findIndex((s) => s.id === step);
  return (
    <div className="mb-6 flex flex-wrap gap-2">
      {steps.map((s, i) => (
        <div
          key={s.id}
          className={`rounded-full px-3 py-1.5 text-xs font-semibold ${
            i === idx
              ? "bg-emerald-600 text-white"
              : i < idx
              ? "bg-emerald-500/20 text-emerald-700 dark:text-emerald-300"
              : "bg-emerald-900/5 text-emerald-900/40 dark:bg-emerald-50/5 dark:text-emerald-50/40"
          }`}
        >
          {s.label}
        </div>
      ))}
    </div>
  );
}

function CropStep({ onPick }: { onPick: (c: Crop) => void }) {
  return (
    <div className="grid grid-cols-2 gap-4 sm:grid-cols-3">
      {CROPS.map((c) => (
        <Card key={c.id} className="cursor-pointer transition hover:-translate-y-0.5 hover:shadow-md" >
          <button className="w-full text-left" onClick={() => onPick(c)}>
            <div className="mb-2 text-4xl">{c.emoji}</div>
            <CardTitle>{c.name}</CardTitle>
            <p className="mb-2 text-xs italic text-emerald-900/50 dark:text-emerald-50/50">{c.scientificName}</p>
            <p className="mb-3 text-sm text-emerald-900/70 dark:text-emerald-50/70">{c.description}</p>
            <div className="flex gap-2">
              <Pill>{c.chromosomeNumber} chromosomes</Pill>
              <Pill tone="info">{c.germplasm.length} germplasm lines</Pill>
            </div>
          </button>
        </Card>
      ))}
    </div>
  );
}

function ParentStep({
  crop, parentA, parentB, onPick, onNext,
}: {
  crop: Crop;
  parentA: Germplasm | null;
  parentB: Germplasm | null;
  onPick: (slot: "A" | "B", g: Germplasm) => void;
  onNext: () => void;
}) {
  return (
    <div>
      <p className="mb-4 text-sm text-emerald-900/70 dark:text-emerald-50/70">
        Explore the {crop.name} germplasm collection and choose two parents to cross. Compare their trait profiles before committing.
      </p>
      <div className="grid gap-4 md:grid-cols-2">
        {(["A", "B"] as const).map((slot) => {
          const picked = slot === "A" ? parentA : parentB;
          return (
            <Card key={slot}>
              <CardTitle>Parent {slot}</CardTitle>
              <div className="grid max-h-80 gap-2 overflow-y-auto pr-1">
                {crop.germplasm.map((g) => (
                  <button
                    key={g.id}
                    onClick={() => onPick(slot, g)}
                    className={`rounded-xl border p-3 text-left text-sm transition ${
                      picked?.id === g.id
                        ? "border-emerald-600 bg-emerald-600/10"
                        : "border-emerald-900/10 hover:bg-emerald-900/5 dark:border-emerald-50/10 dark:hover:bg-emerald-50/5"
                    }`}
                  >
                    <div className="font-semibold">{g.name}</div>
                    <div className="text-xs text-emerald-900/50 dark:text-emerald-50/50">{g.origin}</div>
                    <div className="mt-1 flex flex-wrap gap-1">
                      {g.tags.map((t) => (
                        <Pill key={t}>{t}</Pill>
                      ))}
                    </div>
                  </button>
                ))}
              </div>
            </Card>
          );
        })}
      </div>

      {parentA && parentB && (
        <Card className="mt-4">
          <CardTitle>Trait Comparison: {parentA.name} vs {parentB.name}</CardTitle>
          <div className="grid gap-x-8 md:grid-cols-2">
            <div>
              <p className="mb-2 text-xs font-semibold uppercase text-emerald-900/50 dark:text-emerald-50/50">{parentA.name}</p>
              {crop.traits.map((t) => (
                <TraitBar key={t.id} trait={t} value={parentA.traitValues[t.id] ?? 0.5} compareValue={parentB.traitValues[t.id]} />
              ))}
            </div>
            <div>
              <p className="mb-2 text-xs font-semibold uppercase text-emerald-900/50 dark:text-emerald-50/50">{parentB.name}</p>
              {crop.traits.map((t) => (
                <TraitBar key={t.id} trait={t} value={parentB.traitValues[t.id] ?? 0.5} compareValue={parentA.traitValues[t.id]} />
              ))}
            </div>
          </div>
          <Button className="mt-4" onClick={onNext}>Choose Breeding Method →</Button>
        </Card>
      )}
    </div>
  );
}

function MethodStep({ method, onPick, onNext }: { method: BreedingMethod | null; onPick: (m: BreedingMethod) => void; onNext: () => void }) {
  return (
    <div>
      <p className="mb-4 text-sm text-emerald-900/70 dark:text-emerald-50/70">
        Every breeding method trades off speed, cost, and precision. Pick the strategy for this program.
      </p>
      <div className="grid gap-3 md:grid-cols-2">
        {BREEDING_METHODS.map((m) => (
          <Card key={m.id} className={`cursor-pointer ${method === m.id ? "ring-2 ring-emerald-600" : ""}`}>
            <button className="w-full text-left" onClick={() => onPick(m.id)}>
              <CardTitle>{m.name}</CardTitle>
              <p className="mb-2 text-sm text-emerald-900/70 dark:text-emerald-50/70">{m.summary}</p>
              <div className="grid grid-cols-2 gap-3 text-xs">
                <div>
                  <p className="mb-1 font-semibold text-emerald-600 dark:text-emerald-400">Advantages</p>
                  <ul className="list-inside list-disc space-y-0.5 text-emerald-900/70 dark:text-emerald-50/70">
                    {m.advantages.map((a) => <li key={a}>{a}</li>)}
                  </ul>
                </div>
                <div>
                  <p className="mb-1 font-semibold text-rose-500">Limitations</p>
                  <ul className="list-inside list-disc space-y-0.5 text-emerald-900/70 dark:text-emerald-50/70">
                    {m.limitations.map((a) => <li key={a}>{a}</li>)}
                  </ul>
                </div>
              </div>
              <div className="mt-2 flex gap-2">
                <Pill tone="info">~{m.generationsToStability} generations to stability</Pill>
              </div>
            </button>
          </Card>
        ))}
      </div>
      <Button className="mt-4" disabled={!method} onClick={onNext}>
        <Sparkles size={16} /> Perform Hybridization
      </Button>
    </div>
  );
}

function GenerationsStep({
  crop, generations, genIndex, methodInfo, targetGenerations, activeEvent, onToggleSelect, onSelectTopN, onAdvance, onGoToRelease,
}: {
  crop: Crop;
  generations: Individual[][];
  genIndex: number;
  methodInfo: ReturnType<typeof getBreedingMethod>;
  targetGenerations: number;
  activeEvent: FieldEvent | null;
  onToggleSelect: (id: string) => void;
  onSelectTopN: (n: number) => void;
  onAdvance: () => void;
  onGoToRelease: () => void;
}) {
  const gen = generations[genIndex] ?? [];
  const selectedCount = gen.filter((i) => i.selected).length;
  const label = genIndex === 0 ? "F1" : `F${genIndex + 1}`;
  const readyToRelease = genIndex + 1 >= targetGenerations;
  const EventIcon = activeEvent ? (Icons as unknown as Record<string, typeof Sparkles>)[activeEvent.icon] ?? Sparkles : null;

  return (
    <div>
      {activeEvent && (
        <Card className="mb-4 border-amber-500/40 bg-amber-500/5">
          <div className="flex items-start gap-3">
            {EventIcon && <EventIcon className="mt-0.5 shrink-0 text-amber-600" size={22} />}
            <div>
              <p className="font-semibold text-amber-700 dark:text-amber-300">
                Field Event: {activeEvent.name} <Pill tone={activeEvent.severity === "high" ? "bad" : activeEvent.severity === "medium" ? "warn" : "neutral"}>{activeEvent.severity}</Pill>
              </p>
              <p className="text-sm text-emerald-900/70 dark:text-emerald-50/70">{activeEvent.description}</p>
            </div>
          </div>
        </Card>
      )}

      <div className="mb-4 flex flex-wrap items-center justify-between gap-3">
        <div>
          <h2 className="text-lg font-bold">Generation {label}</h2>
          <p className="text-xs text-emerald-900/60 dark:text-emerald-50/60">
            Method: {methodInfo.name} · progress {genIndex + 1}/{targetGenerations} generations toward stability
          </p>
        </div>
        <div className="flex gap-2">
          <Button variant="secondary" onClick={() => onSelectTopN(4)}>Auto-select Top 4</Button>
          {readyToRelease ? (
            <Button onClick={onGoToRelease}>Proceed to Release →</Button>
          ) : (
            <Button onClick={onAdvance} disabled={selectedCount < 2}>
              Advance Generation ({selectedCount} selected)
            </Button>
          )}
        </div>
      </div>

      <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-4">
        {gen.map((ind) => (
          <button
            key={ind.id}
            onClick={() => onToggleSelect(ind.id)}
            className={`rounded-xl border p-3 text-left transition ${
              ind.selected
                ? "border-emerald-600 bg-emerald-600/10 shadow-sm"
                : "border-emerald-900/10 hover:bg-emerald-900/5 dark:border-emerald-50/10 dark:hover:bg-emerald-50/5"
            }`}
          >
            <div className="mb-1 flex items-center justify-between">
              <span className="text-xs font-semibold text-emerald-900/60 dark:text-emerald-50/60">{ind.label.split(" ")[0]}-{ind.id.slice(-4)}</span>
              <Pill tone="info">{scoreIndividual(ind, crop)}</Pill>
            </div>
            {crop.traits.slice(0, 3).map((t) => (
              <TraitBar key={t.id} trait={t} value={ind.traitValues[t.id] ?? 0.5} />
            ))}
            <p className="mt-1 text-[10px] text-emerald-900/40 dark:text-emerald-50/40">Heterozygosity {(ind.heterozygosity * 100).toFixed(0)}%</p>
          </button>
        ))}
      </div>
    </div>
  );
}

function ReleaseStep({
  crop, generation, name, setName, onRelease,
}: {
  crop: Crop;
  generation: Individual[];
  name: string;
  setName: (v: string) => void;
  onRelease: () => void;
}) {
  const best = [...generation].sort((a, b) => scoreIndividual(b, crop) - scoreIndividual(a, crop))[0];
  if (!best) return null;
  return (
    <Card>
      <CardTitle>Release Candidate: Best Line from Final Generation</CardTitle>
      <Pill tone="good">Overall Score: {scoreIndividual(best, crop)}/100</Pill>
      <div className="mt-3 grid gap-x-8 sm:grid-cols-2">
        {crop.traits.map((t) => (
          <TraitBar key={t.id} trait={t} value={best.traitValues[t.id] ?? 0.5} />
        ))}
      </div>
      <div className="mt-4 flex flex-wrap items-center gap-3">
        <input
          value={name}
          onChange={(e) => setName(e.target.value)}
          placeholder={`e.g. ${crop.name}-Champion-1`}
          className="w-64 rounded-xl border border-emerald-900/15 bg-transparent px-3 py-2 text-sm outline-none focus:border-emerald-600 dark:border-emerald-50/15"
        />
        <Button onClick={onRelease} disabled={!name.trim()}>
          <Trophy size={16} /> Release Variety
        </Button>
      </div>
    </Card>
  );
}
