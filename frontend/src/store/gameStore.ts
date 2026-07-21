import { create } from "zustand";
import { persist } from "zustand/middleware";
import { levelForTotalXp, rankForLevel } from "../data/gamification";
import type { BreedingProgram } from "../data/types";

export interface XpEvent {
  id: string;
  amount: number;
  reason: string;
  timestamp: number;
}

interface GameState {
  totalXp: number;
  unlockedBadgeIds: string[];
  xpLog: XpEvent[];
  programs: BreedingProgram[];
  publications: number;
  grants: number;
  theme: "light" | "dark";
  lastLevelSeen: number;
  completedMissionIds: string[];

  addXp: (amount: number, reason: string) => void;
  unlockBadge: (badgeId: string) => void;
  saveProgram: (program: BreedingProgram) => void;
  updateProgram: (id: string, updater: (p: BreedingProgram) => BreedingProgram) => void;
  addPublication: () => void;
  addGrant: () => void;
  toggleTheme: () => void;
  acknowledgeLevel: (level: number) => void;
  completeMission: (id: string) => void;
}

export const useGameStore = create<GameState>()(
  persist(
    (set) => ({
      totalXp: 0,
      unlockedBadgeIds: [],
      xpLog: [],
      programs: [],
      publications: 0,
      grants: 0,
      theme: "light",
      lastLevelSeen: 1,
      completedMissionIds: [],

      addXp: (amount, reason) =>
        set((state) => ({
          totalXp: state.totalXp + amount,
          xpLog: [{ id: `xp-${Date.now()}-${Math.random().toString(36).slice(2, 7)}`, amount, reason, timestamp: Date.now() }, ...state.xpLog].slice(0, 50),
        })),

      unlockBadge: (badgeId) =>
        set((state) => (state.unlockedBadgeIds.includes(badgeId) ? state : { unlockedBadgeIds: [...state.unlockedBadgeIds, badgeId] })),

      saveProgram: (program) => set((state) => ({ programs: [...state.programs, program] })),

      updateProgram: (id, updater) =>
        set((state) => ({
          programs: state.programs.map((p) => (p.id === id ? updater(p) : p)),
        })),

      addPublication: () => set((state) => ({ publications: state.publications + 1 })),
      addGrant: () => set((state) => ({ grants: state.grants + 1 })),
      toggleTheme: () => set((state) => ({ theme: state.theme === "light" ? "dark" : "light" })),
      acknowledgeLevel: (level) => set({ lastLevelSeen: level }),
      completeMission: (id) =>
        set((state) => (state.completedMissionIds.includes(id) ? state : { completedMissionIds: [...state.completedMissionIds, id] })),
    }),
    { name: "genebreed-ai-save" }
  )
);

export function useLevelInfo() {
  const totalXp = useGameStore((s) => s.totalXp);
  const { level, xpIntoLevel, xpForNext } = levelForTotalXp(totalXp);
  const rank = rankForLevel(level);
  return { level, xpIntoLevel, xpForNext, rank, totalXp };
}
