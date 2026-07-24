import 'dart:math';

enum PromptCategory { justification, evidence, alternative, validation, nextStep }

class SupervisorPrompt {
  final PromptCategory category;
  final String question;
  const SupervisorPrompt({required this.category, required this.question});
}

const List<SupervisorPrompt> supervisorPrompts = [
  SupervisorPrompt(category: PromptCategory.justification, question: 'Why did you choose this parent (or this gene/experiment) over the alternatives available to you?'),
  SupervisorPrompt(category: PromptCategory.justification, question: 'What specific trait or outcome were you optimizing for when you made that decision?'),
  SupervisorPrompt(category: PromptCategory.evidence, question: 'What evidence directly supports your hypothesis? Is it observational, experimental, or inferred?'),
  SupervisorPrompt(category: PromptCategory.evidence, question: 'How strong is that evidence — would it hold up if you doubled your sample size?'),
  SupervisorPrompt(category: PromptCategory.alternative, question: 'Can another gene, pathway, or environmental factor explain the same phenotype you observed?'),
  SupervisorPrompt(category: PromptCategory.alternative, question: "If you're wrong, what would the data look like instead? Have you seen anything like that?"),
  SupervisorPrompt(category: PromptCategory.validation, question: 'How would you validate this conclusion — what additional test would strengthen or falsify it?'),
  SupervisorPrompt(category: PromptCategory.validation, question: 'Is your result reproducible? What would change your mind about it?'),
  SupervisorPrompt(category: PromptCategory.nextStep, question: 'What is the single most informative experiment you could run next, given what you now know?'),
  SupervisorPrompt(category: PromptCategory.nextStep, question: 'If resources were limited, which follow-up experiment would you prioritize, and why?'),
];

SupervisorPrompt pickSupervisorPrompt(Set<String> exclude, Random rng) {
  final remaining = supervisorPrompts.where((p) => !exclude.contains(p.question)).toList();
  final pool = remaining.isNotEmpty ? remaining : supervisorPrompts;
  return pool[rng.nextInt(pool.length)];
}
