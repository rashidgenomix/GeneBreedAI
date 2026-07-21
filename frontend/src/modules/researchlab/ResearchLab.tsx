import { useMemo, useState } from "react";
import { Card, CardTitle, Pill } from "../../components/ui/Card";
import { Button } from "../../components/ui/Button";
import { useGameStore } from "../../store/gameStore";
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from "recharts";
import { FlaskConical, RefreshCcw } from "lucide-react";

type AnalysisId = "heritability" | "anova" | "line-x-tester" | "qtl" | "gwas";

const ANALYSES: { id: AnalysisId; name: string; ready: boolean; description: string }[] = [
  { id: "heritability", name: "Heritability & Genetic Advance", ready: true, description: "Estimate H² and expected genetic advance from a simulated segregating population." },
  { id: "anova", name: "ANOVA (Randomized Block Design)", ready: true, description: "Partition variance across genotypes, blocks, and error in a yield trial." },
  { id: "line-x-tester", name: "Line × Tester Analysis", ready: false, description: "Estimate GCA and SCA effects from a line × tester mating design." },
  { id: "qtl", name: "QTL Mapping", ready: false, description: "Map quantitative trait loci from a biparental mapping population." },
  { id: "gwas", name: "Genome-Wide Association Study", ready: false, description: "Scan genome-wide markers for trait associations in a diversity panel." },
];

function generatePopulation(n: number, mean: number, genoVarRatio: number, seed: number) {
  const rng = mulberry32(seed);
  const genoSd = Math.sqrt(genoVarRatio) * 8;
  const envSd = Math.sqrt(1 - genoVarRatio) * 8;
  return Array.from({ length: n }, (_, i) => {
    const g = gaussian(rng) * genoSd;
    const e = gaussian(rng) * envSd;
    return { id: `P${i + 1}`, value: Math.max(0, mean + g + e), genoEffect: g, envEffect: e };
  });
}

function gaussian(rng: () => number) {
  const u = 1 - rng();
  const v = rng();
  return Math.sqrt(-2 * Math.log(u)) * Math.cos(2 * Math.PI * v);
}

