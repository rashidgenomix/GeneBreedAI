import { Link } from "react-router-dom";
import { Card, CardTitle } from "../components/ui/Card";
import { useLevelInfo } from "../store/gameStore";
import {
  Sprout, Dna, Search, GraduationCap, MessageSquareText, Gamepad2,
  FlaskConical, NotebookPen, Trophy,
} from "lucide-react";

const MODULES = [
  { to: "/breeder", label: "AI Plant Breeder Simulator", icon: Sprout, desc: "Cross parents, advance generations, survive field events, release a variety." },
  { to: "/gene-lab", label: "Gene Function Discovery Lab", icon: Dna, desc: "Edit genes and observe phenotypes to discover what they do." },
  { to: "/detective", label: "AI Gene Detective", icon: Search, desc: "Investigate mystery mutants using real diagnostic tools." },
  { to: "/supervisor", label: "AI Research Supervisor", icon: GraduationCap, desc: "Defend your reasoning under Socratic questioning." },
  { to: "/viva", label: "AI Viva Examiner", icon: MessageSquareText, desc: "Adaptive oral-exam-style questioning." },
  { to: "/games", label: "Genetics Games", icon: Gamepad2, desc: "Trait prediction, gene matching, and more." },
  { to: "/research-lab", label: "Virtual Research Lab", icon: FlaskConical, desc: "Heritability, ANOVA, and other real analyses." },
  { to: "/notebook", label: "Field Notebook", icon: NotebookPen, desc: "Record and report observations from your trials." },
  { to: "/career", label: "Career Mode", icon: Trophy, desc: "Climb from Student to Chief Plant Breeder." },
];

export default function Home() {
  const { level, rank } = useLevelInfo();
  return (
    <div className="mx-auto max-w-6xl">
      <div className="mb-8 rounded-3xl bg-gradient-to-br from-emerald-600 to-emerald-800 p-8 text-white shadow-lg">
        <p className="mb-1 text-sm font-medium uppercase tracking-wider text-emerald-100">Welcome back, {rank.title} (Lvl {level})</p>
        <h1 className="mb-2 text-3xl font-bold">🧬 GeneBreed AI</h1>
        <p className="max-w-2xl text-emerald-50/90">
          An immersive virtual laboratory for Plant Breeding & Genetics. Learn by experimenting, not by reading — cross plants, edit
          genes, solve mysteries, and run real breeding programs from seed to released variety.
        </p>
      </div>

      <h2 className="mb-3 text-lg font-bold">Modules</h2>
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {MODULES.map((m) => (
          <Link key={m.to} to={m.to}>
            <Card className="h-full transition hover:-translate-y-0.5 hover:shadow-md">
              <m.icon className="mb-2 text-emerald-600" size={26} />
              <CardTitle>{m.label}</CardTitle>
              <p className="text-sm text-emerald-900/70 dark:text-emerald-50/70">{m.desc}</p>
            </Card>
          </Link>
        ))}
      </div>
    </div>
  );
}
