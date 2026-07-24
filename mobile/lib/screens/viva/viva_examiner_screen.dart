import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/viva_questions.dart';
import '../../state/game_provider.dart';
import '../../widgets/app_card.dart';

class VivaExaminerScreen extends StatefulWidget {
  const VivaExaminerScreen({super.key});

  @override
  State<VivaExaminerScreen> createState() => _VivaExaminerScreenState();
}

class _VivaExaminerScreenState extends State<VivaExaminerScreen> {
  final Random rng = Random();
  int difficulty = 1;
  List<String> askedIds = [];
  VivaQuestion? current;
  int? selected;
  int streak = 0;
  int correctCount = 0;
  int total = 0;

  VivaQuestion? _pickNext(int diff, List<String> exclude) {
    final pool = vivaQuestions.where((q) => q.difficulty == diff && !exclude.contains(q.id)).toList();
    final fallback = vivaQuestions.where((q) => !exclude.contains(q.id)).toList();
    final source = pool.isNotEmpty ? pool : fallback;
    if (source.isEmpty) return null;
    return source[rng.nextInt(source.length)];
  }

  void _start() {
    final q = _pickNext(1, []);
    setState(() {
      current = q;
      askedIds = q != null ? [q.id] : [];
    });
  }

  void _answer(int idx) {
    if (current == null || selected != null) return;
    final isCorrect = idx == current!.correctIndex;
    final game = context.read<GameProvider>();
    setState(() {
      selected = idx;
      total += 1;
      if (isCorrect) {
        correctCount += 1;
        streak += 1;
        game.addXp(10 + current!.difficulty * 5, 'Viva: answered a level-${current!.difficulty} question correctly');
      } else {
        streak = 0;
        game.addXp(2, 'Viva: attempted a question');
      }
    });
  }

  void _next() {
    if (current == null) return;
    final wasCorrect = selected == current!.correctIndex;
    var newDiff = difficulty;
    if (wasCorrect && streak >= 1 && difficulty < 3) newDiff = difficulty + 1;
    if (!wasCorrect && difficulty > 1) newDiff = difficulty - 1;
    final q = _pickNext(newDiff, askedIds);
    setState(() {
      difficulty = newDiff;
      current = q;
      selected = null;
      if (q != null) askedIds = [...askedIds, q.id];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (current == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🗣️ AI Viva Examiner', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text(
                'Adaptive oral-exam-style questioning. Difficulty rises when you answer well and eases off when you struggle.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(onPressed: _start, icon: const Icon(Icons.chat_bubble_outline, size: 16), label: const Text('Start Viva Session')),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Pill('Difficulty: L$difficulty', tone: PillTone.info),
              Pill('$correctCount/$total correct'),
              Pill('Streak: $streak', tone: streak >= 2 ? PillTone.good : PillTone.neutral),
            ],
          ),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle(current!.topic),
                Text(current!.question, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 10),
                for (var i = 0; i < current!.options.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Card(
                      color: selected != null
                          ? (i == current!.correctIndex ? const Color(0x2210B981) : (i == selected ? const Color(0x22F43F5E) : null))
                          : null,
                      child: ListTile(
                        onTap: selected == null ? () => _answer(i) : null,
                        title: Text(current!.options[i], style: const TextStyle(fontSize: 13)),
                      ),
                    ),
                  ),
                if (selected != null)
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(selected == current!.correctIndex ? Icons.check_circle : Icons.cancel,
                              color: selected == current!.correctIndex ? const Color(0xFF059669) : const Color(0xFFF43F5E), size: 16),
                          const SizedBox(width: 6),
                          Text(selected == current!.correctIndex ? 'Correct' : 'Not quite', style: const TextStyle(fontWeight: FontWeight.w700)),
                        ]),
                        const SizedBox(height: 6),
                        Text(selected == current!.correctIndex ? current!.followUpCorrect : current!.followUpIncorrect, style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 8),
                        ElevatedButton(onPressed: _next, child: const Text('Next Question →')),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
