import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/genes.dart';
import '../../state/game_provider.dart';
import '../../widgets/app_card.dart';

class _Tile {
  final String key;
  final String pairId;
  final String content;
  bool matched = false;
  _Tile({required this.key, required this.pairId, required this.content});
}

List<_Tile> _buildTiles() {
  final chosen = geneCards.take(6).toList();
  final tiles = <_Tile>[];
  for (final g in chosen) {
    tiles.add(_Tile(key: '${g.id}-symbol', pairId: g.id, content: g.symbol));
    tiles.add(_Tile(key: '${g.id}-fn', pairId: g.id, content: '${g.function.split('.').first}.'));
  }
  tiles.shuffle();
  return tiles;
}

class GeneMatchingGame extends StatefulWidget {
  final VoidCallback onExit;
  const GeneMatchingGame({super.key, required this.onExit});

  @override
  State<GeneMatchingGame> createState() => _GeneMatchingGameState();
}

class _GeneMatchingGameState extends State<GeneMatchingGame> {
  late List<_Tile> tiles;
  final List<String> flipped = [];
  int moves = 0;

  @override
  void initState() {
    super.initState();
    tiles = _buildTiles();
  }

  void _restart() {
    setState(() {
      tiles = _buildTiles();
      flipped.clear();
      moves = 0;
    });
  }

  void _flip(String key) {
    if (flipped.length == 2 || flipped.contains(key)) return;
    final tile = tiles.firstWhere((t) => t.key == key);
    if (tile.matched) return;

    setState(() => flipped.add(key));

    if (flipped.length == 2) {
      setState(() => moves += 1);
      final a = tiles.firstWhere((t) => t.key == flipped[0]);
      final b = tiles.firstWhere((t) => t.key == flipped[1]);
      if (a.pairId == b.pairId) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!mounted) return;
          setState(() {
            for (final t in tiles) {
              if (t.pairId == a.pairId) t.matched = true;
            }
            flipped.clear();
          });
          context.read<GameProvider>().addXp(10, 'Gene Matching: found a pair');
          if (tiles.every((t) => t.matched)) {
            context.read<GameProvider>().unlockBadge('game-champion');
          }
        });
      } else {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (!mounted) return;
          setState(() => flipped.clear());
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchedCount = tiles.where((t) => t.matched).length;
    final won = matchedCount == tiles.length;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Gene Matching', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
              TextButton(onPressed: widget.onExit, child: const Text('← Back to Games')),
            ],
          ),
          Wrap(spacing: 8, children: [
            Pill('Moves: $moves', tone: PillTone.info),
            Pill('Matched: ${matchedCount ~/ 2}/${tiles.length ~/ 2}', tone: PillTone.good),
          ]),
          if (won)
            AppCard(
              child: Column(
                children: [
                  Text('🎉 Solved in $moves moves!', style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  ElevatedButton(onPressed: _restart, child: const Text('Play Again')),
                ],
              ),
            ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tiles.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.3),
            itemBuilder: (context, i) {
              final t = tiles[i];
              final isFlipped = flipped.contains(t.key) || t.matched;
              return InkWell(
                onTap: () => _flip(t.key),
                child: Container(
                  decoration: BoxDecoration(
                    color: t.matched ? const Color(0x2210B981) : (isFlipped ? Colors.black.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.05)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: t.matched ? const Color(0xFF059669) : Colors.black12),
                  ),
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  child: Text(isFlipped ? t.content : '?', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
