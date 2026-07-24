import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/home/app_shell.dart';
import 'screens/home/home_screen.dart';
import 'screens/breeder/breeder_screen.dart';
import 'screens/genelab/gene_lab_screen.dart';
import 'screens/detective/gene_detective_screen.dart';
import 'screens/supervisor/research_supervisor_screen.dart';
import 'screens/viva/viva_examiner_screen.dart';
import 'screens/games/games_hub_screen.dart';
import 'screens/researchlab/research_lab_screen.dart';
import 'screens/notebook/field_notebook_screen.dart';
import 'screens/career/career_mode_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(location: state.matchedLocation, child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/breeder', builder: (context, state) => const BreederScreen()),
        GoRoute(path: '/gene-lab', builder: (context, state) => const GeneLabScreen()),
        GoRoute(path: '/detective', builder: (context, state) => const GeneDetectiveScreen()),
        GoRoute(path: '/supervisor', builder: (context, state) => const ResearchSupervisorScreen()),
        GoRoute(path: '/viva', builder: (context, state) => const VivaExaminerScreen()),
        GoRoute(path: '/games', builder: (context, state) => const GamesHubScreen()),
        GoRoute(path: '/research-lab', builder: (context, state) => const ResearchLabScreen()),
        GoRoute(path: '/notebook', builder: (context, state) => const FieldNotebookScreen()),
        GoRoute(path: '/career', builder: (context, state) => const CareerModeScreen()),
      ],
    ),
  ],
);
