import type { ReactNode } from "react";

export function Card({ children, className = "" }: { children: ReactNode; className?: string }) {
  return (
    <div className={`rounded-2xl border border-emerald-900/10 bg-white/80 p-5 shadow-sm backdrop-blur dark:border-emerald-100/10 dark:bg-[#10201a]/80 ${className}`}>
      {children}
    </div>
  );
}

export function CardTitle({ children, className = "" }: { children: ReactNode; className?: string }) {
  return <h3 className={`mb-2 text-base font-semibold tracking-tight ${className}`}>{children}</h3>;
}

export function Pill({ children, tone = "neutral" }: { children: ReactNode; tone?: "neutral" | "good" | "warn" | "bad" | "info" }) {
  const tones: Record<string, string> = {
    neutral: "bg-emerald-900/10 text-emerald-900 dark:bg-emerald-50/10 dark:text-emerald-50",
    good: "bg-emerald-500/15 text-emerald-700 dark:text-emerald-300",
    warn: "bg-amber-500/15 text-amber-700 dark:text-amber-300",
    bad: "bg-rose-500/15 text-rose-700 dark:text-rose-300",
    info: "bg-sky-500/15 text-sky-700 dark:text-sky-300",
  };
  return <span className={`inline-flex items-center rounded-full px-2.5 py-1 text-xs font-medium ${tones[tone]}`}>{children}</span>;
}
