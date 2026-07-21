import { useMemo, useState } from "react";
import { Card, Pill } from "../../components/ui/Card";
import { Button } from "../../components/ui/Button";
import { GENE_CARDS } from "../../data/genes";
import { useGameStore } from "../../store/gameStore";

interface Tile {
  key: string;
  pairId: string;
  content: string;
  kind: "symbol" | "function";
  matched: boolean;
}

function buildTiles(): Tile[] {
  const chosen = GENE_CARDS.slice(0, 6);
  const tiles: Tile[] = [];
  chosen.forEach((g) => {
    tiles.push({ key: `${g.id}-symbol`, pairId: g.id, content: g.symbol, kind: "symbol", matched: false });
    tiles.push({ key: `${g.id}-fn`, pairId: g.id, content: g.function.split(".")[0] + ".", kind: "function", matched: false });
  });
  for (let i = tiles.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [tiles[i], tiles[j]] = [tiles[j], tiles[i]];
  }
  return tiles;
}

export default function GeneMatchingGame({ onExit }: { onExit: () => void }) {
  const [tiles, setTiles] = useState<Tile[]>(() => buildTiles());
  const [flipped, setFlipped] = useState<string[]>([]);
  const [moves, setMoves] = useState(0);
  const addXp = useGameStore((s) => s.addXp);
  const unlockBadge = useGameStore((s) => s.unlockBadge);

  const matchedCount = tiles.filter((t) => t.matched).length;
  const won = matchedCount === tiles.length;

  function flip(key: string) {
    if (flipped.length === 2 || flipped.includes(key)) return;
    const tile = tiles.find((t) => t.key === key)!;
    if (tile.matched) return;
    const newFlipped = [...flipped, key];
    setFlipped(newFlipped);

    if (newFlipped.length === 2) {
      setMoves((m) => m + 1);
      const [a, b] = newFlipped.map((k) => tiles.find((t) => t.key === k)!);
      if (a.pairId === b.pairId) {
        setTimeout(() => {
          setTiles((ts) => ts.map((t) => (t.pairId === a.pairId ? { ...t, matched: true } : t)));
          setFlipped([]);
          addXp(10, "Gene Matching: found a pair");
        }, 400);
      } else {
        setTimeout(() => setFlipped([]), 800);
      }
    }
  }

  function restart() {
    setTiles(buildTiles());
    setFlipped([]);
    setMoves(0);
  }

  useMemo(() => {
    if (won && moves > 0) unlockBadge("game-champion");
  }, [won, moves, unlockBadge]);

  return (
    <div className="mx-auto max-w-4xl">
      <div className="mb-4 flex items-center justify-between">
        <h1 className="text-xl font-bold">Gene Matching</h1>
        <Button variant="secondary" onClick={onExit}>← Back to Games</Button>
      </div>
      <div className="mb-3 flex gap-2">
        <Pill tone="info">Moves: {moves}</Pill>
        <Pill tone="good">Matched: {matchedCount / 2}/{tiles.length / 2}</Pill>
      </div>

      {won && (
        <Card className="mb-4 border-emerald-600/30 bg-emerald-600/5 text-center">
          <p className="font-semibold">🎉 Solved in {moves} moves!</p>
          <Button className="mt-2" onClick={restart}>Play Again</Button>
        </Card>
      )}

      <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-4">
        {tiles.map((t) => {
          const isFlipped = flipped.includes(t.key) || t.matched;
          return (
            <button
              key={t.key}
              onClick={() => flip(t.key)}
              className={`flex h-28 items-center justify-center rounded-xl border p-2 text-center text-xs font-medium transition ${
                t.matched
                  ? "border-emerald-600 bg-emerald-600/10 text-emerald-700 dark:text-emerald-300"
                  : isFlipped
                  ? "border-emerald-900/20 bg-white dark:border-emerald-50/20 dark:bg-[#16281f]"
                  : "border-emerald-900/10 bg-emerald-900/5 hover:bg-emerald-900/10 dark:border-emerald-50/10 dark:bg-emerald-50/5"
              }`}
            >
              {isFlipped ? t.content : "?"}
            </button>
          );
        })}
      </div>
    </div>
  );
}
