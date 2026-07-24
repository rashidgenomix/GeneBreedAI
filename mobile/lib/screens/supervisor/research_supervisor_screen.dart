import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/supervisor_questions.dart';
import '../../state/game_provider.dart';
import '../../widgets/app_card.dart';

enum ReasoningStrength { weak, developing, strong }

class _Turn {
  final SupervisorPrompt prompt;
  final String response;
  final String feedback;
  final ReasoningStrength strength;
  _Turn({required this.prompt, required this.response, required this.feedback, required this.strength});
}

class ResearchSupervisorScreen extends StatefulWidget {
  const ResearchSupervisorScreen({super.key});

  @override
  State<ResearchSupervisorScreen> createState() => _ResearchSupervisorScreenState();
}

class _ResearchSupervisorScreenState extends State<ResearchSupervisorScreen> {
  final Random rng = Random();
  final topicController = TextEditingController();
  final responseController = TextEditingController();
  bool started = false;
  SupervisorPrompt? currentPrompt;
  final List<_Turn> turns = [];
  bool showHint = false;

  void _begin() {
    if (topicController.text.trim().isEmpty) return;
    setState(() {
      started = true;
      currentPrompt = pickSupervisorPrompt({}, rng);
    });
  }

  ({String feedback, ReasoningStrength strength}) _evaluate(String response) {
    final trimmed = response.trim();
    final words = trimmed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    const markers = ['because', 'evidence', 'data', 'control', 'hypothesis', 'compare', 'expect', 'predict', 'test'];
    final markerHits = markers.where((m) => trimmed.toLowerCase().contains(m)).length;

    if (words.length < 6) {
      return (feedback: "That's quite brief. A research supervisor would push you to elaborate — what specific reasoning or evidence backs this up?", strength: ReasoningStrength.weak);
    }
    if (markerHits >= 2) {
      return (feedback: "Good — you're grounding your answer in evidence and causal reasoning rather than intuition alone. Keep connecting claims to data.", strength: ReasoningStrength.strong);
    }
    return (feedback: "You've stated a position, but try tying it more explicitly to evidence or a testable prediction — what would you expect to see if you're right?", strength: ReasoningStrength.developing);
  }

  void _submit() {
    if (currentPrompt == null || responseController.text.trim().isEmpty) return;
    final evalResult = _evaluate(responseController.text);
    final game = context.read<GameProvider>();
    setState(() {
      turns.add(_Turn(prompt: currentPrompt!, response: responseController.text, feedback: evalResult.feedback, strength: evalResult.strength));
      game.addXp(
        evalResult.strength == ReasoningStrength.strong ? 15 : (evalResult.strength == ReasoningStrength.developing ? 8 : 3),
        'Responded to research supervisor prompt',
      );
      responseController.clear();
      showHint = false;
      currentPrompt = pickSupervisorPrompt(turns.map((t) => t.prompt.question).toSet(), rng);
    });
  }

  Color _strengthColor(ReasoningStrength s) => switch (s) {
        ReasoningStrength.strong => const Color(0xFF059669),
        ReasoningStrength.developing => const Color(0xFFB45309),
        ReasoningStrength.weak => const Color(0xFFE11D48),
      };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🎓 AI Research Supervisor', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text("The supervisor never hands you answers. It interrogates your reasoning and only offers a hint when you're stuck.", style: TextStyle(fontSize: 13)),
          const SizedBox(height: 12),
          if (!started)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CardTitle('What decision or hypothesis do you want to defend?'),
                  const Text('e.g. "I chose Drysdale as a parent because it\'s drought tolerant"', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 8),
                  TextField(controller: topicController, maxLines: 3, decoration: const InputDecoration(border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(onPressed: _begin, icon: const Icon(Icons.school, size: 16), label: const Text('Begin Viva-style Discussion')),
                ],
              ),
            ),
          if (started) ...[
            AppCard(child: Text('Your claim: "${topicController.text}"', style: const TextStyle(fontStyle: FontStyle.italic))),
            const SizedBox(height: 10),
            for (final t in turns)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: const [Icon(Icons.school, size: 16, color: Color(0xFF059669)), SizedBox(width: 6), Text('Supervisor asks:', style: TextStyle(fontWeight: FontWeight.w700))]),
                      Text(t.prompt.question, style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(8)),
                        child: Text('You: ${t.response}', style: const TextStyle(fontSize: 13)),
                      ),
                      const SizedBox(height: 6),
                      Pill('${t.strength.name} reasoning', tone: t.strength == ReasoningStrength.strong ? PillTone.good : (t.strength == ReasoningStrength.developing ? PillTone.warn : PillTone.bad)),
                      const SizedBox(height: 6),
                      Text(t.feedback, style: TextStyle(fontSize: 12, color: _strengthColor(t.strength))),
                    ],
                  ),
                ),
              ),
            if (currentPrompt != null)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: const [Icon(Icons.school, size: 16, color: Color(0xFF059669)), SizedBox(width: 6), Text('Supervisor asks:', style: TextStyle(fontWeight: FontWeight.w700))]),
                    Text(currentPrompt!.question, style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 8),
                    TextField(controller: responseController, maxLines: 3, decoration: const InputDecoration(hintText: 'Respond with your reasoning...', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, children: [
                      ElevatedButton.icon(onPressed: _submit, icon: const Icon(Icons.send, size: 16), label: const Text('Respond')),
                      OutlinedButton.icon(onPressed: () => setState(() => showHint = !showHint), icon: const Icon(Icons.lightbulb, size: 16), label: const Text('Hint')),
                    ]),
                    if (showHint)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Hint: mention what data, comparison, or control would let someone else check your reasoning independently.',
                          style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
