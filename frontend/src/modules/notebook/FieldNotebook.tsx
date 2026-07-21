import { useState } from "react";
import { Card, CardTitle, Pill } from "../../components/ui/Card";
import { Button } from "../../components/ui/Button";
import { CROPS } from "../../data/crops";
import type { CropId } from "../../data/types";
import { useNotebookStore, type NotebookEntry } from "../../store/notebookStore";
import { useGameStore } from "../../store/gameStore";
import { NotebookPen, Image as ImageIcon, Trash2, FileText } from "lucide-react";

const TYPES: { id: NotebookEntry["observationType"]; label: string }[] = [
  { id: "flowering", label: "Flowering date" },
  { id: "disease-score", label: "Disease score (1-9)" },
  { id: "yield", label: "Yield" },
  { id: "height", label: "Plant height" },
  { id: "general", label: "General observation" },
];

export default function FieldNotebook() {
  const { entries, addEntry, removeEntry } = useNotebookStore();
  const addXp = useGameStore((s) => s.addXp);

  const [cropId, setCropId] = useState<CropId>(CROPS[0].id);
  const [type, setType] = useState<NotebookEntry["observationType"]>("general");
  const [value, setValue] = useState("");
  const [notes, setNotes] = useState("");
  const [imageDataUrl, setImageDataUrl] = useState<string | undefined>();
  const [showReport, setShowReport] = useState(false);

  function handleImage(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = () => setImageDataUrl(reader.result as string);
    reader.readAsDataURL(file);
  }

  function submit() {
    if (!value.trim()) return;
    addEntry({ cropId, date: new Date().toISOString().slice(0, 10), observationType: type, value: value.trim(), notes: notes.trim(), imageDataUrl });
    addXp(5, "Recorded a field notebook observation");
    setValue("");
    setNotes("");
    setImageDataUrl(undefined);
  }

  return (
    <div className="mx-auto max-w-4xl">
      <h1 className="text-2xl font-bold tracking-tight">📓 Field Notebook</h1>
      <p className="mb-6 text-sm text-emerald-900/60 dark:text-emerald-50/60">
        Record real observations from your virtual field trials — flowering dates, disease scores, yield, and images.
      </p>

      <Card className="mb-4">
        <CardTitle>New Observation</CardTitle>
        <div className="grid gap-3 sm:grid-cols-2">
          <select value={cropId} onChange={(e) => setCropId(e.target.value as CropId)} className="rounded-xl border border-emerald-900/15 bg-transparent px-3 py-2 text-sm dark:border-emerald-50/15">
            {CROPS.map((c) => <option key={c.id} value={c.id}>{c.emoji} {c.name}</option>)}
          </select>
          <select value={type} onChange={(e) => setType(e.target.value as NotebookEntry["observationType"])} className="rounded-xl border border-emerald-900/15 bg-transparent px-3 py-2 text-sm dark:border-emerald-50/15">
            {TYPES.map((t) => <option key={t.id} value={t.id}>{t.label}</option>)}
          </select>
          <input value={value} onChange={(e) => setValue(e.target.value)} placeholder="Measured value" className="rounded-xl border border-emerald-900/15 bg-transparent px-3 py-2 text-sm dark:border-emerald-50/15" />
          <label className="flex cursor-pointer items-center gap-2 rounded-xl border border-dashed border-emerald-900/20 px-3 py-2 text-sm text-emerald-900/60 dark:border-emerald-50/20 dark:text-emerald-50/60">
            <ImageIcon size={16} /> {imageDataUrl ? "Image attached" : "Attach image"}
            <input type="file" accept="image/*" className="hidden" onChange={handleImage} />
          </label>
        </div>
        <textarea value={notes} onChange={(e) => setNotes(e.target.value)} placeholder="Notes..." rows={2} className="mt-3 w-full rounded-xl border border-emerald-900/15 bg-transparent p-3 text-sm dark:border-emerald-50/15" />
        <Button className="mt-3" onClick={submit} disabled={!value.trim()}>
          <NotebookPen size={16} /> Save Entry
        </Button>
      </Card>

      <div className="mb-3 flex items-center justify-between">
        <h2 className="text-lg font-bold">Entries ({entries.length})</h2>
        <Button variant="secondary" onClick={() => setShowReport((v) => !v)}>
          <FileText size={16} /> {showReport ? "Hide" : "Generate"} Report
        </Button>
      </div>

      {showReport && <Report entries={entries} />}

      <div className="flex flex-col gap-2">
        {entries.map((e) => (
          <Card key={e.id} className="flex items-start justify-between gap-3">
            <div className="flex gap-3">
              {e.imageDataUrl && <img src={e.imageDataUrl} alt="observation" className="h-14 w-14 rounded-lg object-cover" />}
              <div>
                <div className="flex items-center gap-2 text-sm font-semibold">
                  {CROPS.find((c) => c.id === e.cropId)?.emoji} {TYPES.find((t) => t.id === e.observationType)?.label}
                  <Pill>{e.date}</Pill>
                </div>
                <p className="text-sm">{e.value}</p>
                {e.notes && <p className="text-xs text-emerald-900/60 dark:text-emerald-50/60">{e.notes}</p>}
              </div>
            </div>
            <button onClick={() => removeEntry(e.id)} className="rounded-lg p-2 text-rose-500 hover:bg-rose-500/10">
              <Trash2 size={16} />
            </button>
          </Card>
        ))}
        {entries.length === 0 && <p className="text-sm text-emerald-900/50 dark:text-emerald-50/50">No entries yet — record your first observation above.</p>}
      </div>
    </div>
  );
}

function Report({ entries }: { entries: NotebookEntry[] }) {
  const byCrop = entries.reduce<Record<string, number>>((acc, e) => {
    acc[e.cropId] = (acc[e.cropId] ?? 0) + 1;
    return acc;
  }, {});
  return (
    <Card className="mb-4 bg-emerald-600/5">
      <CardTitle>Auto-generated Summary Report</CardTitle>
      <p className="text-sm">Total observations: {entries.length}</p>
      <ul className="mt-2 list-inside list-disc text-sm">
        {Object.entries(byCrop).map(([cropId, count]) => (
          <li key={cropId}>{CROPS.find((c) => c.id === cropId)?.name}: {count} observations</li>
        ))}
      </ul>
    </Card>
  );
}
