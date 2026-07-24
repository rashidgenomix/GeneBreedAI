import 'package:flutter/material.dart';

/// Maps the kebab-case icon names used in data files (field events, detective clues,
/// badges) to concrete Flutter icons — mirrors the dynamic lucide-react lookup in the web app.
IconData iconForName(String name) {
  switch (name) {
    case 'bug':
      return Icons.bug_report;
    case 'thermometer':
      return Icons.thermostat;
    case 'cloud-drizzle':
      return Icons.water_drop;
    case 'waves':
      return Icons.waves;
    case 'wind':
      return Icons.air;
    case 'sprout':
      return Icons.eco;
    case 'dna':
      return Icons.biotech;
    case 'alert-triangle':
      return Icons.warning_amber_rounded;
    case 'trending-up':
      return Icons.trending_up;
    case 'wallet':
      return Icons.account_balance_wallet;
    case 'microscope':
      return Icons.science;
    case 'git-branch':
      return Icons.account_tree;
    case 'activity':
      return Icons.show_chart;
    case 'map-pin':
      return Icons.location_on;
    case 'test-tube':
      return Icons.biotech;
    case 'ruler':
      return Icons.straighten;
    case 'award':
      return Icons.military_tech;
    case 'shield-check':
      return Icons.verified_user;
    case 'search':
      return Icons.search;
    case 'bar-chart':
      return Icons.bar_chart;
    case 'layers':
      return Icons.layers;
    case 'trophy':
      return Icons.emoji_events;
    case 'book-open':
      return Icons.menu_book;
    default:
      return Icons.auto_awesome;
  }
}
