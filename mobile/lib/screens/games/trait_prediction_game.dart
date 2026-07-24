import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/game_provider.dart';
import '../../widgets/app_card.dart';

class _Round {
  final String parentA;
  final String parentB;
  final String question;
  final List<String> options;
  final int correctIndex;
  _Round({required this.parentA, required this.parentB, required this.question, required this.options, required this.correctIndex});
}

String _ratioLabel(String parentA, String parentB) {
  final allelesA = parentA.split('');
  final allelesB = parentB.split('');
  int dominantCount = 0;
  final combos = <String>[];
  for (final a in allelesA) {
    for (final b in allelesB) {
      combos.add(a + b);
      if (a == a.toUpperCase() || b == b.toUpperCase()) dominantCount += 1;
    }
  }
  final dominantPct = ((dominantCount / combos.length) * 100).round();
  final recessivePct = 100 - dominantPct;
  int gcd(int a, int b) => b == 0 ? a : gcd(b, a % b);
  final divisor = gcd(dominantPct, recessivePct) == 0 ? 1 : gcd(dominantPct, recessivePct);
  return recessivePct == 0 ? 'All dominant' : '${dominantPct ~/ divisor}:${recessivePct ~/ divisor}';
}

_Round _buildRound(int seed) {
  const crossOptions = [
    ['Aa', 'Aa'],
    ['Aa', 'aa'],
    ['AA', 'aa'],
    ['Aa', 'AA'],
    ['aa', 'aa'],
  ];
  final pair = crossOptions[seed % crossOptions.length];
  final ratio = _ratioLabel(pair[0], pair[1]);
  const allRatios = ['3:1', '1:1', 'All dominant', 'All recessive', '1:2:1'];
  final uniqueOptions = <String>{ratio, ...allRatios}.take(4).toList();
  final correctIndex = uniqueOptions.indexOf(ratio);
  return _Round(
    parentA: pair[0],
    parentB: pair[1],
    question: 'Cross ${pair[0]} × ${pair[1]} for a single dominant gene. What phenotypic ratio (dominant : recessive) do you expect?',
    options: uniqueOptions,
    correctIndex: correctIndex,
  );
}

class TraitPredictionGame extends StatefulWidget {
  final VoidCallback onExit;
  const TraitPredictionGame({super.key, required this.onExit});

  @override
  State<TraitPredictionGame> createState() => _TraitPredictionGameState();
}

class _TraitPredictionGameState extends State<TraitPredictionGame> {
  int seed = 0;
  int? selected;
  int score = 0;
  int roundsPlayed = 0;

  void _answer(int i, _Round round) {
    if (selected != null) return;
    setState(() {
      selected = i;
      roundsPlayed += 1;
    });
    if (i == round.correctIndex) {
      setState(() => score += 1);
      context.read<GameProvider>().addXp(12, 'Trait Prediction: correct answer');
    }
  }

  void _next() {
    if (roundsPlayed >= 5 && score == 5) context.read<GameProvider>().unlockBadge('game-champion');
    setState(() {
      seed += 1;
      selected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final round = _buildRound(seed);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Trait Prediction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              TextButton(onPressed: widget.onExit, child: const Text('← Back to Games')),
            ],
          ),
          Pill('Score: $score/$roundsPlayed', tone: PillTone.info),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle('Round ${roundsPlayed + 1}'),
                Text(round.question, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: round.options.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 2.4),
                  itemBuilder: (context, i) {
                    final opt = round.options[i];
                    Color? bg;
                    if (selected != null) {
                      if (i == round.correctIndex) {
                        bg = const Color(0x2210B981);
                      } else if (i == selected) {
                        bg = const Color(0x22F43F5E);
                      }
                    }
                    return OutlinedButton(
                      onPressed: () => _answer(i, round),
                      style: OutlinedButton.styleFrom(backgroundColor: bg),
                      child: Text(opt),
                    );
                  },
                ),
                if (selected != null) ...[
                  const SizedBox(height: 10),
                  Row(children: [
                    Icon(selected == round.correctIndex ? Icons.check_circle : Icons.cancel,
                        color: selected == round.correctIndex ? const Color(0xFF059669) : const Color(0xFFF43F5E), size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        selected == round.correctIndex ? 'Correct!' : 'The correct ratio was ${round.options[round.correctIndex]}.',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  ElevatedButton(onPressed: _next, child: const Text('Next Round →')),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
