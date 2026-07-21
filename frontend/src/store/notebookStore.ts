import { create } from "zustand";
import { persist } from "zustand/middleware";

export interface NotebookEntry {
  id: string;
  cropId: string;
  date: string;
  observationType: "flowering" | "disease-score" | "yield" | "height" | "general";
  value: string;
  notes: string;
  imageDataUrl?: string;
}

interface NotebookState {
  entries: NotebookEntry[];
  addEntry: (entry: Omit<NotebookEntry, "id">) => void;
  removeEntry: (id: string) => void;
}

export const useNotebookStore = create<NotebookState>()(
  persist(
    (set) => ({
      entries: [],
      addEntry: (entry) =>
        set((state) => ({
          entries: [{ ...entry, id: `note-${Date.now()}-${Math.random().toString(36).slice(2, 6)}` }, ...state.entries],
        })),
      removeEntry: (id) => set((state) => ({ entries: state.entries.filter((e) => e.id !== id) })),
    }),
    { name: "genebreed-ai-notebook" }
  )
);
