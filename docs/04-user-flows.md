# 4. User Flows

## 4.1 First-time student onboarding

```mermaid
flowchart LR
    A[Land on login] --> B[Sign in with Google]
    B --> C{Has a join code?}
    C -- yes --> D[Enter course join code]
    C -- no --> E[Skip — solo/self-study mode]
    D --> F[Land on Home Dashboard]
    E --> F
    F --> G[Guided first mission: 'Perform a Cross']
    G --> H[Breeder Simulator wizard]
```

## 4.2 Core breeding program flow (Module 1)

```mermaid
flowchart TD
    Start([Open Breeder Simulator]) --> Crop[Choose Crop]
    Crop --> Parents[Explore germplasm & compare traits]
    Parents --> Method[Choose breeding method]
    Method --> Cross[Perform hybridization → F1 population]
    Cross --> Select[Select individuals in this generation]
    Select --> Event[Field event fires: disease/drought/flood/...]
    Event --> Pressure[Selection pressure applied to population]
    Pressure --> Advance{Generations to stability reached?}
    Advance -- no --> Select
    Advance -- yes --> Release[Name & release variety]
    Release --> Score[Score computed, XP + badges awarded]
    Score --> Record[Program saved to research record / pedigree]
```

## 4.3 Gene Function Discovery flow (Module 2)

```mermaid
flowchart LR
    A[Pick crop] --> B[Open chromosome map]
    B --> C[Select a gene → gene card]
    C --> D[Choose edit type: KO / overexpr. / RNAi / CRISPR]
    D --> E[Run experiment]
    E --> F[Observe phenotype + mechanism]
    F --> G[Reflect: what does this imply about gene function?]
    G -->|optional| H[Continue to AI Research Supervisor to defend inference]
```

## 4.4 AI Research Supervisor flow (Module 4)

```mermaid
flowchart TD
    A[Student states a claim/decision] --> B[Supervisor asks a Socratic question]
    B --> C[Student responds]
    C --> D[Rule-based/GPT evaluator scores reasoning: weak / developing / strong]
    D --> E{Student stuck?}
    E -- yes, requests hint --> F[Reveal a minimal hint, not the answer]
    E -- no --> G[Supervisor asks a follow-up from a different category]
    F --> C
    G --> C
```

## 4.5 Teacher flow

```mermaid
flowchart LR
    A[Teacher logs in] --> B[Create course + join code]
    B --> C[Assign mission/module to course]
    C --> D[Students complete work]
    D --> E[Teacher Dashboard: progress + submissions]
    E --> F[Grade / generate class report]
    F --> G[Compare performance across students/cohorts]
```

## 4.6 End-to-end "week in the life" of a student

1. Open app → daily missions surface on Home ("Perform a cross", "Answer 3 viva questions").
2. Spend 15 minutes in the Breeder Simulator advancing a wheat pedigree-breeding program.
3. A disease outbreak field event forces a selection decision; XP and a "Survivor" badge condition
   are tracked.
4. Switch to Gene Function Lab to knock out `Rht-B1` and observe the semi-dwarf phenotype.
5. Open the AI Research Supervisor to defend why they chose that parent — supervisor pushes back
   with "what evidence supports this?" until the reasoning is solid.
6. End the session in Career Mode, claiming completed missions and checking badge progress.
7. Weekly: finish the breeding program to release a variety, unlocking a publication and pushing
   the student from Student → Intern once enough XP accrues.
