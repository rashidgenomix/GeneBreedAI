import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../state/game_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/module_theme.dart';
import '../../widgets/progress_ring.dart';

/// The 5 bottom-nav destinations. The remaining modules (reached from the Home dashboard's
/// tile grid, or the "More" sheet below) don't need a permanently-reserved tab slot.
const List<ModuleId> _bottomNavModules = [ModuleId.breeder, ModuleId.games, ModuleId.career];

const List<ModuleId> _moreSheetModules = [
  ModuleId.geneLab,
  ModuleId.detective,
  ModuleId.supervisor,
  ModuleId.viva,
  ModuleId.researchLab,
  ModuleId.notebook,
];

class AppShell extends StatelessWidget {
  final Widget child;
  final String location;
  const AppShell({super.key, required this.child, required this.location});

  int get _selectedIndex {
    if (location == '/') return 0;
    final idx = _bottomNavModules.indexWhere((m) => moduleTheme(m).route == location);
    return idx == -1 ? -1 : idx + 1;
  }

  void _onTap(BuildContext context, int index) {
    if (index == 0) {
      context.go('/');
      return;
    }
    if (index <= _bottomNavModules.length) {
      context.go(moduleTheme(_bottomNavModules[index - 1]).route);
      return;
    }
    _showMoreSheet(context);
  }

  void _showMoreSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('More modules', style: AppText.sectionTitle),
                const SizedBox(height: AppSpacing.md),
                for (final id in _moreSheetModules) _MoreTile(id: id),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final levelInfo = game.levelInfo;
    final pct = levelInfo.xpForNext == 0 ? 0.0 : (levelInfo.xpIntoLevel / levelInfo.xpForNext).clamp(0.0, 1.0);
    final currentModule = _currentModuleForLocation(location);
    final accent = currentModule != null ? moduleTheme(currentModule).color : AppColors.emerald600;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: location == '/' ? 16 : 0,
        title: location == '/'
            ? const Text('🧬 GeneBreed AI', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18))
            : Row(
                children: [
                  Icon(moduleTheme(currentModule!).icon, color: accent, size: 20),
                  const SizedBox(width: 8),
                  Text(moduleTheme(currentModule).label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                ],
              ),
        actions: [
          ProgressRing(
            value: pct,
            color: accent,
            size: 34,
            strokeWidth: 3,
            center: Text('${levelInfo.level}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: Icon(game.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: game.toggleTheme,
          ),
        ],
      ),
      // Proper Scaffold composition (bottomNavigationBar slot, not an overlay/Stack) so Flutter
      // automatically reserves body space for the bar — content can never render underneath it.
      body: SafeArea(bottom: false, child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex.clamp(0, _bottomNavModules.length + 1),
        onDestinationSelected: (i) => _onTap(context, i),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          for (final id in _bottomNavModules)
            NavigationDestination(icon: Icon(moduleTheme(id).icon), label: moduleTheme(id).label.split(' ').first),
          const NavigationDestination(icon: Icon(Icons.apps), label: 'More'),
        ],
      ),
    );
  }

  ModuleId? _currentModuleForLocation(String loc) {
    for (final m in moduleThemes.values) {
      if (m.route == loc) return m.id;
    }
    return null;
  }
}

class _MoreTile extends StatelessWidget {
  final ModuleId id;
  const _MoreTile({required this.id});

  @override
  Widget build(BuildContext context) {
    final m = moduleTheme(id);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: m.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppRadius.sm)),
        child: Icon(m.icon, color: m.color),
      ),
      title: Text(m.label, style: AppText.cardTitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context).pop();
        context.go(m.route);
      },
    );
  }
}
