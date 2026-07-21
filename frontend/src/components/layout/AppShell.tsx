import { useEffect } from "react";
import { NavLink, Outlet } from "react-router-dom";
import {
  Sprout, Dna, Search, GraduationCap, MessageSquareText, Gamepad2,
  FlaskConical, NotebookPen, Trophy, Sun, Moon, Menu,
} from "lucide-react";
import { useState } from "react";
import { useGameStore, useLevelInfo } from "../../store/gameStore";
import { rankForLevel } from "../../data/gamification";

const NAV_ITEMS = [
  { to: "/breeder", label: "Breeder Simulator", icon: Sprout },
  { to: "/gene-lab", label: "Gene Function Lab", icon: Dna },
  { to: "/detective", label: "Gene Detective", icon: Search },
  { to: "/supervisor", label: "Research Supervisor", icon: GraduationCap },
  { to: "/viva", label: "Viva Examiner", icon: MessageSquareText },
  { to: "/games", label: "Genetics Games", icon: Gamepad2 },
  { to: "/research-lab", label: "Virtual Research Lab", icon: FlaskConical },
  { to: "/notebook", label: "Field Notebook", icon: NotebookPen },
  { to: "/career", label: "Career Mode", icon: Trophy },
];

export default function AppShell() {
  const theme = useGameStore((s) => s.theme);
  const toggleTheme = useGameStore((s) => s.toggleTheme);
  const { level, xpIntoLevel, xpForNext } = useLevelInfo();
  const rank = rankForLevel(level);
  const [mobileNavOpen, setMobileNavOpen] = useState(false);

  useEffect(() => {
    document.documentElement.classList.toggle("dark", theme === "dark");
  }, [theme]);

  const pct = Math.min(100, Math.round((xpIntoLevel / xpForNext) * 100));

  return (
    <div className="flex h-screen w-screen overflow-hidden bg-emerald-50 text-emerald-950 dark:bg-[#0b1512] dark:text-emerald-50">
      <aside
        className={`${mobileNavOpen ? "translate-x-0" : "-translate-x-full"} fixed z-30 h-full w-72 shrink-0 border-r border-emerald-900/10 bg-white/80 backdrop-blur-md transition-transform duration-200 dark:border-emerald-100/10 dark:bg-[#0e1c17]/90 md:static md:translate-x-0`}
      >
        <div className="flex h-16 items-center gap-2 px-5">
          <span className="text-2xl">🧬</span>
          <span className="text-lg font-bold tracking-tight">GeneBreed AI</span>
        </div>
        <nav className="flex flex-col gap-1 px-3">
          {NAV_ITEMS.map(({ to, label, icon: Icon }) => (
            <NavLink
              key={to}
              to={to}
              onClick={() => setMobileNavOpen(false)}
              className={({ isActive }) =>
                `flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition-colors ${
                  isActive
                    ? "bg-emerald-600 text-white shadow-sm"
                    : "text-emerald-900/70 hover:bg-emerald-600/10 dark:text-emerald-50/70 dark:hover:bg-emerald-400/10"
                }`
              }
            >
              <Icon size={18} />
              {label}
            </NavLink>
          ))}
        </nav>
      </aside>

      <div className="flex min-w-0 flex-1 flex-col">
        <header className="flex h-16 items-center gap-4 border-b border-emerald-900/10 bg-white/70 px-4 backdrop-blur-md dark:border-emerald-100/10 dark:bg-[#0e1c17]/80">
          <button
            className="rounded-lg p-2 hover:bg-emerald-600/10 md:hidden"
            onClick={() => setMobileNavOpen((v) => !v)}
            aria-label="Toggle navigation"
          >
            <Menu size={20} />
          </button>
          <div className="min-w-0 flex-1">
            <div className="mb-1 flex items-center justify-between text-xs font-medium text-emerald-900/60 dark:text-emerald-50/60">
              <span>
                Lvl {level} · {rank.title}
              </span>
              <span>
                {xpIntoLevel} / {xpForNext} XP
              </span>
            </div>
            <div className="h-2 w-full max-w-md overflow-hidden rounded-full bg-emerald-900/10 dark:bg-emerald-50/10">
              <div className="h-full rounded-full bg-gradient-to-r from-emerald-500 to-lime-400 transition-all duration-500" style={{ width: `${pct}%` }} />
            </div>
          </div>
          <button
            onClick={toggleTheme}
            className="rounded-lg p-2 text-emerald-900/70 hover:bg-emerald-600/10 dark:text-emerald-50/70 dark:hover:bg-emerald-400/10"
            aria-label="Toggle dark mode"
          >
            {theme === "light" ? <Moon size={18} /> : <Sun size={18} />}
          </button>
        </header>

        <main className="flex-1 overflow-y-auto p-4 md:p-6">
          <Outlet />
        </main>
      </div>

      {mobileNavOpen && (
        <div className="fixed inset-0 z-20 bg-black/30 md:hidden" onClick={() => setMobileNavOpen(false)} />
      )}
    </div>
  );
}
