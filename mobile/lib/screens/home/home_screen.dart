import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../state/game_provider.dart';
import '../../theme/app_theme.dart';

class ModuleInfo {
  final String route;
  final String label;
  final IconData icon;
  final String desc;
  const ModuleInfo(this.route, this.label, this.icon, this.desc);
}

const List<ModuleInfo> modules = [
  ModuleInfo('/breeder', 'AI Plant Breeder Simulator', Icons.eco, 'Cross parents, advance generations, survive field events, release a variety.'),
  ModuleInfo('/gene-lab', 'Gene Function Discovery Lab', Icons.biotech, 'Edit genes and observe phenotypes to discover what they do.'),
  ModuleInfo('/detective', 'AI Gene Detective', Icons.search, 'Investigate mystery mutants using real diagnostic tools.'),
  ModuleInfo('/supervisor', 'AI Research Supervisor', Icons.school, 'Defend your reasoning under Socratic questioning.'),
  ModuleInfo('/viva', 'AI Viva Examiner', Icons.chat_bubble_outline, 'Adaptive oral-exam-style questioning.'),
  ModuleInfo('/games', 'Genetics Games', Icons.sports_esports, 'Trait prediction, gene matching, and more.'),
  ModuleInfo('/research-lab', 'Virtual Research Lab', Icons.science, 'Heritability, ANOVA, and other real analyses.'),
  ModuleInfo('/notebook', 'Field Notebook', Icons.edit, 'Record and report observations from your trials.'),
  ModuleInfo('/career', 'Career Mode', Icons.emoji_events, 'Climb from Student to Chief Plant Breeder.'),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final level = game.levelInfo.level;
    final rank = game.rank;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.emerald600, AppColors.emerald900], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('WELCOME BACK, ${rank.title.toUpperCase()} (LVL $level)',
                    style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1)),
                const SizedBox(height: 8),
                const Text('🧬 GeneBreed AI', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text(
                  'An immersive virtual laboratory for Plant Breeding & Genetics. Learn by experimenting, not by reading — '
                  'cross plants, edit genes, solve mysteries, and run real breeding programs from seed to released variety.',
                  style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Modules', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: modules.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.92),
            itemBuilder: (context, i) {
              final m = modules[i];
              return _ModuleCard(module: m);
            },
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final ModuleInfo module;
  const _ModuleCard({required this.module});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.go(module.route),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(module.icon, color: AppColors.emerald600, size: 26),
              const SizedBox(height: 8),
              Text(module.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700), maxLines: 3),
              const SizedBox(height: 4),
              Expanded(
                child: Text(module.desc, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color), maxLines: 4, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
