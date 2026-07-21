import { Card, CardTitle, Pill } from "../../components/ui/Card";
import { Button } from "../../components/ui/Button";
import { useGameStore, useLevelInfo } from "../../store/gameStore";
import { CAREER_RANKS, BADGES } from "../../data/gamification";
import { MISSIONS } from "../../data/missions";
import { Trophy, CheckCircle2, Award, BookOpen, Landmark } from "lucide-react";

export default function CareerMode() {
  const { level, rank, totalXp } = useLevelInfo();
  const unlockedBadgeIds = useGameStore((s) => s.unlockedBadgeIds);
  const completedMissionIds = useGameStore((s) => s.completedMissionIds);
  const completeMission = useGameStore((s) => s.completeMission);
  const addXp = useGameStore((s) => s.addXp);
  const publications = useGameStore((s) => s.publications);
  const grants = useGameStore((s) => s.grants);
  const addPublication = useGameStore((s) => s.addPublication);
  const addGrant = useGameStore((s) => s.addGrant);

  function claimMission(id: string, xp: number) {
    if (completedMissionIds.includes(id)) return;
    completeMission(id);
    addXp(xp, "Mission reward claimed");
  }

  return (
    <div className="mx-auto max-w-5xl">
      <h1 className="text-2xl font-bold tracking-tight">🏆 Career Mode</h1>
      <p className="mb-6 text-sm text-emerald-900/60 dark:text-emerald-50/60">
        Progress from Student to Chief Plant Breeder by earning XP, badges, publications, and research grants.
      </p>

      <Card className="mb-6">
        <CardTitle>Career Ladder</CardTitle>
        <div className="flex flex-wrap gap-2">
          {CAREER_RANKS.map((r) => (
            <div
              key={r.id}
              className={`flex min-w-40 flex-col rounded-xl border p-3 ${
                rank.id === r.id
                  ? "border-emerald-600 bg-emerald-600/10"
                  : level >= r.minLevel
                  ? "border-emerald-900/10 bg-emerald-600/5 dark:border-emerald-50/10"
                  : "border-emerald-900/10 opacity-50 dark:border-emerald-50/10"
              }`}
            >
              <span className="text-sm font-semibold">{r.title}</span>
              <span className="text-xs text-emerald-900/50 dark:text-emerald-50/50">Level {r.minLevel}+</span>
            </div>
          ))}
        </div>
        <div className="mt-4 grid grid-cols-2 gap-3 sm:grid-cols-4">
          <Stat icon={Trophy} label="Level" value={String(level)} />
          <Stat icon={Award} label="Total XP" value={String(totalXp)} />
          <Stat icon={BookOpen} label="Publications" value={String(publications)} />
          <Stat icon={Landmark} label="Grants" value={String(grants)} />
        </div>
        <div className="mt-3 flex gap-2">
          <Button variant="secondary" onClick={() => { addPublication(); addXp(40, "Published a research finding"); }}>
            <BookOpen size={16} /> Submit Publication (+40 XP)
          </Button>
          <Button variant="secondary" onClick={() => { addGrant(); addXp(30, "Awarded a research grant"); }}>
            <Landmark size={16} /> Apply for Grant (+30 XP)
          </Button>
        </div>
      </Card>

      <Card className="mb-6">
        <CardTitle>Missions</CardTitle>
        <div className="grid gap-2 sm:grid-cols-2">
          {MISSIONS.map((m) => {
            const done = completedMissionIds.includes(m.id);
            return (
              <div key={m.id} className={`flex items-center justify-between rounded-xl border p-3 ${done ? "border-emerald-600/30 bg-emerald-600/5" : "border-emerald-900/10 dark:border-emerald-50/10"}`}>
                <div>
                  <div className="flex items-center gap-2 text-sm font-semibold">
                    {m.title} <Pill tone={m.type === "weekly" ? "info" : "neutral"}>{m.type}</Pill>
                  </div>
                  <p className="text-xs text-emerald-900/60 dark:text-emerald-50/60">{m.description}</p>
                </div>
                <Button variant={done ? "secondary" : "primary"} disabled={done} onClick={() => claimMission(m.id, m.xp)}>
                  {done ? <><CheckCircle2 size={14} /> Done</> : `+${m.xp} XP`}
                </Button>
              </div>
            );
          })}
        </div>
      </Card>

      <Card>
        <CardTitle>Badges ({unlockedBadgeIds.length}/{BADGES.length})</CardTitle>
        <div className="grid grid-cols-2 gap-2 sm:grid-cols-3 md:grid-cols-5">
          {BADGES.map((b) => {
            const unlocked = unlockedBadgeIds.includes(b.id);
            return (
              <div key={b.id} className={`rounded-xl border p-3 text-center ${unlocked ? "border-emerald-600/30 bg-emerald-600/5" : "border-emerald-900/10 opacity-40 dark:border-emerald-50/10"}`}>
                <Award className={`mx-auto mb-1 ${unlocked ? "text-emerald-600" : "text-emerald-900/40 dark:text-emerald-50/40"}`} size={22} />
                <p className="text-xs font-semibold">{b.name}</p>
                <p className="text-[10px] text-emerald-900/50 dark:text-emerald-50/50">{b.description}</p>
              </div>
            );
          })}
        </div>
      </Card>
    </div>
  );
}

function Stat({ icon: Icon, label, value }: { icon: typeof Trophy; label: string; value: string }) {
  return (
    <div className="flex items-center gap-2 rounded-xl bg-emerald-900/5 p-3 dark:bg-emerald-50/5">
      <Icon size={18} className="text-emerald-600" />
      <div>
        <p className="text-xs text-emerald-900/50 dark:text-emerald-50/50">{label}</p>
        <p className="font-mono font-semibold">{value}</p>
      </div>
    </div>
  );
}
