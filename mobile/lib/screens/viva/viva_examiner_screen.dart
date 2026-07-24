import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/viva_questions.dart';
import '../../state/game_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/module_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/detail_sheet.dart';
import '../../widgets/stage_node.dart';
import '../../widgets/status_state.dart';

final _accent = moduleTheme(ModuleId.viva).color;
const _stageNames = {1: 'Foundation', 2: 'Intermediate', 3: 'Advanced'};

class _Answered {
  final VivaQuestion question;
  final int selectedIndex;
  final bool correct;
  const _Answered({required this.question, required this.selectedIndex, required this.correct});
}

class VivaExaminerScreen extends StatefulWidget {
  const VivaExaminerScreen({super.key});

  @override
  State<VivaExaminerScreen> createState() => _VivaExaminerScreenState();
}

class _VivaExaminerScreenState extends State<VivaExaminerScreen> {
  VivaTopic? topic;
  int? stage;
  List<VivaQuestion> sessionQuestions = [];
  int questionIndex = 0;
  int? selected;
  final List<_Answered> answered = [];
  bool sessionComplete = false;

  void _openTopic(VivaTopic t) => setState(() => topic = t);

  void _startStage(int s) {
    setState(() {
      stage = s;
      sessionQuestions = vivaQuestionsFor(topic!.id, s)..shuffle();
      questionIndex = 0;
      selected = null;
      answered.clear();
      sessionComplete = false;
    });
  }

  void _answer(int idx) {
    if (selected != null) return;
    final q = sessionQuestions[questionIndex];
    final isCorrect = idx == q.correctIndex;
    setState(() {
      selected = idx;
      answered.add(_Answered(question: q, selectedIndex: idx, correct: isCorrect));
    });
    final game = context.read<GameProvider>();
    game.addXp(isCorrect ? 8 + stage! * 4 : 2, 'Viva: ${topic!.name} — ${_stageNames[stage]}');
  }

  void _nextQuestion() {
    if (questionIndex + 1 >= sessionQuestions.length) {
      final correctCount = answered.where((a) => a.correct).length;
      final passed = correctCount >= (sessionQuestions.length * 0.75).ceil();
      if (passed) {
        context.read<GameProvider>().completeVivaStage(topic!.id, stage!);
      }
      setState(() => sessionComplete = true);
      return;
    }
    setState(() {
      questionIndex += 1;
      selected = null;
    });
  }

