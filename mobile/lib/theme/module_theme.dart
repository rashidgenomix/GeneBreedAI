import 'package:flutter/material.dart';

/// Identifies each of the 9 GeneBreed AI modules so every screen/widget can key into a
/// single, consistent accent color + icon instead of hardcoding either.
enum ModuleId { breeder, geneLab, detective, supervisor, viva, games, researchLab, notebook, career }

class ModuleTheme {
  final ModuleId id;
  final String label;
  final IconData icon;
  final Color color;
  final String route;

  const ModuleTheme({required this.id, required this.label, required this.icon, required this.color, required this.route});

  /// A soft tint of the accent color, used for card backgrounds/chips (theme-aware alpha).
  Color tint([double alpha = 0.12]) => color.withValues(alpha: alpha);
}

const Map<ModuleId, ModuleTheme> moduleThemes = {
  ModuleId.breeder: ModuleTheme(
    id: ModuleId.breeder,
    label: 'Breeder Simulator',
    icon: Icons.eco,
    color: Color(0xFF059669), // emerald
    route: '/breeder',
  ),
  ModuleId.geneLab: ModuleTheme(
    id: ModuleId.geneLab,
    label: 'Gene Function Lab',
    icon: Icons.biotech,
    color: Color(0xFF7C3AED), // violet
    route: '/gene-lab',
  ),
  ModuleId.detective: ModuleTheme(
    id: ModuleId.detective,
    label: 'Gene Detective',
    icon: Icons.search,
    color: Color(0xFFD97706), // amber
    route: '/detective',
  ),
  ModuleId.supervisor: ModuleTheme(
    id: ModuleId.supervisor,
    label: 'Research Supervisor',
    icon: Icons.school,
    color: Color(0xFF4F46E5), // indigo
    route: '/supervisor',
  ),
  ModuleId.viva: ModuleTheme(
    id: ModuleId.viva,
    label: 'Viva Examiner',
    icon: Icons.chat_bubble_outline,
    color: Color(0xFFE11D48), // rose
    route: '/viva',
  ),
  ModuleId.games: ModuleTheme(
    id: ModuleId.games,
    label: 'Genetics Games',
    icon: Icons.sports_esports,
    color: Color(0xFF0891B2), // cyan
    route: '/games',
  ),
  ModuleId.researchLab: ModuleTheme(
    id: ModuleId.researchLab,
    label: 'Virtual Research Lab',
    icon: Icons.science,
    color: Color(0xFF2563EB), // blue
    route: '/research-lab',
  ),
  ModuleId.notebook: ModuleTheme(
    id: ModuleId.notebook,
    label: 'Field Notebook',
    icon: Icons.edit_note,
    color: Color(0xFF65A30D), // lime
    route: '/notebook',
  ),
  ModuleId.career: ModuleTheme(
    id: ModuleId.career,
    label: 'Career Mode',
    icon: Icons.emoji_events,
    color: Color(0xFFEA580C), // orange
    route: '/career',
  ),
};

ModuleTheme moduleTheme(ModuleId id) => moduleThemes[id]!;
