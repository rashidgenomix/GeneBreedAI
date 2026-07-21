import type { Trait } from "../../data/types";
import { displayTraitValue } from "../../lib/genetics";

export function TraitBar({ trait, value, compareValue }: { trait: Trait; value: number; compareValue?: number }) {
  const pct = Math.round(value * 100);
  const comparePct = compareValue !== undefined ? Math.round(compareValue * 100) : undefined;
  const better = compareValue !== undefined && (trait.direction === "lower-better" ? value < compareValue : value > compareValue);
  const worse = compareValue !== undefined && (trait.direction === "lower-better" ? value > compareValue : value < compareValue);

  return (
    <div className="mb-2.5">
      <div className="mb-1 flex items-center justify-between text-xs">
        <span className="font-medium text-emerald-900/80 dark:text-emerald-50/80">{trait.name}</span>
        <span
          className={`font-mono ${better ? "text-emerald-600 dark:text-emerald-400" : worse ? "text-rose-500" : "text-emerald-900/60 dark:text-emerald-50/60"}`}
        >
          {displayTraitValue(trait, value)}
        </span>
      </div>
      <div className="relative h-2 w-full overflow-hidden rounded-full bg-emerald-900/10 dark:bg-emerald-50/10">
        <div className="h-full rounded-full bg-gradient-to-r from-emerald-500 to-lime-400" style={{ width: `${pct}%` }} />
        {comparePct !== undefined && (
          <div className="absolute top-0 h-full w-0.5 bg-rose-500" style={{ left: `${comparePct}%` }} title="Comparison" />
        )}
      </div>
    </div>
  );
}