  void _reviewAnswer(_Answered a) {
    showDetailSheet(
      context,
      title: a.correct ? 'Correct' : 'Not quite',
      subtitle: a.question.question,
      icon: a.correct ? Icons.check_circle : Icons.cancel,
      accentColor: a.correct ? AppColors.good : AppColors.bad,
      children: [
        DetailSection(label: 'Your answer', text: a.question.options[a.selectedIndex]),
        if (!a.correct) DetailSection(label: 'Correct answer', text: a.question.options[a.question.correctIndex]),
        DetailSection(label: 'Follow-up', text: a.correct ? a.question.followUpCorrect : a.question.followUpIncorrect),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final game = context.watch<GameProvider>();

    Widget body;
    if (topic == null) {
      body = _topicGrid(game);
    } else if (stage == null) {
      body = _stageMap(game);
    } else if (sessionComplete) {
      body = _sessionSummary();
    } else {
      body = _questionCard();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg + bottomInset),
      child: body,
    );
  }

  Widget _topicGrid(GameProvider game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pick a topic, then work through its Foundation → Intermediate → Advanced stages.', style: AppText.body),
        const SizedBox(height: AppSpacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: vivaTopics.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.95),
          itemBuilder: (context, i) {
            final t = vivaTopics[i];
            final completedStages = [1, 2, 3].where((s) => game.isVivaStageComplete(t.id, s)).length;
            return EntityCard(
              icon: t.icon,
              accentColor: _accent,
              title: t.name,
              description: t.description,
              progress: completedStages / 3,
              progressLabel: '$completedStages/3',
              onTap: () => _openTopic(t),
            );
          },
        ),
      ],
    );
  }

  Widget _stageMap(GameProvider game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(child: Text(topic!.name, style: AppText.sectionTitle)),
          TextButton(onPressed: () => setState(() => topic = null), child: const Text('← Topics')),
        ]),
        Text(topic!.description, style: AppText.body),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          accentColor: _accent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var s = 1; s <= 3; s++) ...[
                StageNode(
                  label: _stageNames[s]!,
                  accentColor: _accent,
                  status: game.isVivaStageComplete(topic!.id, s)
                      ? StatusState.completed
                      : (s == 1 || game.isVivaStageComplete(topic!.id, s - 1))
                          ? StatusState.available
                          : StatusState.locked,
                  onTap: () => _startStage(s),
                ),
                if (s < 3) StageConnector(completed: game.isVivaStageComplete(topic!.id, s), accentColor: _accent),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _questionCard() {
    final q = sessionQuestions[questionIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(child: Text('${topic!.name} — ${_stageNames[stage]}', style: AppText.sectionTitle)),
          TextButton(onPressed: () => setState(() => stage = null), child: const Text('← Stages')),
        ]),
        Pill('Question ${questionIndex + 1}/${sessionQuestions.length}', tone: PillTone.info),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          accentColor: _accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(q.question, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: AppSpacing.sm),
              for (var i = 0; i < q.options.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Card(
                    color: selected != null
                        ? (i == q.correctIndex ? AppColors.good.withValues(alpha: 0.12) : (i == selected ? AppColors.bad.withValues(alpha: 0.12) : null))
                        : null,
                    child: ListTile(
                      onTap: selected == null ? () => _answer(i) : null,
                      title: Text(q.options[i], style: const TextStyle(fontSize: 13)),
                    ),
                  ),
                ),
              if (selected != null) ...[
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(selected == q.correctIndex ? Icons.check_circle : Icons.cancel, color: selected == q.correctIndex ? AppColors.good : AppColors.bad, size: 16),
                        const SizedBox(width: 6),
                        Text(selected == q.correctIndex ? 'Correct' : 'Not quite', style: const TextStyle(fontWeight: FontWeight.w700)),
                      ]),
                      const SizedBox(height: 6),
                      Text(selected == q.correctIndex ? q.followUpCorrect : q.followUpIncorrect, style: AppText.body),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ElevatedButton(onPressed: _nextQuestion, child: Text(questionIndex + 1 >= sessionQuestions.length ? 'Finish Stage' : 'Next Question →')),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _sessionSummary() {
    final correctCount = answered.where((a) => a.correct).length;
    final passed = correctCount >= (sessionQuestions.length * 0.75).ceil();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(child: Text('${topic!.name} — ${_stageNames[stage]} complete', style: AppText.sectionTitle)),
        ]),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          accentColor: passed ? AppColors.good : _accent,
          child: Column(
            children: [
              Icon(passed ? Icons.emoji_events : Icons.replay, size: 36, color: passed ? AppColors.good : _accent),
              const SizedBox(height: 8),
              Text('Score: $correctCount/${sessionQuestions.length}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              Text(passed ? 'Stage passed — next stage unlocked!' : 'Score 75% or higher to unlock the next stage. Review below and try again.', textAlign: TextAlign.center, style: AppText.body),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Review answers', style: AppText.statLabel),
        const SizedBox(height: 6),
        for (final a in answered)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: AppCard(
              padding: const EdgeInsets.all(10),
              child: InkWell(
                onTap: () => _reviewAnswer(a),
                child: Row(
                  children: [
                    Icon(a.correct ? Icons.check_circle : Icons.cancel, color: a.correct ? AppColors.good : AppColors.bad, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(a.question.question, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
                    const Icon(Icons.chevron_right, size: 18),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        Wrap(spacing: 8, children: [
          ElevatedButton.icon(onPressed: () => _startStage(stage!), icon: const Icon(Icons.refresh, size: 16), label: const Text('Retry Stage')),
          OutlinedButton.icon(onPressed: () => setState(() => stage = null), icon: const Icon(Icons.map, size: 16), label: const Text('Back to Stage Map')),
        ]),
      ],
    );
  }
}