function mulberry32(seed: number) {
  let a = seed;
  return function () {
    a |= 0; a = (a + 0x6d2b79f5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

function variance(values: number[]) {
  const m = values.reduce((a, b) => a + b, 0) / values.length;
  return values.reduce((a, b) => a + (b - m) ** 2, 0) / (values.length - 1);
}

export default function ResearchLab() {
  const [active, setActive] = useState<AnalysisId | null>(null);
  if (active === "heritability") return <HeritabilityAnalysis onExit={() => setActive(null)} />;
  if (active === "anova") return <AnovaAnalysis onExit={() => setActive(null)} />;

  return (
    <div className="mx-auto max-w-5xl">
      <h1 className="text-2xl font-bold tracking-tight">🧪 Virtual Research Lab</h1>
      <p className="mb-6 text-sm text-emerald-900/60 dark:text-emerald-50/60">
        Run real statistical analyses on generated breeding datasets and interpret the results, exactly as in a research methods course.
      </p>
      <div className="grid gap-4 sm:grid-cols-2">
        {ANALYSES.map((a) => (
          <Card key={a.id} className={a.ready ? "cursor-pointer hover:-translate-y-0.5 hover:shadow-md" : "opacity-60"}>
            <button className="w-full text-left" disabled={!a.ready} onClick={() => setActive(a.id)}>
              <CardTitle>{a.name}</CardTitle>
              <p className="mb-2 text-sm text-emerald-900/70 dark:text-emerald-50/70">{a.description}</p>
              <Pill tone={a.ready ? "good" : "neutral"}>{a.ready ? "Run analysis" : "Coming soon"}</Pill>
            </button>
          </Card>
        ))}
      </div>
    </div>
  );
}

function HeritabilityAnalysis({ onExit }: { onExit: () => void }) {
  const [seed, setSeed] = useState(1);
  const addXp = useGameStore((s) => s.addXp);
  const unlockBadge = useGameStore((s) => s.unlockBadge);

  const parents = useMemo(() => generatePopulation(20, 60, 0.15, seed), [seed]); // low genetic variance (uniform parents)
  const f2 = useMemo(() => generatePopulation(60, 65, 0.55, seed + 1), [seed]); // segregating population, higher genetic variance

  const vpParents = variance(parents.map((p) => p.value));
  const vpF2 = variance(f2.map((p) => p.value));
  const vg = Math.max(0, vpF2 - vpParents);
  const h2 = Math.min(0.99, vg / vpF2);
  const selectionIntensity = 2.06; // ~top 5% selected
  const gain = h2 * selectionIntensity * Math.sqrt(vpF2);
  const meanF2 = f2.reduce((a, b) => a + b.value, 0) / f2.length;
  const gainPct = (gain / meanF2) * 100;

  function analyze() {
    addXp(30, "Completed a heritability & genetic advance analysis");
  }

  const histogram = useMemo(() => {
    const bins = 8;
    const values = f2.map((p) => p.value);
    const min = Math.min(...values);
    const max = Math.max(...values);
    const width = (max - min) / bins || 1;
    const counts = Array.from({ length: bins }, (_, i) => ({ bin: `${(min + i * width).toFixed(0)}`, count: 0 }));
    values.forEach((v) => {
      const idx = Math.min(bins - 1, Math.floor((v - min) / width));
      counts[idx].count += 1;
    });
    return counts;
  }, [f2]);

  return (
    <div className="mx-auto max-w-4xl">
      <div className="mb-4 flex items-center justify-between">
        <h1 className="text-xl font-bold">Heritability & Genetic Advance</h1>
        <Button variant="secondary" onClick={onExit}>← Back to Lab</Button>
      </div>
      <Card className="mb-4">
        <CardTitle>Dataset</CardTitle>
        <p className="mb-3 text-sm text-emerald-900/70 dark:text-emerald-50/70">
          Parent population: 20 genetically uniform plants (V<sub>P</sub> ≈ environmental variance only). F2 population: 60 segregating
          plants (V<sub>P</sub> = genetic + environmental variance). Yield in g/plant.
        </p>
        <div className="h-56">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={histogram}>
              <CartesianGrid strokeDasharray="3 3" opacity={0.2} />
              <XAxis dataKey="bin" fontSize={11} />
              <YAxis fontSize={11} />
              <Tooltip />
              <Bar dataKey="count" fill="#10b981" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>
        <Button variant="secondary" className="mt-2" onClick={() => setSeed((s) => s + 2)}>
          <RefreshCcw size={14} /> Generate New Dataset
        </Button>
      </Card>

      <Card>
        <CardTitle>Your Task</CardTitle>
        <p className="mb-3 text-sm text-emerald-900/70 dark:text-emerald-50/70">
          Estimate broad-sense heritability using the variance-component method: H² = (V<sub>P,F2</sub> − V<sub>P,parents</sub>) / V<sub>P,F2</sub>,
          then estimate the expected genetic advance under 5% selection intensity.
        </p>
        <Button
          onClick={() => { analyze(); unlockBadge("statistician"); }}
        >
          <FlaskConical size={16} /> Compute Results
        </Button>

        <div className="mt-4 grid grid-cols-2 gap-3 text-sm sm:grid-cols-4">
          <Stat label="Vp (parents)" value={vpParents.toFixed(1)} />
          <Stat label="Vp (F2)" value={vpF2.toFixed(1)} />
          <Stat label="Vg (estimated)" value={vg.toFixed(1)} />
          <Stat label="H² (broad-sense)" value={(h2 * 100).toFixed(1) + "%"} />
          <Stat label="Genetic advance" value={gain.toFixed(2) + " g"} />
          <Stat label="GA (% of mean)" value={gainPct.toFixed(1) + "%"} />
        </div>

        <Card className="mt-4 bg-emerald-600/5">
          <p className="text-xs font-semibold uppercase text-emerald-900/50 dark:text-emerald-50/50">Interpretation</p>
          <p className="text-sm">
            {h2 > 0.6
              ? "High heritability — direct phenotypic selection on this trait should be effective and genetic gain will be substantial."
              : h2 > 0.3
              ? "Moderate heritability — combine phenotypic selection with replicated trials or markers to improve selection accuracy."
              : "Low heritability — environmental variance dominates. Consider replicated multi-location trials, better experimental control, or marker-assisted/genomic selection."}
          </p>
        </Card>
      </Card>
    </div>
  );
}

function AnovaAnalysis({ onExit }: { onExit: () => void }) {
  const [seed, setSeed] = useState(10);
  const addXp = useGameStore((s) => s.addXp);

  const genotypes = ["G1", "G2", "G3", "G4"];
  const blocks = [1, 2, 3];

  const data = useMemo(() => {
    const rng = mulberry32(seed);
    const genoEffects: Record<string, number> = { G1: 0, G2: 4, G3: -2, G4: 7 };
    const blockEffects: Record<number, number> = { 1: 0, 2: 2, 3: -1 };
    const rows: { genotype: string; block: number; yield: number }[] = [];
    genotypes.forEach((g) => {
      blocks.forEach((b) => {
        const value = 30 + genoEffects[g] + blockEffects[b] + gaussian(rng) * 2.5;
        rows.push({ genotype: g, block: b, yield: Math.round(value * 10) / 10 });
      });
    });
    return rows;
  }, [seed]);

  const grandMean = data.reduce((a, r) => a + r.yield, 0) / data.length;
  const genoMeans = Object.fromEntries(genotypes.map((g) => [g, data.filter((r) => r.genotype === g).reduce((a, r) => a + r.yield, 0) / blocks.length]));
  const blockMeans = Object.fromEntries(blocks.map((b) => [b, data.filter((r) => r.block === b).reduce((a, r) => a + r.yield, 0) / genotypes.length]));

  const ssTotal = data.reduce((a, r) => a + (r.yield - grandMean) ** 2, 0);
  const ssGeno = blocks.length * genotypes.reduce((a, g) => a + (genoMeans[g] - grandMean) ** 2, 0);
  const ssBlock = genotypes.length * blocks.reduce((a, b) => a + (blockMeans[b] - grandMean) ** 2, 0);
  const ssError = ssTotal - ssGeno - ssBlock;

  const dfGeno = genotypes.length - 1;
  const dfBlock = blocks.length - 1;
  const dfError = dfGeno * dfBlock;
  const msGeno = ssGeno / dfGeno;
  const msBlock = ssBlock / dfBlock;
  const msError = ssError / dfError;
  const fGeno = msGeno / msError;
  const fBlock = msBlock / msError;

  function complete() {
    addXp(30, "Completed an ANOVA (RBD) analysis");
  }

  return (
    <div className="mx-auto max-w-4xl">
      <div className="mb-4 flex items-center justify-between">
        <h1 className="text-xl font-bold">ANOVA — Randomized Block Design</h1>
        <Button variant="secondary" onClick={onExit}>← Back to Lab</Button>
      </div>

      <Card className="mb-4">
        <CardTitle>Trial dataset</CardTitle>
        <p className="mb-3 text-sm text-emerald-900/70 dark:text-emerald-50/70">4 genotypes × 3 blocks, yield in t/ha.</p>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="text-left text-xs uppercase text-emerald-900/50 dark:text-emerald-50/50">
                <th className="p-2">Genotype</th>
                {blocks.map((b) => <th key={b} className="p-2">Block {b}</th>)}
                <th className="p-2">Mean</th>
              </tr>
            </thead>
            <tbody>
              {genotypes.map((g) => (
                <tr key={g} className="border-t border-emerald-900/10 dark:border-emerald-50/10">
                  <td className="p-2 font-medium">{g}</td>
                  {blocks.map((b) => (
                    <td key={b} className="p-2">{data.find((r) => r.genotype === g && r.block === b)!.yield}</td>
                  ))}
                  <td className="p-2 font-mono">{genoMeans[g].toFixed(1)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <Button variant="secondary" className="mt-2" onClick={() => setSeed((s) => s + 3)}>
          <RefreshCcw size={14} /> New Trial Data
        </Button>
      </Card>

      <Card>
        <CardTitle>ANOVA Table</CardTitle>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="text-left text-xs uppercase text-emerald-900/50 dark:text-emerald-50/50">
                <th className="p-2">Source</th><th className="p-2">df</th><th className="p-2">SS</th><th className="p-2">MS</th><th className="p-2">F</th>
              </tr>
            </thead>
            <tbody className="font-mono">
              <tr className="border-t border-emerald-900/10 dark:border-emerald-50/10"><td className="p-2 font-sans">Genotype</td><td className="p-2">{dfGeno}</td><td className="p-2">{ssGeno.toFixed(1)}</td><td className="p-2">{msGeno.toFixed(1)}</td><td className="p-2">{fGeno.toFixed(2)}</td></tr>
              <tr className="border-t border-emerald-900/10 dark:border-emerald-50/10"><td className="p-2 font-sans">Block</td><td className="p-2">{dfBlock}</td><td className="p-2">{ssBlock.toFixed(1)}</td><td className="p-2">{msBlock.toFixed(1)}</td><td className="p-2">{fBlock.toFixed(2)}</td></tr>
              <tr className="border-t border-emerald-900/10 dark:border-emerald-50/10"><td className="p-2 font-sans">Error</td><td className="p-2">{dfError}</td><td className="p-2">{ssError.toFixed(1)}</td><td className="p-2">{msError.toFixed(1)}</td><td className="p-2">—</td></tr>
              <tr className="border-t border-emerald-900/10 dark:border-emerald-50/10"><td className="p-2 font-sans">Total</td><td className="p-2">{dfGeno + dfBlock + dfError}</td><td className="p-2">{ssTotal.toFixed(1)}</td><td className="p-2">—</td><td className="p-2">—</td></tr>
            </tbody>
          </table>
        </div>
        <Card className="mt-3 bg-emerald-600/5">
          <p className="text-xs font-semibold uppercase text-emerald-900/50 dark:text-emerald-50/50">Interpretation</p>
          <p className="text-sm">
            F(genotype) = {fGeno.toFixed(2)} against a critical value around 4.76 (df=3,6, α=0.05) — {fGeno > 4.76 ? "genotypes differ significantly, so selection among them is justified." : "genotype differences are not statistically significant at this replication level; more blocks/locations may be needed."}
          </p>
        </Card>
        <Button className="mt-3" onClick={complete}>
          <FlaskConical size={16} /> Submit Interpretation
        </Button>
      </Card>
    </div>
  );
}

function Stat({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-xl bg-emerald-900/5 p-3 dark:bg-emerald-50/5">
      <p className="text-xs text-emerald-900/50 dark:text-emerald-50/50">{label}</p>
      <p className="font-mono text-lg font-semibold">{value}</p>
    </div>
  );
}
