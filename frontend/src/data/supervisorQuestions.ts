export interface SupervisorPrompt {
  category: "justification" | "evidence" | "alternative" | "validation" | "next-step";
  question: string;
}

export const SUPERVISOR_PROMPTS: SupervisorPrompt[] = [
  { category: "justification", question: "Why did you choose this parent (or this gene/experiment) over the alternatives available to you?" },
  { category: "justification", question: "What specific trait or outcome were you optimizing for when you made that decision?" },
  { category: "evidence", question: "What evidence directly supports your hypothesis? Is it observational, experimental, or inferred?" },
  { category: "evidence", question: "How strong is that evidence — would it hold up if you doubled your sample size?" },
  { category: "alternative", question: "Can another gene, pathway, or environmental factor explain the same phenotype you observed?" },
  { category: "alternative", question: "If you're wrong, what would the data look like instead? Have you seen anything like that?" },
  { category: "validation", question: "How would you validate this conclusion — what additional test would strengthen or falsify it?" },
  { category: "validation", question: "Is your result reproducible? What would change your mind about it?" },
  { category: "next-step", question: "What is the single most informative experiment you could run next, given what you now know?" },
  { category: "next-step", question: "If resources were limited, which follow-up experiment would you prioritize, and why?" },
];

export function pickSupervisorPrompt(exclude: Set<string>): SupervisorPrompt {
  const remaining = SUPERVISOR_PROMPTS.filter((p) => !exclude.has(p.question));
  const pool = remaining.length > 0 ? remaining : SUPERVISOR_PROMPTS;
  return pool[Math.floor(Math.random() * pool.length)];
}
