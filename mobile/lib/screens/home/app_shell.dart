import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../state/game_provider.dart';
import 'home_screen.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final String location;
  const AppShell({super.key, required this.child, required this.location});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final levelInfo = game.levelInfo;
    final pct = levelInfo.xpForNext == 0 ? 0.0 : (levelInfo.xpIntoLevel / levelInfo.xpForNext).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lvl ${levelInfo.level} · ${game.rank.title}', style: const TextStyle(fontSize: 12)),
                Text('${levelInfo.xpIntoLevel} / ${levelInfo.xpForNext} XP', style: const TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(value: pct, minHeight: 6, backgroundColor: Colors.black12),
            ),
          ],
        ),
        toolbarHeight: 64,
        actions: [
          IconButton(
            icon: Icon(game.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: game.toggleTheme,
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                child: Row(
                  children: [
                    Text('🧬', style: TextStyle(fontSize: 28)),
                    SizedBox(width: 10),
                    Text('GeneBreed AI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              for (final m in modules)
                ListTile(
                  leading: Icon(m.icon),
                  title: Text(m.label),
                  selected: location == m.route,
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go(m.route);
                  },
                ),
            ],
          ),
        ),
      ),
      body: child,
    );
  }
}
