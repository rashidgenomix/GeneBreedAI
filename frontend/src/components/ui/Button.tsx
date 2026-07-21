import type { ButtonHTMLAttributes } from "react";

type Variant = "primary" | "secondary" | "ghost" | "danger";

const VARIANTS: Record<Variant, string> = {
  primary: "bg-emerald-600 text-white hover:bg-emerald-700 disabled:bg-emerald-600/40",
  secondary: "bg-emerald-900/10 text-emerald-900 hover:bg-emerald-900/15 dark:bg-emerald-50/10 dark:text-emerald-50 dark:hover:bg-emerald-50/15",
  ghost: "bg-transparent text-emerald-900 hover:bg-emerald-900/10 dark:text-emerald-50 dark:hover:bg-emerald-50/10",
  danger: "bg-rose-600 text-white hover:bg-rose-700",
};

export function Button({
  variant = "primary",
  className = "",
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & { variant?: Variant }) {
  return (
    <button
      className={`inline-flex items-center justify-center gap-2 rounded-xl px-4 py-2 text-sm font-semibold shadow-sm transition-colors disabled:cursor-not-allowed disabled:opacity-50 ${VARIANTS[variant]} ${className}`}
      {...props}
    />
  );
}
