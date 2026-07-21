import { useState } from "react";
import { CROPS } from "../../data/crops";
import { getGenesByCrop, EDIT_LABELS, type EditType, type GeneCard } from "../../data/genes";
import { Card, CardTitle, Pill } from "../../components/ui/Card";
import { Button } from "../../components/ui/Button";
import { useGameStore } from "../../store/gameStore";
import { Dna, ArrowRight, FlaskConical } from "lucide-react";

export default function GeneLab() {
  const [cropId, setCropId] = useState(CROPS[0].id);
  const [selectedGene, setSelectedGene] = useState<GeneCard | null>(null);
  const [editType, setEditType] = useState<EditType | null>(null);
  const [result, setResult] = useState<GeneCard["editOutcomes"][number] | null>(null);
  const addXp = useGameStore((s) => s.addXp);
  const unlockBadge = useGameStore((s) => s.unlockBadge);

  const genes = getGenesByCrop(cropId);

  function runEdit() {
    if (!selectedGene || !editType) return;
    const outcome = selectedGene.editOutcomes.find((o) => o.edit === editType)!;
    setResult(outcome);
    addXp(20, `Ran a ${EDIT_LABELS[editType]} experiment on ${selectedGene.symbol}`);
    unlockBadge("gene-hunter");
  }

  return (
    <div className="mx-auto max-w-6xl">
      <h1 className="text-2xl font-bold tracking-tight">🧬 Gene Function Discovery Lab</h1>
      <p className="mb-6 text-sm text-emerald-900/60 dark:text-emerald-50/60">
        Investigate genes by editing them and observing phenotype outcomes — don't memorize function, discover it.
      </p>

      <div className="mb-4 flex flex-wrap gap-2">
        {CROPS.map((c) => (
          <button
            key={c.id}
            onClick={() => { setCropId(c.id); setSelectedGene(null); setResult(null); }}
            className={`rounded-full px-3 py-1.5 text-sm font-medium transition ${
              cropId === c.id ? "bg-emerald-600 text-white" : "bg-emerald-900/5 text-emerald-900/70 dark:bg-emerald-50/5 dark:text-emerald-50/70"
            }`}
          >
            {c.emoji} {c.name}
          </button>
        ))}
      </div>

      <div className="grid gap-4 lg:grid-cols-3">
        <div className="lg:col-span-1">
          <p className="mb-2 text-xs font-semibold uppercase text-emerald-900/50 dark:text-emerald-50/50">Chromosome map</p>
          <div className="flex flex-col gap-2">
            {genes.map((g) => (
              <button
                key={g.id}
                onClick={() => { setSelectedGene(g); setEditType(null); setResult(null); }}
                className={`rounded-xl border p-3 text-left transition ${
                  selectedGene?.id === g.id
                    ? "border-emerald-600 bg-emerald-600/10"
                    : "border-emerald-900/10 hover:bg-emerald-900/5 dark:border-emerald-50/10 dark:hover:bg-emerald-50/5"
                }`}
              >
                <div className="flex items-center gap-2">
                  <Dna size={16} className="text-emerald-600" />
                  <span className="font-mono font-semibold">{g.symbol}</span>
                </div>
                <p className="text-xs text-emerald-900/50 dark:text-emerald-50/50">Chr {g.chromosome} · {g.position}</p>
              </button>
            ))}
          </div>
        </div>

        <div className="lg:col-span-2">
          {!selectedGene && (
            <Card className="flex h-64 items-center justify-center text-center text-sm text-emerald-900/50 dark:text-emerald-50/50">
              Select a gene from the chromosome map to open its gene card.
            </Card>
          )}

          {selectedGene && (
            <Card>
              <div className="mb-3 flex items-center justify-between">
                <div>
                  <CardTitle>{selectedGene.symbol} — {selectedGene.name}</CardTitle>
                  <p className="text-xs text-emerald-900/50 dark:text-emerald-50/50">{selectedGene.proteinFamily}</p>
                </div>
                <Pill tone="info">Chr {selectedGene.chromosome}</Pill>
              </div>

              <p className="mb-3 text-sm text-emerald-900/70 dark:text-emerald-50/70">{selectedGene.function}</p>
              <p className="mb-4 text-xs text-emerald-900/50 dark:text-emerald-50/50"><strong>Pathway:</strong> {selectedGene.pathway}</p>

              <p className="mb-1 text-xs font-semibold uppercase text-emerald-900/50 dark:text-emerald-50/50">Expression profile</p>
              <div className="mb-4 flex flex-wrap gap-2">
                {selectedGene.expression.map((e) => (
                  <div key={e.tissue} className="rounded-lg bg-emerald-900/5 px-2 py-1 text-xs dark:bg-emerald-50/5">
                    {e.tissue}: <span className="font-mono">{Math.round(e.level * 100)}%</span>
                  </div>
                ))}
              </div>

              <Card className="mb-4 bg-emerald-600/5">
                <p className="text-xs font-semibold uppercase text-emerald-900/50 dark:text-emerald-50/50">Wild-type phenotype</p>
                <p className="text-sm">{selectedGene.normalPhenotype}</p>
              </Card>

              <p className="mb-2 text-xs font-semibold uppercase text-emerald-900/50 dark:text-emerald-50/50">Gene editing simulator</p>
              <div className="mb-3 flex flex-wrap gap-2">
                {(Object.keys(EDIT_LABELS) as EditType[]).map((et) => (
                  <button
                    key={et}
                    onClick={() => { setEditType(et); setResult(null); }}
                    className={`rounded-full px-3 py-1.5 text-xs font-medium transition ${
                      editType === et ? "bg-emerald-600 text-white" : "bg-emerald-900/5 text-emerald-900/70 dark:bg-emerald-50/5 dark:text-emerald-50/70"
                    }`}
                  >
                    {EDIT_LABELS[et]}
                  </button>
                ))}
              </div>
              <Button onClick={runEdit} disabled={!editType}>
                <FlaskConical size={16} /> Run Experiment
              </Button>

              {result && (
                <Card className="mt-4 border-emerald-600/30 bg-emerald-600/5">
                  <div className="flex items-center gap-2 text-sm font-semibold text-emerald-700 dark:text-emerald-300">
                    {selectedGene.symbol} <ArrowRight size={14} /> {EDIT_LABELS[result.edit]}
                  </div>
                  <p className="mt-2 text-sm"><strong>Observed phenotype:</strong> {result.phenotype}</p>
                  <p className="mt-1 text-xs text-emerald-900/60 dark:text-emerald-50/60"><strong>Mechanism:</strong> {result.mechanism}</p>
                  <Pill tone={result.yieldImpact >= 0 ? "good" : "bad"}>
                    Yield impact: {result.yieldImpact > 0 ? "+" : ""}{result.yieldImpact}%
                  </Pill>
                  <p className="mt-3 text-xs italic text-emerald-900/50 dark:text-emerald-50/50">
                    Reflect: what does this outcome tell you about {selectedGene.symbol}'s normal function? Could another gene in the
                    same pathway produce a similar phenotype?
                  </p>
                </Card>
              )}
            </Card>
          )}
        </div>
      </div>
    </div>
  );
}
